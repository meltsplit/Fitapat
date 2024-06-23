////
////  DependencyContainer.swift
////  ZOOC
////
////  Created by 류희재 on 5/19/24.
////
//
//import Foundation
//import Swinject
//
//struct DependencyContainer {
//    fileprivate static let container: Container = {
//        return DependencyContainer.getContainer()
//    }()
//    
//    fileprivate static func getContainer() -> Container {
//        let container = Container()
//        
//        // MARK: MyController
//        container.register(AuthService.self) { _ in DefaultAuthService() }
//        container.register(UserService.self) { _ in DefaultUserService() }
//        container.register(RealmService.self) { _ in DefaultRealmService() }
//        container.register(SMSService.self) { _ in DefaultSMSService() }
//        
//        container.register(AuthRepository.self) { r in DefaultAuthRepository(authService: r.resolve(AuthService.self)!, realmService: r.resolve(RealmService.self)!, smsService: r.resolve(SMSService.self)!) }
//        
//        container.register(UserRepository.self) { r in DefaultUserRepository(userService: r.resolve(UserService.self)!, realmService: r.resolve(RealmService.self)!) }
//        
//        container.register(MyUseCase.self) { r in DefaultMyUseCase(petRepository: DefaultPetRepository.shared, authRepository: r.resolve(AuthRepository.self)!, userRepository: r.resolve(UserRepository.self)!) }
//        
//        container.register(MyViewModel.self) { r in MyViewModel(myUseCase: r.resolve(MyUseCase.self)!) }
//        
//        container.register(MyViewController.self) { r in MyViewController(viewModel: r.resolve(MyViewModel.self)!)
//        }
//    }
//}
//        
////    static func resolve<Service>(_ serviceType: Service.Type) -> Service {
////        return DependencyContainer.container.resolve(serviceType)!
////    }
////    
////    static func resolve<Service, Argument>(_ serviceType: Service.Type, _ argument: Argument) -> Service {
////        return DependencyContainer.container.resolve(serviceType, argument: argument)!
////    }
// 
