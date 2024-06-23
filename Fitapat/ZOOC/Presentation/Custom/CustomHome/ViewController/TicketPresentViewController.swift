//
//  TicketPresentView.swift
//  ZOOC
//
//  Created by 류희재 on 3/21/24.
//

import UIKit

import SnapKit
import Then
import RxSwift
import Lottie

protocol TicketPresentViewControllerDelegate: AnyObject {
    func useTicketButtonDidTap()
}

final class TicketPresentViewController : UIViewController {
    
    //MARK: - Properties
    
    unowned let delegate: TicketPresentViewControllerDelegate
    private let disposeBag = DisposeBag()
    
    //MARK: - UI Components
    
    private let xButton = UIButton()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private let celebrateAnimationView = LottieAnimationView(name: "confetti")
    private let giftAnimationView = LottieAnimationView(name: "giftBox")
    
    private let useTicketButton = UIButton()
    
    
    //MARK: - Life Cycle
    
    init(delegate: TicketPresentViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style()
        hierarchy()
        layout()
        bindUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        giftAnimationView.play()
        celebrateAnimationView.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        celebrateAnimationView.stop()
        giftAnimationView.stop()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    
    //MARK: - Custom Method
    
    private func style() {
        view.do {
            $0.backgroundColor = .black.withAlphaComponent(0.8)
        }
        
        titleLabel.do {
            $0.text = "셀프 AI 티켓을 10장 선물해드릴게요!"
            $0.font = .zw_head1
            $0.textColor = .zw_white
            $0.textAlignment = .center
        }
        
        descriptionLabel.do {
            $0.font = .zw_Body2
            $0.textColor = .zw_background
            $0.text = "직접 만든 캐릭터로 반려동물에 적용해보세요"
            $0.textAlignment = .center
        }
        
        xButton.do {
            $0.setImage(.icExit.withTintColor(.zw_white), for: .normal)
        }
        
        celebrateAnimationView.do {
            $0.contentMode = .scaleAspectFit
            $0.loopMode = .loop
            $0.animationSpeed = 1.0
        }
        
        giftAnimationView.do {
            $0.contentMode = .scaleAspectFit
            $0.loopMode = .loop
            $0.animationSpeed = 1.0
        }
        
        useTicketButton.do {
            $0.backgroundColor = .white
            $0.setTitle("티켓 사용하러 가기", for: .normal)
            $0.setTitleColor(.zw_point, for: .normal)
            $0.titleLabel?.font = .zw_Subhead3
            $0.titleLabel?.textAlignment = .center
        }
    }
    
    private func hierarchy() {
        view.addSubviews(
            xButton,
            titleLabel,
            descriptionLabel,
            celebrateAnimationView,
            giftAnimationView,
            useTicketButton
        )
    }
    
    private func layout() {
        xButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(58)
            $0.trailing.equalToSuperview().inset(28)
            $0.size.equalTo(36)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(212)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        celebrateAnimationView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(260)
        }
        
        giftAnimationView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(12)
            $0.size.equalTo(414)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(122)
        }
        
        useTicketButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(180)
            $0.horizontalEdges.equalToSuperview().inset(87)
            $0.height.equalTo(51)
        }
    }
    
    private func bindUI() {
        xButton.rx.tap
            .asDriver(onErrorJustReturn: Void())
            .drive(with: self, onNext: { owner, _ in
                owner.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
        useTicketButton.rx.tap
            .asDriver(onErrorJustReturn: Void())
            .drive(with: self, onNext: { owner, _ in
                owner.dismiss(animated: false)
                owner.delegate.useTicketButtonDidTap()
            }).disposed(by: disposeBag)
    }
}

