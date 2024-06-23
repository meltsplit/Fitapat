//
//  OnboardingPhoneVerificationUseCase.swift
//  ZOOC
//
//  Created by 장석우 on 3/8/24.
//

import RxSwift

protocol OnboardingPhoneVerificationUseCase: OnboardingBaseUseCase {
    
    func sendVertificationCode(to phoneNumberWithHypen: String) -> Observable<Void>
    func checkDemoAccount(_ userInfo: UserInfo) -> Observable<Bool>
    func verify(with code: String) -> Bool
}
