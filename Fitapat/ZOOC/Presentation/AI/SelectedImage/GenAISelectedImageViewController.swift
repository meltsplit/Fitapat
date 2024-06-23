//
//  GenAISelectImageViewController.swift
//  ZOOC
//
//  Created by 류희재 on 2023/08/18.
//

import UIKit

import RxSwift
import RxCocoa
import Photos

final class GenAISelectedImageViewController : BaseViewController {
    
    //MARK: - Properties
    
    let viewModel: GenAISelectedImageViewModel
    
    private let reselectImagesDidFinishPickingEvent = PublishRelay<[PHAsset]>()
    private let disposeBag = DisposeBag()
    
    //MARK: - UI Components
    
    let rootView = GenAISelectedImageView()
    
    let xButton = UIBarButtonItem(image: .icExit,
                                  style: .plain,
                                  target: nil,
                                  action: nil)
    
    //MARK: - Life Cycle
    
    init(viewModel: GenAISelectedImageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar()
        bindUI()
        bindViewModel()
    }
    
    //MARK: - Custom Method
    
    private func setNavigationBar() {
        navigationItem.rightBarButtonItems = [UIBarButtonItem.fixedSpace(10),
                                              xButton]
    }
    
    private func bindUI() {
        xButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.presentAlertViewController()
            }
            .disposed(by: disposeBag)
        
        rootView.generateAIModelButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.rootView.generateAIModelButton.isEnabled = false
                owner.rootView.generateAIModelButton.setTitle("", for: .normal)
                owner.rootView.buttonActivityIndicatorView.startAnimating()
            }
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        let input = GenAISelectedImageViewModel.Input(
            viewWillAppearEvent: self.rx.viewWillAppear.asObservable(),
            reselectImagesButtonDidTap: self.rootView.reSelectImageButton.rx.tap.asObservable(),
            reselectImagesDidFinishPicking: self.reselectImagesDidFinishPickingEvent.asObservable(),
            generateAIModelButtonDidTapEvent: self.rootView.generateAIModelButton.rx.tap.asObservable()
        )
        
        let output = self.viewModel.transform(from: input, disposeBag: self.disposeBag)
        
        output.selectedImages
            .asDriver(onErrorJustReturn: [])
            .drive(
                rootView.petImageCollectionView.rx.items(
                    cellIdentifier: GenAIPetImageCollectionViewCell.cellIdentifier,
                    cellType: GenAIPetImageCollectionViewCell.self)
            ) { row, data, cell in
                cell.dataBind(data)
            }
            .disposed(by: disposeBag)
        
        output.presentFapImagePicker
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: presentFapPickerViewController)
            .disposed(by: disposeBag)
        
        output.imageUploadDidBegin
            .subscribe(with: self,
                       onNext: { owner, _ in
                owner.rootView.buttonActivityIndicatorView.stopAnimating()
                
                owner.dismiss(animated: true)
                owner.navigationController?.popToRootViewController(animated: true)
            }).disposed(by: disposeBag)
        
        output.showToast
            .asDriver(onErrorJustReturn: "")
            .drive(with: self, onNext: { owner, message in
                owner.presentToast(message)
            }).disposed(by: disposeBag)
        
      
    }
}

extension GenAISelectedImageViewController {
    func presentAlertViewController() {
        let alertVC = FapAlertViewController(.leaveAIPage)
        alertVC.delegate = self
        self.present(alertVC, animated: false)
    }
    
    private func presentFapPickerViewController(with assets: [PHAsset]) {
        let pickerVC = ImagePickerViewController(viewModel: ImagePickerViewModel(with: assets))
        pickerVC.modalPresentationStyle = .fullScreen
        pickerVC.delegate = self
        self.present(pickerVC, animated: true)
    }
}

extension GenAISelectedImageViewController: FapAlertViewControllerDelegate {
    func leftButtonDidTap(_ alertType: FapAlertType) {
        dismiss(animated: true)
        navigationController?.popViewController(animated: true)
    }
    
    func rightButtonDidTap(_ alertType: FapAlertType) {
        return
    }
}


extension GenAISelectedImageViewController: ImagePickerViewControllerDelegate {
    func picker(_ picker: ImagePickerViewController, 
                didFinishPicking results: [PHAsset]) {
        picker.dismiss(animated: true)
        self.reselectImagesDidFinishPickingEvent.accept(results)
    }
}
