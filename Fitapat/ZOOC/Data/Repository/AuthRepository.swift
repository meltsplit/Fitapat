//
//  UserRepository.swift
//  ZOOC
//
//  Created by 장석우 on 11/18/23.
//

import Foundation

import RxSwift
import Moya

protocol AuthRepository {
    func sendVerificationMessage(to phoneNumber: String, code: String) -> Observable<Void>
    func authorize(_ serviceType: OAuthProviderType) -> Observable<OAuthAuthenticationModel>
    func userCheck(_ oauthModel: OAuthAuthenticationModel) -> Observable<OnboardingUserInfo>
    func login(_ oauthModel: OAuthAuthenticationModel) -> Observable<FitapatAuthenticationResult>
    func signUp(_ model: OnboardingUserInfo) -> Observable<FitapatAuthenticationResult> 
    func saveJWTTokens(_ result: FitapatAuthenticationResult)
    
}

final class DefaultAuthRepository {
    
    //MARK: - Dependency
    
    private let authService: AuthService
    private let realmService: RealmService
    private let smsService: SMSService
    private let factory: (OAuthProviderType) -> OAuthServiceType
    
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Life Cycle
    
    init(
        authService: AuthService,
        realmService: RealmService,
        smsService: SMSService,
        factory: @escaping (OAuthProviderType) -> OAuthServiceType
    ) {
        self.authService = authService
        self.realmService = realmService
        self.smsService = smsService
        self.factory = factory
    }
    
}

extension DefaultAuthRepository: AuthRepository {
    
    func sendVerificationMessage(to phoneNumber: String, code: String) -> RxSwift.Observable<Void> {
        smsService.sendMessage(.init(code: code, receiver: phoneNumber))
            .asObservable()
            .replacingNetworkError(of: .notFound, with: AuthError.sendMessageFail)
            .do(onError: { _ in SentryManager.capture(AuthError.sendMessageFail) })
    }
    
    func authorize(_ serviceType: OAuthProviderType) -> Observable<OAuthAuthenticationModel> {
        return factory(serviceType)
            .authorize()
            .asObservable()
            .do(onError: { _ in
                let error: AuthError = serviceType == .kakao ? .kakaoLoginError : .appleLoginError
                SentryManager.capture(error)
            })
    }
    
    func userCheck(_ oauthModel: OAuthAuthenticationModel) -> Observable<OnboardingUserInfo> {
        return authService.userCheck(
            "Bearer \(oauthModel.oauthToken)",
            oauthModel.oauthType.rawValue
        )
        .asObservable()
        .map{ $0.toDomain(false, oauthModel)}
        .catchNetworkAndReturn(of: .notFound, with: .newUser(oauthModel))
        .do(onError: { _ in SentryManager.capture(AuthError.userCheckFail)})
        
    }
    
    func login(_ oauthModel: OAuthAuthenticationModel) -> Observable<FitapatAuthenticationResult> {
        return authService.login(
            "Bearer \(oauthModel.oauthToken)",
            oauthModel.oauthType.rawValue
        )
        .asObservable()
        .do(onError: { _ in SentryManager.capture(AuthError.loginFail)})
    }
    
    func signUp(_ model: OnboardingUserInfo) -> Observable<FitapatAuthenticationResult> {
        return authService.signUp(
            model.oauthModel.oauthType.rawValue,
            "Bearer \(model.oauthModel.oauthToken)",
            model.userInfo.toData(with: model.oauthModel)
        )
        .asObservable()
        .do(onError: { _ in SentryManager.capture(AuthError.signUpFail)})
    }
    
    func saveJWTTokens(_ result: FitapatAuthenticationResult) {
        UserDefaultsManager.zoocAccessToken = result.accessToken
        UserDefaultsManager.zoocRefreshToken = result.refreshToken
    }
}
