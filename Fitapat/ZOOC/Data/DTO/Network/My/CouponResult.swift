//
//  CouponResult.swift
//  ZOOC
//
//  Created by 류희재 on 5/13/24.
//

import Foundation

struct CouponResult: Codable {
    let id: Int
    let code, name: String
    let amount: Int
    let registrationDeadline: String?
    let useRequirementAmount: Int?
    let useDeadline: String?
}
