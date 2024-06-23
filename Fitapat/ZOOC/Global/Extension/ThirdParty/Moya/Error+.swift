//
//  Error.swift
//  ZOOC
//
//  Created by 장석우 on 3/19/24.
//

import Foundation
import Moya

extension Error {
    
    func toNetworkServiceError() -> NetworkServiceError {
        guard let error = self as? MoyaError,
              let response = error.response else { return .unknownError }
        
        let decodedData = try? JSONDecoder().decode(SimpleResponse.self, from: response.data)
        let fapStatus = decodedData?.status
        
        guard let fapStatus else { return NetworkServiceError(rawValue: response.statusCode) ?? .unknownError}
        return NetworkServiceError(rawValue: fapStatus) ?? .unknownError
    }
}
