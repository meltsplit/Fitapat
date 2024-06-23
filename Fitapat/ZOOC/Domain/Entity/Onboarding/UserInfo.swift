//
//  OnboardingRequest.swift
//  ZOOC
//
//  Created by 장석우 on 3/7/24.
//

import Foundation

struct UserInfo {
    var phone: String?
    var name: String?
    var marketing: Bool?
    
    
    func toData(with oAuthModel: OAuthAuthenticationModel) -> UserInfoRequest {
        guard let marketing else { return .init(agreement: nil,
                                                name: name ?? oAuthModel.name,
                                                phone: phone ?? oAuthModel.phoneNumber)
        }
        
        return UserInfoRequest(agreement: AgreementRequest(marketing: marketing) ,
                               name: name ?? oAuthModel.name,
                               phone: phone ?? oAuthModel.phoneNumber)
    }
}
