//
//  AuthError.swift
//  ZOOC
//
//  Created by 장석우 on 2023/05/20.
//

import Foundation

enum AuthError: BaseDataError {
    case userCheckFail
    case loginFail
    case signUpFail
    
    case tokenExpired
    case kakaoLoginError
    case appleLoginError
    case encodedFail
    case notExistedUser
    case sendMessageFail
    case unknown(_ error: String?)
}
