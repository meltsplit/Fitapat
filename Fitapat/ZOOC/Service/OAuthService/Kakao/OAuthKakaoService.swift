//
//  OAuthKakaoService.swift
//  ZOOC
//
//  Created by 장석우 on 12/19/23.
//

import Foundation

import RxSwift
import RxCocoa

import RxKakaoSDKAuth
import RxKakaoSDKUser

import KakaoSDKAuth
import KakaoSDKUser

final class OAuthKakaoService: OAuthServiceType {
    
    let disposeBag = DisposeBag()
    
    func authorize() -> Single<OAuthAuthenticationModel> {
        return login().map { OAuthAuthenticationModel(oauthType: .kakao, 
                                                      oauthToken: $0.0.accessToken,
                                                      name: $0.1 ?? "고객",
                                                      phoneNumber: $0.2?.replacingOccurrences(of: "+82 ", with: "0")
            .replacingOccurrences(of: "-", with: "")
        )
        }
    }
    
    func login() -> Single<(OAuthToken, String?, String?)> {
        let isKakaoTalkLoginAvailable = UserApi.isKakaoTalkLoginAvailable()
        var oAuthToken: OAuthToken?
        return Single.create { observer in
            if isKakaoTalkLoginAvailable {
                UserApi.shared.rx.loginWithKakaoTalk()
                    .do (onNext: { oAuthToken = $0 })
                    .map { _ in (nil, true) }
                    .flatMap(UserApi.shared.rx.me)
                    .subscribe(onNext: { user in
                        if let oAuthToken {
                            observer(.success((oAuthToken,
                                               user.kakaoAccount?.name,
                                               user.kakaoAccount?.phoneNumber
                                              )))
                        } else {
                            observer(.failure(AuthError.kakaoLoginError))
                        }
                    }, onError: { error in
                        observer(.failure(AuthError.kakaoLoginError))
                    })
                    .disposed(by: self.disposeBag)
            } else {
                UserApi.shared.rx.loginWithKakaoAccount()
                    .do (onNext: { oAuthToken = $0 })
                    .map { _ in (nil, true) }
                    .flatMap(UserApi.shared.rx.me)
                    .subscribe(onNext: { user in
                        if let oAuthToken {
                            observer(.success((oAuthToken,
                                               user.kakaoAccount?.name,
                                               user.kakaoAccount?.phoneNumber)))
                        } else {
                            observer(.failure(AuthError.kakaoLoginError))
                        }
                    }, onError: { error in
                        observer(.failure(AuthError.kakaoLoginError))
                    })
                    .disposed(by: self.disposeBag)
            }
            
            return Disposables.create()
        }
    }
    
    deinit {
        print("죽음")
    }
}
