//
//  DefaultOnboardingPhoneVerificationUsecase.swift
//  ZOOC
//
//  Created by 장석우 on 3/6/24.
//

import RxSwift
import RxRelay

final class DefaultOnboardingPhoneVerificationUseCase: OnboardingPhoneVerificationUseCase {
    
    let userRepository: UserRepository
    let authRepository: AuthRepository
    let appRepository: AppRepository
    
    private let disposeBag = DisposeBag()
    
    let loginError = PublishRelay<String>()
    
    private var verificationCode: String?
    
    init(
        userRepository: UserRepository,
        authRepository: AuthRepository,
        appRepository: AppRepository
    ) {
        self.userRepository = userRepository
        self.authRepository = authRepository
        self.appRepository = appRepository
    }
    
    func sendVertificationCode(to phoneNumberWithHypen: String) -> Observable<Void> {
        
        let phoneNumber = phoneNumberWithHypen
            .replacingOccurrences(of: "-", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        verificationCode = RandomNumberGenerator.create(length: 6)
        return authRepository.sendVerificationMessage(
            to: phoneNumber,
            code: verificationCode!)
        .do(onError: { err in
            self.loginError.accept("문자 전송에 실패했습니다")})
        .catch { _ in Observable.empty()}
        
    }
    
    func verify(with code: String) -> Bool {
        return code == verificationCode
    }
    
    func checkDemoAccount(_ userInfo: UserInfo) -> RxSwift.Observable<Bool> {
        return appRepository.checkDemoTestable()
            .map { testable in
                return testable && userInfo.phone == Config.demoPhone
            }
            .catchAndReturn(false)
    }
    
    
}
