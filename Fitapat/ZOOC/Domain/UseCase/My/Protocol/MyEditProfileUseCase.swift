//
//  MyEditProfileUseCase.swift
//  ZOOC
//
//  Created by 류희재 on 2023/09/25.
//

import UIKit

import RxSwift
import RxCocoa

protocol MyEditProfileUseCase {
    var editFail: PublishRelay<String> { get }
    
    func getPetResult() -> Observable<PetResult?>
    func editProfile(_ profileData: MyEditProfileModel) -> Observable<Void>
}
