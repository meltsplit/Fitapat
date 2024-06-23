//
//  GenAISelectImageViewModel.swift
//  ZOOC
//
//  Created by 류희재 on 2023/08/18.
//

import UIKit

import RxSwift
import RxCocoa
import PhotosUI
import MobileCoreServices

final class GenAISelectedImageViewModel: ViewModelType {
    
    
    //MARK: - Properties
    
    private let useCase: GenAISelectedImageUseCase
    
    private var initData: SelectedImagesModel
    internal var disposeBag = DisposeBag()
    
    //MARK: - Life Cycle
    
    init(
        useCase: GenAISelectedImageUseCase,
        initData: SelectedImagesModel
    ) {
        self.useCase = useCase
        self.initData = initData
    }
    
    struct Input {
        var viewWillAppearEvent: Observable<Void>
        var reselectImagesButtonDidTap: Observable<Void>
        var reselectImagesDidFinishPicking: Observable<[PHAsset]>
        var generateAIModelButtonDidTapEvent: Observable<Void>
    }
    
    struct Output {
        var selectedImages = PublishRelay<[PHAsset]>()
        var presentFapImagePicker = PublishRelay<[PHAsset]>()
        var imageUploadDidBegin = PublishRelay<Void>()
        var showToast = PublishRelay<String>()
    }
    
    func transform(from input: Input, disposeBag: RxSwift.DisposeBag) -> Output {
        let output = Output()
        self.bindOutput(output: output, disposeBag: disposeBag)
        
        input.viewWillAppearEvent
            .map { self.initData.assets}
            .bind(to: output.selectedImages)
            .disposed(by: disposeBag)
        
        input.reselectImagesButtonDidTap
            .map { self.initData.assets }
            .bind(to: output.presentFapImagePicker)
            .disposed(by: disposeBag)
        
        input.reselectImagesDidFinishPicking
            .do(onNext: { self.initData.assets = $0 })
            .bind(to: output.selectedImages)
            .disposed(by: disposeBag)
        
        input.generateAIModelButtonDidTapEvent
            .map { self.initData }
            .bind(onNext: useCase.handlePetData)
            .disposed(by: disposeBag)
        
        return output
    }
    
    
    //MARK: - Custom Method
    
    private func bindOutput(output: Output, disposeBag: DisposeBag) {
        
        useCase.imageUploadDidBegin
            .bind(to: output.imageUploadDidBegin)
            .disposed(by: disposeBag)
        
        useCase.registerError
            .bind(to: output.showToast)
            .disposed(by: disposeBag)
        
        useCase.makeDataSetError
            .bind(to: output.showToast)
            .disposed(by: disposeBag)
        
    }
}

