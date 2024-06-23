//
//  UserDefaultKeyList.swift
//  ZOOC
//
//  Created by 장석우 on 2023/04/26.
//

import Foundation

enum UserDefaultKeys: String, CaseIterable {
    case fcmToken
    case zoocAccessToken
    case zoocRefreshToken
    case userNameAndPhoneLast
    case isFirstAttemptCustom
    case neverShowTutorial
}

struct UserDefaultsManager {
    
    @UserDefaultWrapper<String>(key: UserDefaultKeys.fcmToken.rawValue, defaultValue: "none")
    static var fcmToken: String
    
    @UserDefaultWrapper<String>(key: UserDefaultKeys.zoocAccessToken.rawValue, defaultValue: "")
    static var zoocAccessToken: String
    
    @UserDefaultWrapper<String>(key: UserDefaultKeys.zoocRefreshToken.rawValue, defaultValue: "")
    static var zoocRefreshToken: String
    
    @UserDefaultWrapper<String>(key: UserDefaultKeys.userNameAndPhoneLast.rawValue, defaultValue: "이름없음")
    static var userNameAndPhoneLast: String
    
    @UserDefaultWrapper<Bool>(key: UserDefaultKeys.isFirstAttemptCustom.rawValue, defaultValue: false)
    static var isFirstAttemptCustom: Bool
    
    @UserDefaultWrapper<Bool>(key: UserDefaultKeys.neverShowTutorial.rawValue, defaultValue: false)
    static var neverShowTutorial: Bool
    
}

extension UserDefaultsManager {
    
    static func setUserInfo(_ data: UserInfo) {
        let name = data.name ?? "이름없음"
        let phoneLast = data.phone?.suffix(4) ?? "번호없음"
        let nameWithPhone = name + "_" + phoneLast
        UserDefaultsManager.userNameAndPhoneLast = nameWithPhone
    }
    
    static func reset() {
        
        UserDefaultKeys.allCases.forEach { key in
            guard key != .fcmToken else { return  }
            guard key != .neverShowTutorial else { return  }
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
    }
}

