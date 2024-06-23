//
//  OnboardingEntity.swift
//  ZOOC
//
//  Created by 장석우 on 3/7/24.
//

import Foundation

struct OnboardingUserInfo {
    let isFirstUser: Bool
    let oauthModel: OAuthAuthenticationModel
    var userInfo: UserInfo
    
    static func newUser(_ oauthModel: OAuthAuthenticationModel) -> OnboardingUserInfo {
        return OnboardingUserInfo(isFirstUser: true,
                                  oauthModel: oauthModel,
                                  userInfo: .init(phone: oauthModel.phoneNumber,
                                                  name: oauthModel.name,
                                                  marketing: nil))
    }
    
    static func unknown() -> OnboardingUserInfo {
        return .init(isFirstUser: false, 
                     oauthModel: .init(oauthType: .kakao, oauthToken: "", name: ""),
                     userInfo: .init())
    }
}


