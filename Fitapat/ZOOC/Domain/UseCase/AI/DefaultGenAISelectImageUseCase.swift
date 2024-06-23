//
//  DefaultGenAISelectImageUseCase.swift
//  ZOOC
//
//  Created by 류희재 on 2023/09/21.
//

import UIKit

import RxSwift
import RxCocoa
import PhotosUI

final class DefaultGenAISelectedImageUseCase: GenAISelectedImageUseCase, PHAssetTransformer {
    typealias ImageUploadManagerProtocol = ImageManagerSettable & ImageManagerResponseSendable & URLSessionTaskDelegate
    
    private var petRepository: PetRepository
    var imageManager = PHCachingImageManager()
    private let imageUploadManager: ImageUploadManagerProtocol
    
    private let disposeBag = DisposeBag()
    
    init(
        repository: PetRepository,
        imageUploadManager: ImageUploadManagerProtocol
    ) {
        self.petRepository = repository
        self.imageUploadManager = imageUploadManager
    }
    
    deinit {
        print("DefaultGenAISelectImageUseCase 죽는다")
    }
    
    var ableToShowImages = PublishRelay<Bool>()
    
    var registerError = PublishRelay<String>()
    var makeDataSetError = PublishRelay<String>()
    var imageUploadDidBegin = PublishRelay<Void>()
    
    func handlePetData(with model: SelectedImagesModel) {
        guard let pet = model.retryWithPet else {
            registerPet(with: model)
            return
        }
        guard let datasetID = pet.datasetID else {
            makeDataSet(for: pet.id, with: model.assets)
            return
        }
        
        Task {
            let images = await transformToUIImages(for: model.assets,
                                             targetSize: .init(width: 1024, height: 1024))
            uploadImages(datasetId: datasetID, images: images)
        }
        
    }
    
    func registerPet(with model: SelectedImagesModel) {
        let request = MyRegisterPetRequest(name: model.name, breed: model.breed)
        petRepository.registerPet(request)
            .map { $0.id }
            .subscribe(with: self, onNext: { owner, id in
                owner.makeDataSet(for: id, with: model.assets)
                NotificationCenter.default.post(name: .refreshCustom, object: nil)
            }, onError: { owner, _ in
                owner.registerError.accept("반려동물 등록 과정 중 오류가 발생했습니다.")
            }).disposed(by: disposeBag)
    }
    
    func makeDataSet(for petID: Int, with assets: [PHAsset]) {
        petRepository.postMakeDataset(petID)
            .subscribe(with: self, onNext: { owner, result in
                Task { @MainActor in
                    let images = await owner.transformToUIImages(
                        for: assets,
                        targetSize: .init(width: 1024, height: 1024)
                    )
                    owner.uploadImages(datasetId: result.datasetId, images: images)
                }
                
            }, onError: { owner, _ in
                owner.makeDataSetError.accept(("데이터셋을 만드는 과정 중 오류가 발생했습니다."))
            }).disposed(by: disposeBag)
    }
    
    func uploadImages(datasetId: String, images: [UIImage]) {
        self.imageUploadDidBegin.accept(Void())
        Task { @MainActor in 
            do {
                _ = try await petRepository.postPetImages(datasetID: datasetId,
                                                          files: images,
                                                          with: imageUploadManager)
                self.petRepository.updatePetInfo()
                self.imageUploadManager.responseSuccess()
            } catch {
                
                dump(error)
                let code = (error as NSError).code
                print(code)
                
                switch code {
                case -999: //백그라운드로 들어갔을 때
                    return self.imageUploadManager.responseFail(willContinue: true)
                case -1005: //인터넷 연결이 끊겼을 때
                    return self.imageUploadManager.responseFail(willContinue: false)
                default: break
                }
                
                guard let error = error as? NetworkServiceError else {
                    imageUploadManager.responseFail(willContinue: true)
                    return
                }
                imageUploadManager.responseFail(willContinue: false)
            }
        }
    }
}
