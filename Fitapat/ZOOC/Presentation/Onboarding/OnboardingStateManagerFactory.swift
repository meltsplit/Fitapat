//
//  OnboardingManager.swift
//  ZOOC
//
//  Created by 장석우 on 3/8/24.
//

import Foundation

typealias OnboardingStateManager = OnboardingActionSelector & OnboardingNavigationState

struct OnboardingStateManagerFactory {
    
    static func create(_ model: OnboardingUserInfo) -> OnboardingStateManager {
        
        let fapName = model.userInfo.name
        let fapPhone = model.userInfo.phone
        let socialName = model.oauthModel.name
        let socialPhone = model.oauthModel.phoneNumber
        
        guard !model.isFirstUser else {
            if socialPhone == nil {
                return SignUpNeedPhoneState()
            } else {
                return SignUpNotNeedState()
            }
        }
        
        if (fapPhone == nil && socialPhone == nil) {
            return SignInNeedPhoneState()
        } else if (fapName == nil && socialName != nil) || (fapPhone == nil && socialPhone != nil)
        {
            return SignInUpdateWithSocialInfoState()
        } else {
            return SignInJustState()
        }
    }
}





//        if model.isFirstUser  {
//            if name == nil && phone == nil {
//                return SignUpNeedBothState()
//            } else if name == nil {
//                return SignUpNeedNameState()
//            } else if phone == nil {
//                return SignUpNeedPhoneState()
//            } else {
//                return SignUpNotNeedState()
//            }
//        } else {
//            if name == nil && phone == nil {
//                return SignInNeedBothState()
//            } else if name == nil {
//                if model.oauthModel.name != nil {
//                    return SignInNeedNameButNameState()
//                } else {
//                    return SignInNeedNameState()
//                }
//
//            } else if phone == nil {
//                if model.oauthModel.phoneNumber != nil {
//                    return SignInNeedPhoneButPhoneState()
//                } else {
//                    return SignInNeedPhoneState()
//                }
//            } else {
//                return SignInNotNeedState()
//            }
//        }
