//
//  ImagePickerViewController.swift
//  ZOOC
//
//  Created by 장석우 on 4/10/24.
//

import UIKit

import SnapKit

import RxSwift
import RxCocoa
import RxGesture
import Photos


protocol ImagePickerViewControllerDelegate: AnyObject {
    func picker(_ picker: ImagePickerViewController, didFinishPicking results: [PHAsset])
}

final class ImagePickerViewController: BaseViewController {
    
    //MARK: - DataSource
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, PHAsset>
    enum Section { case main }
    private var selectedImagesDataSource: DataSource!
    
    //MARK: - Properties
    
    private let viewModel: ImagePickerViewModel
    private let rootView = ImagePickerView()
    
    weak var delegate: ImagePickerViewControllerDelegate?
    
    private let defaultAlbumEvent = PublishRelay<AlbumInfo>()
    private let disposeBag = DisposeBag()
    
    
    //MARK: - Life Cycle
    
    init(viewModel: ImagePickerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        bindUI()
        bindViewModel()
        configureDataSource()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    func bindUI() {
        
        rootView.albumButton.rx.tap
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: rootView.toggleAlbum)
            .disposed(by: disposeBag)
        
        Observable.merge(
            rootView.xButton.rx.tap.asObservable(),
            rootView.unauthorizedView.xButton.rx.tap.asObservable()
        ).subscribe(with: self, onNext: { owner, _ in
                owner.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    func bindViewModel() {
        let input = ImagePickerViewModel.Input(
            viewWillAppear: rx.viewWillAppear.asObservable(),
            goToSettingButtonDidTap: rootView.unauthorizedView.permissionButton.rx.tap.asObservable(),
            albumDidSelect:
                Observable.merge(
                    rootView.albumCollectionView.rx.modelSelected(AlbumInfo.self).asObservable(),
                    defaultAlbumEvent.asObservable()
                ),
            photoCellDidSelect: rootView.photoCollectionView.rx.itemSelected.asObservable(),
            photoCellDidDeselect: rootView.photoCollectionView.rx.modelDeselected(PHAsset.self).asObservable(),
            selectedCellDidSelect: rootView.selectedPhotoCollectionView.rx.itemSelected.asObservable(),
            doneButtonDidTap: rootView.confirmButton.rx.tap.asObservable()
            
        )
        
        let output = viewModel.transform(from: input, disposeBag: disposeBag)
        
        output.getPermissionPhotoLibraryAuthSuccess
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: rootView.hiddenUnauthorizedView)
            .disposed(by: disposeBag)
        
        output.albums
            .asDriver(onErrorJustReturn: [])
            .do(onNext: {
                guard let firstAlbum = $0.first else { return }
                self.defaultAlbumEvent.accept(firstAlbum)
            })
            .drive(rootView.albumCollectionView.rx.items(
                cellIdentifier: AlbumCollectionViewCell.reuseCellIdentifier,
                cellType: AlbumCollectionViewCell.self)
            ) { row, album, cell in
                cell.dataBind(album)
            }
            .disposed(by: disposeBag)
        
        output.albumChanged
            .asDriver(onErrorJustReturn: .unknown())
            .do(onNext: rootView.updateAlbumTitle)
            .map { _ in }
            .drive(onNext: rootView.toggleAlbum)
            .disposed(by: disposeBag)
        
        output.images
            .asDriver(onErrorJustReturn: [])
            .drive(rootView.photoCollectionView.rx.items(
                cellIdentifier: PhotoCollectionViewCell.reuseCellIdentifier,
                cellType: PhotoCollectionViewCell.self)
            ) { row, image, cell in
                cell.dataBind(image)
                cell.observe(at: output.selectedImages)
                if output.selectedImages.value.contains(image) {
                    self.rootView.photoCollectionView.selectCell(at: IndexPath(row: row, section: 0))
                }
            }
            .disposed(by: disposeBag)
        
        output.selectedImages
            .skip(1)
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: loadSnapshot)
            .disposed(by: disposeBag)
        
        output.selectedImages
            .map { $0.count }
            .asDriver(onErrorJustReturn: 0 )
            .drive(onNext: rootView.updateUI)
            .disposed(by: disposeBag)
        
        output.selectImage
            .asDriver(onErrorJustReturn: .init())
            .drive(onNext: rootView.photoCollectionView.selectCell)
            .disposed(by: disposeBag)
        
        output.deselectImage
            .asDriver(onErrorJustReturn: .init())
            .drive(onNext: rootView.photoCollectionView.deselectCell)
            .disposed(by: disposeBag)
        
        output.showToast
            .asDriver(onErrorJustReturn: .init())
            .drive(onNext: presentToast)
            .disposed(by: disposeBag)
        
        output.didFinishPicking
            .asDriver(onErrorJustReturn: [])
            .drive(with: self, onNext: { owner, assets in
                owner.delegate?.picker(owner, didFinishPicking: assets)
            })
            .disposed(by: disposeBag)
    }
}

//MARK: - Cell


// MARK: - Snapshot

private extension ImagePickerViewController {
    
    func configureDataSource() {
        
        let cellRegsitration = UICollectionView.CellRegistration
        <SelectedPhotoCollectionViewCell, PHAsset> { cell, _, asset in
            cell.dataBind(asset)
        }
        
        self.selectedImagesDataSource = DataSource(
            collectionView: self.rootView.selectedPhotoCollectionView
        ) { cv, indexPath, asset in
            return cv.dequeueConfiguredReusableCell(
                using: cellRegsitration,
                for: indexPath,
                item: asset
            )
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, PHAsset>()
        snapshot.appendSections([.main])
        snapshot.appendItems([], toSection: .main)
        selectedImagesDataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func loadSnapshot(with assets: [PHAsset]) {
        var snapshot = selectedImagesDataSource.snapshot()
        let previousAssets = snapshot.itemIdentifiers(inSection: .main)
        snapshot.deleteItems(previousAssets)
        snapshot.appendItems(assets, toSection: .main)
        self.selectedImagesDataSource.apply(snapshot, animatingDifferences: true)
        if previousAssets.count < assets.count {
            rootView.scrollToRight()
        }
        
    }
}

