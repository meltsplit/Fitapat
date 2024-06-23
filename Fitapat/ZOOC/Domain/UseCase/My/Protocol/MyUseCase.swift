//
//  MyUseCase.swift
//  ZOOC
//
//  Created by 류희재 on 2023/09/25.
//

import Foundation

import RxSwift
import RxCocoa

protocol MyUseCase {
    var logoutFail: PublishRelay<String> { get }
    var deleteAccountFail: PublishRelay<String> { get }
    
    func requestPetData() -> Observable<PetResult?>
    func requestTicketCnt() -> Observable<Int>
    func requestCouponCnt() -> Observable<Int>
    func logout() -> Observable<Void>
    func deleteAccount() -> Observable<Void>
}
