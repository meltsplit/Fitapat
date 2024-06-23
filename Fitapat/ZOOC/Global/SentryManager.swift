//
//  FapSentry.swift
//  ZOOC
//
//  Created by 장석우 on 3/19/24.
//

import Foundation

import Sentry

struct SentryManager {
    
    static func start() {
        SentrySDK.start { options in
            options.dsn = Config.sentryDSN
            options.debug = false
            #if RELEASE
            options.environment = "production"
            #elseif DEBUG
            options.environment = "debug"
            #endif
            
            options.enableCaptureFailedRequests = true
            options.attachScreenshot = true
            options.enableUserInteractionTracing = true
            options.attachViewHierarchy = true
            options.enableUIViewControllerTracing = true
            options.enableNetworkBreadcrumbs = true
            let httpStatusCodeRange = HttpStatusCodeRange(min: 400, max: 599)
            options.failedRequestStatusCodes = [ httpStatusCodeRange ]
            options.enableAutoBreadcrumbTracking = true
        }
    }
    
    static func resetUser() {
        SentrySDK.setUser(User())
    }
    
    
    static func setUser() {
        let nameWithPhone = UserDefaultsManager.userNameAndPhoneLast
        let pet = DefaultPetRepository.shared.petResult?.name ?? "펫 없음"
        let at = UserDefaultsManager.zoocAccessToken
        let rt = UserDefaultsManager.zoocRefreshToken
        
        let user = User(userId: nameWithPhone)
        user.username = pet
        user.data = [
            "accessToken" : at,
            "refreshToken" : rt
        ]
        
        SentrySDK.setUser(user)
    }
    
    static func capture(_ error: Error) {
        SentrySDK.capture(error: error)
    }
    
}
