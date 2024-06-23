//
//  NetworkError.swift
//  ZOOC
//
//  Created by 장석우 on 11/21/23.
//

import Foundation

public enum NetworkServiceError: Int, Error, CustomStringConvertible {
    
    
    //MARK: - Request Error
    
    case invalidURLError
    case payloadEncodingError
    
    //MARK: - Response Error
    
    case badRequest = 400 // 클라이언트가 올바르지 못한 요청을 보내고 있음을 의미
    case unauthorized = 401 // 로그인을 하지 않아 권한이 없음. 권한 인증 요구
    case forbidden = 403  // 요청이 서버에 의해 거부 되었음을 의미. 금지된 페이지
    case notFound = 404  // 요청한 URL을 찾을 수 없음을 의미
    case methodNotAllowed = 405
    case notAcceptable = 406    // ACCSS TOKEN 과 refresh token 이 모두 만료됨
    case requestTimeOut = 408
    case conflicted = 409 // 클라이언트 요청에 대해 서버에서 충돌 요소가 발생 할수 있음을 의미
    
    case internalServerError = 500  // 서버에 오류가 발생하여 응답 할 수 없음을 의미
    case notImplemented = 501
    case badGateway = 502
    case serviceUnavailable = 503  // 현재 서버가 유지보수 등의 이유로 일시적인 사용 불가함을 의미
    
    //MARK: - Fitapat Response Error
    
    case badImageExtension = 4001
    case tokenExpired = 4002
    case noToken = 4003
    case notEnoughTicket = 4004
    
    case unknownError
    case responseDecodingError
    case emptyDataError
    
    public var description: String { self.errorDescription }
    var errorDescription: String {
        switch self {
        case .invalidURLError: return "INVALID_URL_ERROR"
        case .badRequest: return "400:INVALID_REQUEST_ERROR"
        case .unauthorized: return "401:AUTHENTICATION_FAILURE_ERROR"
        case .forbidden: return "403:FORBIDDEN_ERROR"
        case .notFound: return "404:NOT_FOUND_ERROR"
        case .methodNotAllowed: return "405:NOT_ALLOWED_HTTP_METHOD_ERROR"
        case .requestTimeOut: return "408:TIMEOUT_ERROR"
        case .internalServerError: return "500:INTERNAL_SERVER_ERROR"
        case .notImplemented: return "501:NOT_SUPPORTED_ERROR"
        case .badGateway: return "502:BAD_GATEWAY_ERROR"
        case .serviceUnavailable: return "503:INVALID_SERVICE_ERROR"
        case .responseDecodingError: return "RESPONSE_DECODING_ERROR"
        case .payloadEncodingError: return "REQUEST_BODY_ENCODING_ERROR"
        case .unknownError: return "UNKNOWN_ERROR"
        case .emptyDataError: return "RESPONSE_DATA_EMPTY_ERROR"
        case .notAcceptable: return "notAcceptable"
        case .badImageExtension: return "badImageExtension"
        case .tokenExpired: return "tokenExpired"
        case .noToken: return "noToken"
        case .notEnoughTicket: return "notEnoughTicket"
        case .conflicted: return "conflicted"
        }
    }


}
