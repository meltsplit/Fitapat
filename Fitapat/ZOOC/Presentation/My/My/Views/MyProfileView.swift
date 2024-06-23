//
//  ProfileView.swift
//  ZOOC
//
//  Created by 류희재 on 2023/01/01.
//

import UIKit

import SnapKit
import Then

final class MyProfileView: UIView {
    
    //MARK: - UI Components
    
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let breedLabel = UILabel()
    lazy var editProfileButton = UIButton()
    
    
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
    
    override func draw(_ rect: CGRect) {
        profileImageView.makeCornerRound(ratio: 2)
    }
    
    //MARK: - Custom Method
    
    private func style() {
        self.do {
            $0.backgroundColor = .clear
            $0.makeCornerRound(radius: 4)
            $0.setBorder(width: 1, color: .zw_brightgray)
        }
        
        profileImageView.do {
            $0.image = .zwImage(.mock_hidi)
            $0.contentMode = .scaleAspectFill
        }
        
        nameLabel.do {
            $0.font = .zw_Subhead1
            $0.textColor = .zw_black
            $0.textAlignment = .center
        }
        
        breedLabel.do {
            $0.font = .zw_Body2
            $0.textColor = .zw_gray
            $0.textAlignment = .center
        }
        
        editProfileButton.do {
            $0.setImage(.icEdit, for: .normal)
        }

        
    }
    
    private func hierarchy() {
        self.addSubviews(profileImageView, nameLabel, breedLabel, editProfileButton)
        
    }
    
    private func layout() {
        
        profileImageView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(24)
            $0.leading.equalToSuperview().inset(24)
            $0.size.equalTo(70)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(36)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(16)
        }
        
        breedLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
            $0.leading.equalTo(nameLabel)
        }
        
        editProfileButton.snp.makeConstraints {
            $0.centerY.equalTo(nameLabel)
            $0.leading.equalTo(nameLabel.snp.trailing).offset(4)
            $0.size.equalTo(20)
        }
        

    }
}

extension MyProfileView {
    func dataBind(_ data: PetResult) {
        nameLabel.text = data.name
        breedLabel.text = data.breed
        profileImageView.kfSetImage(with: data.photo, placeholder: .defaultProfile)
    }
}
