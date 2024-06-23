//
//  MyNoticeView.swift
//  ZOOC
//
//  Created by 류희재 on 5/14/24.
//

import UIKit

import SnapKit
import Then

final class MyNoticeView: UIView {
    
    //MARK: - UI Components
    
    private let marketingTitleLabel = UILabel()
    internal let marketingAgreeButton = UISwitch()
    private let separator = UIView()
    private let noticeSettingTitleLabel = UILabel()
    let noticeSettingButton = UIButton()
    
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
    
    //MARK: - Custom Method
    
    private func style() {
        marketingTitleLabel.do {
            $0.text = "(선택) 마케팅 수신 동의"
            $0.font = .zw_Body1
            $0.textColor = .zw_black
            $0.textAlignment = .left
        }
        
        marketingAgreeButton.do {
            $0.onTintColor = .zw_point
        }
        
        separator.backgroundColor = .zw_brightgray
        noticeSettingTitleLabel.do {
            $0.text = "기기 알림 설정"
            $0.font = .zw_Body1
            $0.textColor = .zw_black
            $0.textAlignment = .left
        }
        noticeSettingButton.do {
            $0.setTitle("설정", for: .normal)
            $0.setTitleColor(.zw_point, for: .normal)
            $0.titleLabel?.font = .zw_Subhead3
            $0.titleLabel?.textAlignment = .left

        }
    }
    
    private func hierarchy() {
        self.addSubviews(
            marketingTitleLabel,
            marketingAgreeButton, 
            separator,
            noticeSettingTitleLabel,
            noticeSettingButton
        )
    }
    
    private func layout() {
        marketingTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(128)
            $0.leading.equalToSuperview().offset(28)
        }
        marketingAgreeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(125)
            $0.trailing.equalToSuperview().inset(28)
            $0.width.equalTo(43)
            $0.height.equalTo(26)
        }
        separator.snp.makeConstraints {
            $0.top.equalTo(marketingTitleLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(28)
            $0.height.equalTo(1)
        }
        noticeSettingTitleLabel.snp.makeConstraints {
            $0.top.equalTo(separator.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(28)
        }
        noticeSettingButton.snp.makeConstraints {
            $0.top.equalTo(noticeSettingTitleLabel)
            $0.trailing.equalToSuperview().inset(28)
        }
    }

}
