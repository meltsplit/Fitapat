//
//  ImagePickerViewModel.swift
//  ZOOC
//
//  Created by 장석우 on 4/10/24.
//

import Foundation
import UIKit
import Photos

import RxSwift
import RxRelay

final class ImagePickerViewModel: ViewModelType {
    
    //MARK: - Dependency

    let photoAuthService = DefaultPhotoAuthService()
    let albumService = DefaultAlbumService()
    let photoService = DefaultPhotoService()
    
    //MARK: - Properties
    
    private let atLeast = 8
    private let atMost = 15
    private var selectedAssets: [PHAsset] = []
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let goToSettingButtonDidTap: Observable<Void>
        let albumDidSelect: Observable<AlbumInfo>
        let photoCellDidSelect: Observable<IndexPath>
        let photoCellDidDeselect: Observable<PHAsset>
        let selectedCellDidSelect: Observable<IndexPath>
        let doneButtonDidTap: Observable<Void>
    }
    
    struct Output {
        let getPermissionPhotoLibraryAuthSuccess = PublishRelay<Bool>()
        let albumChanged = PublishRelay<AlbumInfo>()
        let albums = PublishRelay<[AlbumInfo]>()
        let images = PublishRelay<[PHAsset]>()
        let selectedImages = BehaviorRelay<[PHAsset]>(value: [])
        let selectImage = PublishRelay<IndexPath>()
        let deselectImage = PublishRelay<IndexPath>()
        let didFinishPicking = PublishRelay<[PHAsset]>()
        let showToast = PublishRelay<String>()
    }
    
    
    //MARK: - Life Cycle

    init(with selectedAssets: [PHAsset] = []) {
        self.selectedAssets = selectedAssets
    }
    
    
    func transform(from input: Input,
                   disposeBag: RxSwift.DisposeBag) -> Output {
        let output = Output()
        
        input.viewWillAppear
            .map { self.photoAuthService.canFullAccessPhotoLibrary }
            .bind(to: output.getPermissionPhotoLibraryAuthSuccess)
            .disposed(by: disposeBag)
        
        input.viewWillAppear
            .filter { self.photoAuthService.canFullAccessPhotoLibrary }
            .flatMap(albumService.getAlbums)
            .bind(to: output.albums)
            .disposed(by: disposeBag)
        
        input.goToSettingButtonDidTap
            .flatMap(photoAuthService.requestAuthorization)
            .bind(to: output.getPermissionPhotoLibraryAuthSuccess)
            .disposed(by: disposeBag)
        
        input.albumDidSelect
            .do(onNext: { output.albumChanged.accept($0)})
            .map { $0.album }
            .flatMap(photoService.convertAlbumToPHAssets)
            .subscribe(with: self, onNext: { owner, images in
                output.images.accept(images)
                output.selectedImages.accept(owner.selectedAssets)
            })
            .disposed(by: disposeBag)
        
        input.photoCellDidSelect
            .withLatestFrom(output.images) { ($0, $1) }
            .subscribe(with: self, onNext: { owner, data in
                let indexPath = data.0
                let asset = data.1[indexPath.row]
                
                if owner.selectedAssets.count < owner.atMost {
                    owner.selectedAssets.append(asset)
                    output.selectedImages.accept(owner.selectedAssets)
                } else {
                    output.showToast.accept("사진은 최대 15장까지 선택 가능해요")
                    output.deselectImage.accept(indexPath)
                }
        })
        .disposed(by: disposeBag)
        
        input.photoCellDidDeselect
            .subscribe(with: self, onNext: { owner, asset in
                guard let index = owner.selectedAssets.firstIndex(of: asset) else { return}
                owner.selectedAssets.remove(at: index)
                output.selectedImages.accept(owner.selectedAssets)
        })
        .disposed(by: disposeBag)
        
        input.selectedCellDidSelect
            .subscribe(with: self, onNext: { owner, indexPath in
                owner.selectedAssets.remove(at: indexPath.row)
                output.selectedImages.accept(owner.selectedAssets)
        })
        .disposed(by: disposeBag)
        
        input.doneButtonDidTap
            .map { self.selectedAssets }
            .bind(to: output.didFinishPicking)
            .disposed(by: disposeBag)
        
        return output
    }
}
