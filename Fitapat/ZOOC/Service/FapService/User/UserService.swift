//
//  UserService.swift
//  ZOOC
//
//  Created by 류희재 on 1/12/24.
//

import Foundation

import Moya
import RxMoya
import RxSwift

protocol UserService {
    func putFCMToken(_ fcmToken: String) -> Single<SimpleResponse>
    func patchUser(_ request: UserInfoRequest) -> Single<SimpleResponse>
    func getTicket() -> Single<Int>
    func getCoupon() -> Single<[CouponResult]>
    func logout() -> Single<Void>
    func deleteAccount() -> Single<Void>
}

struct DefaultUserService { 
    private var provider = MoyaProvider<UserTargetType>(session: Session(interceptor: FapInterceptor.shared),
                                                        plugins: [MoyaLoggingPlugin()])
}

extension DefaultUserService: UserService {
    func putFCMToken(_ fcmToken: String) -> Single<SimpleResponse> {
        provider.rx.request(.patchFCMToken(fcmToken))
            .filterSuccessfulStatusCodes()
            .map(SimpleResponse.self)
    }
    
    func patchUser(_ request: UserInfoRequest) -> Single<SimpleResponse> {
        provider.rx.request(.patchUser(request))
            .filterSuccessfulStatusCodes()
            .map(SimpleResponse.self)
    }
    
    func getTicket() -> Single<Int> {
        provider.rx.request(.getTicket)
            .filterSuccessfulStatusCodes()
            .mapGenericResponse(Int.self)
    }
    
    func getCoupon() -> Single<[CouponResult]> {
        provider.rx.request(.getCoupon)
            .filterSuccessfulStatusCodes()
            .map([CouponResult].self)
    }
    
    func logout() -> Single<Void> {
        provider.rx.request(.logout)
            .filterSuccessfulStatusCodes()
            .map { _ in ()}
            
    }
    
    func deleteAccount() -> Single<Void> {
        provider.rx.request(.deleteAccount)
            .filterSuccessfulStatusCodes()
            .map { _ in ()}
    }
}



