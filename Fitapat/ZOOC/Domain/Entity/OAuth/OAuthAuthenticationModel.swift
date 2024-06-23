//
//  OAuthAuthenticationModel.swift
//  ZOOC
//
//  Created by 류희재 on 1/8/24.
//

import Foundation

struct OAuthAuthenticationModel {
    var oauthType: OAuthProviderType
    var oauthToken: String
    var name: String?
    var phoneNumber: String?
}

extension OAuthAuthenticationModel {
    func toData(_ markting: Bool) -> UserInfoRequest {
        return .init(agreement: .init(marketing: markting), 
                     name: name,
                     phone: phoneNumber)
    }
}
