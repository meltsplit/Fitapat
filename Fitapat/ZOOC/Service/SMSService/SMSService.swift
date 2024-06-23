//
//  SimpleEasyNotificationService.swift
//  ZOOC
//
//  Created by 장석우 on 3/6/24.
//

import Foundation

import RxSwift
import Moya
import RxMoya


protocol SMSService {
    func sendMessage(_ request: SMSRequest) -> Single<Void>
}

struct DefaultSMSService: SMSService {
    
    private var provider = MoyaProvider<AligoTargetType>(plugins: [MoyaLoggingPlugin()])
    
    func sendMessage(_ request: SMSRequest) -> Single<Void> {
        guard let encodedData = try? JSONEncoder().encode(request)
        else { return Single<Void>.error(AuthError.sendMessageFail) }
        return provider.rx.request(.sendMessage(encodedData))
            .filterSuccessfulStatusCodes()
            .map { _ in ()}
    }
}


struct TestSMSService: SMSService {
    
    func sendMessage(_ request: SMSRequest) -> Single<Void> {
        return Single.just(())
    }
}
