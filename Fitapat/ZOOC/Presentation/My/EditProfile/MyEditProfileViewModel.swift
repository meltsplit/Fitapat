//
//  MyEditProfileViewModel.swift
//  ZOOC
//
//  Created by 류희재 on 2023/08/08.
//

/// 1. 이미지를 삭제했는데 삭제가 안됨
/// 2. 이름 텍스트필드 계쏙 넘어서 보내져서 걍 망함

import UIKit

import RxSwift
import RxCocoa
import Kingfisher

final class MyEditProfileViewModel: ViewModelType {
    private let myEditProfileUseCase: MyEditProfileUseCase
    
    init(myEditProfileUseCase: MyEditProfileUseCase) {
        self.myEditProfileUseCase = myEditProfileUseCase
    }
    
    struct Input {
        var viewWillAppearEvent: Observable<Void>
        var nameTextFieldDidChangeEvent: Observable<String>
        var breedTextFieldDidChangeEvent: Observable<String?>
        var profileImageDidChangeEvent: Observable<Data?>
        var editButtonTapEvent: Observable<Void>
    }
    
    struct Output {
        var petResult = PublishRelay<PetResult>()
        var isEdited = PublishRelay<Void>()
        var showToast = PublishRelay<String>()
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        self.bindOutput(output: output, disposeBag: disposeBag)
        
        input.viewWillAppearEvent
            .flatMap(myEditProfileUseCase.getPetResult)
            .filter { $0 != nil }
            .map { $0! }
            .bind(to: output.petResult)
            .disposed(by: disposeBag)
        
        input.editButtonTapEvent
            .withLatestFrom(Observable.combineLatest(
                input.nameTextFieldDidChangeEvent,
                input.breedTextFieldDidChangeEvent,
                input.profileImageDidChangeEvent
            )
        ).map { MyEditProfileModel(
                    name: $0.0,
                    breed: $0.1,
                    profileImg: $0.2
                )
            }
            .flatMap(myEditProfileUseCase.editProfile)
            .bind(to: output.isEdited)
            .disposed(by: disposeBag)
        
        return output
    }
    
    private func bindOutput(output: Output, disposeBag: DisposeBag) {
        myEditProfileUseCase.editFail
            .bind(to: output.showToast)
            .disposed(by: disposeBag)
    }
}



//import Foundation
//
//struct MyEditProfileModel {
//    let name: String
//    let breed: String?
//    let profileImg: Data?
//
//    init(name: String, breed: String?, profileImg: Data?) {
//        self.name = name
//        self.breed = breed
//        self.profileImg = profileImg
//    }
