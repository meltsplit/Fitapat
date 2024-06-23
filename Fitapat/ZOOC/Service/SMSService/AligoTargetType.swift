//
//  SENTargetType.swift
//  ZOOC
//
//  Created by 장석우 on 3/6/24.
//

import Foundation
import Moya

enum AligoTargetType {
    case sendMessage(_ request: Data)
}

extension AligoTargetType: BaseTargetType {
    var path: String {
        switch self {
        case .sendMessage:
            return "/sms"
        }
        
    }
    
    var method: Moya.Method {
        switch self {
        case .sendMessage:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .sendMessage(let request):
            return .requestCompositeData(bodyData: request, 
                                         urlParameters: ["provider" : "aligo"])
        }
    }
    
    var headers: [String : String]? {
        return APIConstants.noTokenHeader
    }
    
    
}

