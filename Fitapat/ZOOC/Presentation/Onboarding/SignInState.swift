//
//  SignInState.swift
//  ZOOC
//
//  Created by 장석우 on 3/8/24.
//


import RxSwift


//MARK: - <로그인> 둘 다 필요할때

struct SignInNeedBothState: OnboardingNavigationState {
    
    var nameButtonTitle: String? = "다음"
    var phoneButtonTitle: String? = "로그인"
    
    //0406 이름 리젝 해결 중. 어차피 oauthModel에 이름있으니 action이 알아서 바꿔줄거임.
    var loginDestination: OnboardingDestination = .name //0406 변경 //0407변경
    
    var nameDestination: OnboardingDestination = .phone
    var phoneDestination: OnboardingDestination = .main
}

extension SignInNeedBothState: OnboardingActionSelector {

    func selectPhoneAction(_ usecase: OnboardingPhoneVerificationUseCase) -> (OnboardingUserInfo) -> RxSwift.Observable<Void> {
        return usecase.loginWithUserInfo
    }
}

//MARK: - <로그인> 번호만 필요할때

struct SignInNeedPhoneState: OnboardingNavigationState {
    
    var phoneButtonTitle: String? = "로그인"
    
    var loginDestination: OnboardingDestination = .phone
    var phoneDestination: OnboardingDestination = .main
}

extension SignInNeedPhoneState: OnboardingActionSelector {
    
    func selectPhoneAction(_ usecase: OnboardingPhoneVerificationUseCase) -> (OnboardingUserInfo) -> RxSwift.Observable<Void> {
        return usecase.loginWithUserInfo
    }
}


//MARK: - <로그인> 이름만 필요할때

struct SignInNeedNameState: OnboardingNavigationState {
    
    var nameButtonTitle: String? = "로그인"
    
    //0406 이름 리젝 해결 중. 어차피 oauthModel에 이름있으니 action이 알아서 바꿔줄거임.
    var loginDestination: OnboardingDestination = .name //0406 변경
    
    var nameDestination: OnboardingDestination = .main
}

extension SignInNeedNameState: OnboardingActionSelector {

//    func selectLoginAction(_ usecase: OnboardingLoginUseCase) -> (OnboardingUserInfo) -> Observable<Void> {
//        return usecase.loginWithUserInfo
//    }
    
    func selectNameAction(_ usecase: OnboardingNameUseCase) -> (OnboardingUserInfo) -> RxSwift.Observable<Void> {
        return usecase.loginWithUserInfo
    }

}

//MARK: - <로그인> 아무것도 필요하지 않을 때

struct SignInNotNeedState: OnboardingNavigationState {
    
    var loginDestination: OnboardingDestination = .main
}

extension SignInNotNeedState: OnboardingActionSelector {
    func selectLoginAction(_ usecase: OnboardingLoginUseCase) -> (OnboardingUserInfo) -> RxSwift.Observable<Void> {
        usecase.login
    }

}

struct SignInUpdateWithSocialInfoState: OnboardingNavigationState {
    var loginDestination: OnboardingDestination = .main
}

extension SignInUpdateWithSocialInfoState: OnboardingActionSelector {
    
    func selectLoginAction(_ usecase: OnboardingLoginUseCase) -> (OnboardingUserInfo) -> Observable<Void> {
        return usecase.loginWithUserInfo
    }

}

//MARK: - 이름/ 휴대폰 받지 않는 로직

struct SignInJustState: OnboardingNavigationState {
    var loginDestination: OnboardingDestination = .main
}

extension SignInJustState: OnboardingActionSelector {
    
    func selectLoginAction(_ usecase: OnboardingLoginUseCase) -> (OnboardingUserInfo) -> Observable<Void> {
        return usecase.login
    }

}
