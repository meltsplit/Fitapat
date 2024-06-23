//
//  SimpleEasyNotificationRequest.swift
//  ZOOC
//
//  Created by 장석우 on 3/6/24.
//

import Foundation

struct SMSRequest: Encodable {
    let receiver: String
    let msg: String
    
    init(
        code: String,
        receiver: String
    ) {
        self.msg = "[핏어팻] 휴대폰 인증번호 [\(code)]를 입력해주세요."
        self.receiver = receiver
    }
    
}

