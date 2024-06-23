//
//  MyViewModel.swift
//  ZOOC
//
//  Created by 류희재 on 2023/08/04.
//

import UIKit

import RxSwift
import RxCocoa

final class MyViewModel: ViewModelType {
    private let useCase: MyUseCase
    
    init(myUseCase: MyUseCase) {
        self.useCase = myUseCase
    }
    
    struct Input {
        let viewWillAppearEvent: Observable<Void>
        let registerButtonDidTapEvent: Observable<Void>
        let logoutButtonDidTapEvent: Observable<Void>
        let deleteAccountButtonDidTapEvent: Observable<Void>
    }
    
    struct Output {
        var profileData = PublishRelay<PetResult?>()
        var ticketCnt = PublishRelay<Int>()
        var couponCnt = PublishRelay<Int>()
        var pushToRegisterVC = PublishRelay<Void>()
        var logoutSuccess = PublishRelay<Void>()
        var deleteAccountSuccess = PublishRelay<Void>()
        var showToast = PublishRelay<String>()
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        self.bindOutput(output: output, disposeBag: disposeBag)
        
        input.viewWillAppearEvent
            .flatMap(useCase.requestPetData)
            .bind(to: output.profileData)
            .disposed(by: disposeBag)
        
        input.viewWillAppearEvent
            .flatMap(useCase.requestTicketCnt)
            .bind(to: output.ticketCnt)
            .disposed(by: disposeBag)
        
        input.viewWillAppearEvent
            .flatMap(useCase.requestCouponCnt)
            .bind(to: output.couponCnt)
            .disposed(by: disposeBag)
        
        input.registerButtonDidTapEvent
            .withLatestFrom(output.profileData)
            .filter { $0 == nil }
            .map { _ in }
            .bind(to: output.pushToRegisterVC)
            .disposed(by: disposeBag)
        
        input.logoutButtonDidTapEvent
            .flatMap(useCase.logout)
            .bind(to: output.logoutSuccess)
            .disposed(by: disposeBag)
        
        input.deleteAccountButtonDidTapEvent
            .flatMap(useCase.deleteAccount)
            .bind(to: output.deleteAccountSuccess)
            .disposed(by: disposeBag)
        
        return output
    }
    
    
    private func bindOutput(output: Output, disposeBag: DisposeBag) {
        Observable.merge(
            useCase.logoutFail.asObservable(),
            useCase.deleteAccountFail.asObservable()
        )
        .bind(to: output.showToast)
        .disposed(by: disposeBag)
    }
}
