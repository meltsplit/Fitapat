//
//  OAuthAppleService.swift
//  ZOOC
//
//  Created by 류희재 on 12/19/23.
//

import UIKit

import AuthenticationServices
import RxSwift

final class OAuthAppleService: OAuthServiceType  {
    
    func authorize() -> Single<OAuthAuthenticationModel> {
        return login().map { OAuthAuthenticationModel(oauthType: .apple,
                                                      oauthToken: $0.0,
                                                      name: $0.1,
                                                      phoneNumber: nil
        ) }
    }
    
    private let disposeBag = DisposeBag()
    private let appleLoginManager = AppleLoginManager()
    
    internal func login() -> Single<(String, String?)> {
        return Single.create { observer in
            self.appleLoginManager
                .handleAuthorizationAppleIDButtonPress()
                .subscribe(onNext: { result in
                    guard
                        let credential = result.credential as? ASAuthorizationAppleIDCredential,
                        let idToken = credential.identityToken
                    else { return }
                    var name: String? = nil
                    
                    if let fullName = credential.fullName,
                       let familyName = fullName.familyName,
                       let givenName = fullName.givenName
                    {
                        name = familyName + givenName
                        KeychainManager.saveUsername(name)
                    }
                    
                    dump(credential.fullName)
                    dump(credential.fullName?.familyName)
                    dump(credential.fullName?.givenName)
                    print("🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏")
                    print(KeychainManager.readUsername())
                    print("🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏")
                    
                    let idTokenString = String(data: idToken, encoding: .utf8)!
                    observer(.success((idTokenString, name)))
                }, onError: { error in
                    observer(.failure(AuthError.appleLoginError))
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
}
