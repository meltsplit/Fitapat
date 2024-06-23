//
//  MyView.swift
//  ZOOC
//
//  Created by 류희재 on 2023/01/01.
//

import UIKit

import SnapKit
import Then

final class MyView: UIView  {
    
    //MARK: - UI Components
    
    internal var scrollView = UIScrollView()
    private let contentView = UIView()
    internal let profileView = MyProfileView()
    internal let noProfileView = MyNoProfileView()
    
    internal let ticketView = UIView()
    private let ticketIcon = UIImageView(image: .icTicket)
    private let ticketTitleLabel = UILabel()
    private let numberOfTicketLabel = UILabel()
    
    internal let couponView = UIView()
    private let couponIcon = UIImageView(image: .icPercent)
    private let couponTitleLabel = UILabel()
    private let numberOfCouponLabel = UILabel()
    
    internal let settingView = MySettingView()
    internal let deleteAccountButton = UIButton()
    
    //MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        style()
        hierarchy()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        settingView.snp.remakeConstraints {
            $0.top.equalTo(ticketView.snp.bottom).offset(12)
            $0.leading.trailing.equalTo(profileView)
            $0.height.equalTo(settingView.contentSize.height)
        }
    }
    
    //MARK: - Custom Method
    
    private func style() {
        self.backgroundColor = .zw_background
        scrollView.do {
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
        }
        deleteAccountButton.do {
            $0.setTitle("회원탈퇴", for: .normal)
            $0.titleLabel?.font = .zw_caption
            $0.titleLabel?.textAlignment = .left
            $0.setTitleColor(.zw_lightgray, for: .normal)
            $0.setUnderline()
        }
        profileView.isHidden = true
        
        couponView.do {
            $0.backgroundColor = .clear
            $0.makeCornerRound(radius: 4)
            $0.setBorder(width: 1, color: .zw_brightgray)
        }
        
        couponTitleLabel.do {
            $0.text = "쿠폰함"
            $0.font = .zw_Subhead4
            $0.textColor = .zw_black
            $0.textAlignment = .center
        }
        
        numberOfCouponLabel.do {
            $0.text = "0개"
            $0.font = .zw_Body2
            $0.textColor = .zw_black
            $0.textAlignment = .center
        }
        
        ticketView.do {
            $0.backgroundColor = .zw_background
            $0.makeCornerRound(radius: 4)
            $0.setBorder(width: 1, color: .zw_brightgray)
        }
        
        ticketTitleLabel.do {
            $0.text = "셀프 AI 티켓"
            $0.font = .zw_Subhead4
            $0.textColor = .zw_black
            $0.textAlignment = .center
        }
        
        numberOfTicketLabel.do {
            $0.text = "개"
            $0.font = .zw_Body2
            $0.textColor = .zw_black
            $0.textAlignment = .center
        }
    }
    
    private func hierarchy() {
        self.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubviews(
            profileView,
            noProfileView,
            couponView,
            ticketView,
            settingView,
            deleteAccountButton
        )
        
        couponView.addSubviews(couponIcon, couponTitleLabel, numberOfCouponLabel)
        ticketView.addSubviews(ticketIcon, ticketTitleLabel, numberOfTicketLabel)
    }
    
    private func layout() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
            $0.height.equalTo(scrollView.frameLayoutGuide).priority(.low)
        }
        
        profileView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.leading.trailing.equalToSuperview().inset(28)
        }
        
        noProfileView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.leading.trailing.equalToSuperview().inset(28)
        }
        
        couponView.snp.makeConstraints {
            $0.top.equalTo(noProfileView.snp.bottom).offset(9)
            $0.horizontalEdges.equalTo(profileView)
            $0.height.equalTo(68)
        }
        
        couponIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(19)
        }
        
        couponTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(couponIcon.snp.trailing).offset(4)
            $0.centerY.equalToSuperview()
        }
        
        numberOfCouponLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.centerY.equalToSuperview()
        }
        
        //TODO: - 기능 없는 쿠폰뷰는 심사 반려될 것 같아서 주석 처리 할게요. (웹뷰 연동시 해당 주석을 해제해주세요.) 24.05.14
        ticketView.snp.makeConstraints {
            $0.top.equalTo(couponView.snp.bottom).offset(8)
            $0.horizontalEdges.equalTo(couponView)
            $0.height.equalTo(68)
        }
        
        //TODO: - 기능 없는 쿠폰뷰는 심사 반려될 것 같아서 레이아웃 다시잡았어요. (웹뷰 연동시 해당 코드를 삭제해주세요.) 24.05.14
//        ticketView.snp.makeConstraints {
//            $0.edges.equalTo(couponView)
//        }
        
        ticketIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(19)
        }
        
        ticketTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(ticketIcon.snp.trailing).offset(4)
            $0.centerY.equalToSuperview()
        }
        
        numberOfTicketLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.centerY.equalToSuperview()
        }
        
        settingView.snp.makeConstraints {
            $0.top.equalTo(ticketView.snp.bottom).offset(12)
            $0.horizontalEdges.equalTo(profileView)
            $0.height.greaterThanOrEqualTo(62 * 6)
        }
        
        deleteAccountButton.snp.makeConstraints {
            $0.top.equalTo(settingView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(32)
            $0.bottom.equalToSuperview().inset(100)
        }
    }
}

extension MyView {
    func updateUI(_ profile: PetResult?) {
        
        noProfileView.isHidden = profile != nil
        profileView.isHidden = profile == nil
        updateLayout(profile != nil)
        guard let profile else { return }
        
        profileView.dataBind(profile)
    }
    
    func updateUI(ticketCnt: Int) {
        numberOfTicketLabel.text = "\(ticketCnt)개"
    }
    
    func updateUI(coupontCnt: Int) {
        numberOfCouponLabel.text = "\(coupontCnt)개"
    }
    
    private func updateLayout(_ haveProfile: Bool) {
        let targetView: UIView = haveProfile ? profileView : noProfileView
        couponView.snp.remakeConstraints {
            $0.top.equalTo(targetView.snp.bottom).offset(9)
            $0.horizontalEdges.equalTo(profileView)
            $0.height.equalTo(68)
        }
        self.layoutIfNeeded()
    }
}
