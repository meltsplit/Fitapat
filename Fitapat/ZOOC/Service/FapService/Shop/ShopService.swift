//
//  ShopService.swift
//  ZOOC
//
//  Created by 장석우 on 11/22/23.
//

import Foundation

import Moya
import RxMoya
import RxSwift

protocol ShopService {
    func getPopularProducts() -> Single<[PopularProductsDTO]>
}

struct DefaultShopService { 
    private var provider = MoyaProvider<ShopTargetType>(session: Session(interceptor: FapInterceptor.shared),
                                                        plugins: [MoyaLoggingPlugin()])
}

extension DefaultShopService: ShopService {
    
    func getPopularProducts() -> RxSwift.Single<[PopularProductsDTO]> {
        provider.rx.request(.getPopularProducts)
            .filterSuccessfulStatusCodes()
            .map([PopularProductsDTO].self)
    }
   
}
