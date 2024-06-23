//
//  DefaultMyUseCase.swift
//  ZOOC
//
//  Created by 류희재 on 2023/09/25.
//

import UIKit

import RxSwift
import RxCocoa

final class DefaultMyUseCase: MyUseCase {
    private let petRepository: PetRepository
    private let authRepository: AuthRepository
    private let userRepository: UserRepository
    
    private let disposeBag = DisposeBag()
    
    init(
        petRepository: PetRepository,
        authRepository: AuthRepository,
        userRepository: UserRepository
    ) {
        self.petRepository = petRepository
        self.authRepository = authRepository
        self.userRepository = userRepository
    }
    
    var logoutFail = PublishRelay<String>()
    var deleteAccountFail = PublishRelay<String>()
}

extension DefaultMyUseCase {
    func requestPetData() -> Observable<PetResult?> {
        return  petRepository.getPet()
            .asObservable()
            .catch { _ in .empty()}
    }
    
    func requestTicketCnt() -> Observable<Int> {
        userRepository.getTicket()
            .asObservable()
            .catch{ _ in return Observable.empty() }
    }
    
    func requestCouponCnt() -> Observable<Int> {
        userRepository.getCoupon()
            .asObservable()
            .catch { _ in return Observable.empty() }
    }
    
    func logout() -> Observable<Void>{
        userRepository.logout()
            .catch { [weak self] error in
                self?.logoutFail.accept("로그아웃에 실패했습니다.")
                return Observable.empty()
            }
    }
    
    func deleteAccount() -> Observable<Void>{
        userRepository.deleteAccount()
            .catch { [weak self] error in
                self?.deleteAccountFail.accept("회원탈퇴에 실패했습니다.")
                return Observable.empty()
            }
    }
}



