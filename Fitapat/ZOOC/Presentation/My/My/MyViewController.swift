//
//  MyViewController.swift
//  ZOOC
//
//  Created by 장석우 on 2022/12/25.
//

import UIKit

import RxSwift
import RxCocoa
import RxGesture

final class MyViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let viewModel: MyViewModel
    private let disposeBag = DisposeBag()
    
    private let deleteAccountSubject = PublishSubject<Void>()
    
    init(viewModel: MyViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Components
    
    private lazy var rootView = MyView()
    
    //MARK: - Life Cycle
    
    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindUI()
        bindViewModel()
    }
    
    //MARK: - Custom Method
    
    private func bindUI() {
        rootView.profileView.editProfileButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                owner.pushToEditProfileView()
            }).disposed(by: disposeBag)
        
        rootView.couponView.rx.tapGesture()
            .when(.recognized)
            .subscribe(with: self, onNext: { owner, _ in
                owner.pushToCouponWebView()
            }).disposed(by: disposeBag)
        
        rootView.ticketView.rx.tapGesture()
            .when(.recognized)
            .map { _ in "내가 커스텀 AI 캐릭터를 만들 수 있는 잔여 횟수예요\n만든 캐릭터로 커스텀 제품을 구매하면 10장을 더 드려요" }
            .bind(onNext: presentToast)
            .disposed(by: disposeBag)
        
        rootView.deleteAccountButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                owner.presentDeleteAccountZoocAlertView()
            }).disposed(by: disposeBag)
        
        rootView.settingView.rx.itemSelected.subscribe(with: self, onNext: { owner, index in
            switch index.row {
            case 0: owner.pushToOrderHistoryView()
            case 1: owner.pushToNoticeSettingView()
            case 2:
                let url = ExternalURL.fapInstagram
                let webVC = DIContainer.shared.makeWebVC(url: url)
                owner.present(webVC,animated: true)
            case 3:
                let url = ExternalURL.fapChannelTalk
                let webVC = DIContainer.shared.makeWebVC(url: url)
                owner.present(webVC,animated: true)
            case 4: owner.pushToAppInformationView()
            default:
                break
            }
        }).disposed(by: disposeBag)
        
    }
    private func bindViewModel() {
        let input = MyViewModel.Input(
            viewWillAppearEvent: self.rx.viewWillAppear.asObservable(), 
            registerButtonDidTapEvent: self.rootView.noProfileView.registerPetButton.rx.tap.asObservable(),
            logoutButtonDidTapEvent: self.rootView.settingView.rx.itemSelected.asObservable()
                .filter({ $0.item == 5 })
                .map{_ in ()},
            deleteAccountButtonDidTapEvent: deleteAccountSubject.asObservable()
        )
        
        let output = self.viewModel.transform(from: input, disposeBag: self.disposeBag)
        
        output.profileData
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self, onNext: { owner, profile in
                owner.rootView.updateUI(profile)
            }).disposed(by: disposeBag)
        
        output.ticketCnt
            .asDriver(onErrorJustReturn: Int())
            .drive(with: self, onNext: { owner, ticketCnt in
                owner.rootView.updateUI(ticketCnt: ticketCnt)
            }).disposed(by: disposeBag)
        
        output.couponCnt
            .asDriver(onErrorJustReturn: Int())
            .drive(with: self, onNext: { owner, couponCnt in
                owner.rootView.updateUI(coupontCnt: couponCnt)
            }).disposed(by: disposeBag)
        
        output.logoutSuccess
            .asDriver(onErrorJustReturn: Void())
            .drive(with: self, onNext: { owner, _ in
                let onboardingNVC = UINavigationController(
                    rootViewController: DIContainer.shared.makeLoginVC()
                )
                UIApplication.shared.changeRootViewController(onboardingNVC)
            }).disposed(by: disposeBag)
        
        output.deleteAccountSuccess
            .asDriver(onErrorJustReturn: Void())
            .drive(with: self, onNext: { owner, isDeleted in
                let onboardingNVC = UINavigationController(
                    rootViewController: DIContainer.shared.makeLoginVC()
                )
                UIApplication.shared.changeRootViewController(onboardingNVC)
            }).disposed(by: disposeBag)
        
        output.pushToRegisterVC
            .asDriver(onErrorJustReturn: Void())
            .drive(onNext: pushToRegisterPetView)
            .disposed(by: disposeBag)
    }
}

//MARK: Flow Login
extension MyViewController {
    
    private func pushToOrderHistoryView() {
        let webVC = DIContainer.shared.makeFapWebVC(path: "/mypage/orderlist")
        webVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    private func pushToEditProfileView() {
        let editProfileVC = MyEditProfileViewController(
            viewModel: MyEditProfileViewModel(
                myEditProfileUseCase: DefaultMyEditProfileUseCase(
                    petRepository: DefaultPetRepository.shared
                )
            )
        )
        editProfileVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(editProfileVC, animated: true)
    }

    private func pushToCouponWebView() {
        let webVC = DIContainer.shared.makeFapWebVC(path: "/mypage/coupon")
        webVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    private func pushToAppInformationView() {
        let appInformationVC = MyAppInformationViewController()
        appInformationVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(appInformationVC, animated: true)
    }
    
    private func pushToNoticeSettingView() {
        let noticeVC = MyNoticeViewController()
        noticeVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(noticeVC, animated: true)
    }
    
    private func pushToRegisterPetView() {
        let registerPetVC = MyRegisterPetViewController(
            petRepository: DefaultPetRepository.shared
        )
        registerPetVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(registerPetVC, animated: true)
    }
    
    private func presentDeleteAccountZoocAlertView() {
        let zoocAlertVC = FapAlertViewController(.deleteAccount)
        zoocAlertVC.delegate = self
        present(zoocAlertVC, animated: false)
    }
}


extension MyViewController: FapAlertViewControllerDelegate {
    func leftButtonDidTap(_ alertType: FapAlertType) {
        deleteAccountSubject.onNext(())
    }
    
    func rightButtonDidTap(_ alertType: FapAlertType) {
        self.dismiss(animated: true)
    }
}
