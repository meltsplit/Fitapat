//
//  PhotoAuthService.swift
//  ZOOC
//
//  Created by 장석우 on 4/10/24.
//
//


import PhotosUI

import RxSwift
import RxRelay

// case notDetermined = 0 // User has not yet made a choice with regards to this application
// case restricted = 1 // This application is not authorized to access photo data.
// case denied = 2 // User has explicitly denied this application access to photos data.
// case authorized = 3 // User has authorized this application to access photos data.
// case limited = 4

//    .notDetermined : 사용자가 앱의 라이브러리 권한을 아무것도 설정하지 않은 경우 입니다.
//    .restricted : 사용자를 통해 권한을 부여 받는 것이 아니지만 라이브러리 권한에 제한이 생긴 경우 입니다. 사진을 얻어 올 수 없습니다
//    .denied : 사용자가 접근을 거부한 것입니다. 사진을 얻어 올 수 없습니다 🥲
//   (우리가 원하는 접근 권한) .authorized : 사용자가 앱에게 라이브러리를 사용할 수 있도록 권한을 설정한 경우 입니다.
//    .limited : (iOS 14+) 사용자가 제한된 접근 권한을 부여한 경우 입니다.


protocol PhotoAuthService {
    var canFullAccessPhotoLibrary: Bool { get }
    func requestAuthorization() -> Observable<Bool>
}

extension PhotoAuthService {
    fileprivate func goToSetting() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url) else { return }
            
        UIApplication.shared.open(url, completionHandler: nil)
    }
}

final class DefaultPhotoAuthService: PhotoAuthService {

    private var authorizationStatus: PHAuthorizationStatus {
        PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    var canFullAccessPhotoLibrary: Bool {
        authorizationStatus == .authorized
    }
    
    func requestAuthorization() -> Observable<Bool> {
        return Observable<Bool>.create { [weak self] observer in
     
            guard let self else { return Disposables.create() }
     
            DispatchQueue.main.async {
                switch self.authorizationStatus {
                case .authorized:
                    observer.onNext(true)
                    observer.onCompleted()
                case .notDetermined:
                    PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                        switch status {
                        case .authorized:
                            observer.onNext(true)
                            observer.onCompleted()
                        default:
                            observer.onNext(false)
                            observer.onCompleted()
                        }
                    }
                default:
                    self.goToSetting()
                    observer.onNext(false)
                    observer.onCompleted()
                }
            }

            return Disposables.create()
        }
    }

}
