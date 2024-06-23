//
//  DefaultMyEditProfileUseCase.swift
//  ZOOC
//
//  Created by 류희재 on 2023/09/25.
//

import UIKit

import RxSwift
import RxCocoa

final class DefaultMyEditProfileUseCase: MyEditProfileUseCase {
    private let petRepository: PetRepository
    private let disposeBag = DisposeBag()
    
    private var petId: Int?
    var editFail = PublishRelay<String>()
    
    init(petRepository: PetRepository) {
        self.petRepository = petRepository
    }
}

extension DefaultMyEditProfileUseCase {
    func getPetResult() -> Observable<PetResult?> {
        return petRepository.getPet()
            .do(onNext: { [weak self] petData in
                self?.petId = petData?.id
            })
    }
    
    func editProfile(_ profileData: MyEditProfileModel) -> Observable<Void> {
        print(#function)
        guard let petId else {
            return Observable<Void>.empty()
        }
        let request = EditProfileRequest(
            id: petId,
            photo: profileData.profileImg != nil,
            name: profileData.name,
            breed: profileData.breed,
            file: profileData.profileImg
        )
        return petRepository.patchPet(request)
            .do(onNext: { _ in
                NotificationCenter.default.post(name: .refreshCustom, object: nil)
            })
            .map { _ in }
            .catch { [weak self] error in
                self?.editFail.accept("잠시 후 다시 시도 해주세요")
                return Observable.empty()
            }
    }
}
   

