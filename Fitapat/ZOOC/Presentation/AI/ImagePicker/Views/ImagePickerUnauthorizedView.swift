//
//  ImagePickerUnauthorizedView.swift
//  ZOOC
//
//  Created by 장석우 on 4/10/24.
//

import UIKit
import PhotosUI

import SnapKit
import Then


final class ImagePickerUnauthorizedView: UIView {
    
    let xButton = UIButton()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private let guideImageView: UIImageView = {
        let imageView = UIImageView(image: .photoAccessGuide)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let permissionButton: UIButton = {
        let button = UIButton()
        button.setTitle("설정하러 가기", for: .normal)
        button.setTitleColor(.zw_white, for: .normal)
        button.titleLabel?.font = .zw_Subhead2
        button.backgroundColor = .zw_point
        button.makeCornerRound(radius: 8)
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        
        style()
        hierarchy()
        layout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func style() {
        
        backgroundColor = .zw_background
        
        xButton.do {
            $0.setImage(.btnX.withTintColor(.zw_black), for: .normal)
            $0.contentMode = .scaleAspectFit
        }
        
        titleLabel.do {
            $0.text = "\'fitapat\'의 사진 접근 권한을 허용해 주세요"
            $0.font = .zw_Subhead1
            $0.textColor = .zw_black
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        
        descriptionLabel.do {
            $0.text = "반려동물 사진을 업로드 하기 위해선 사진 접근 권한이 필요해요"
            $0.font = .zw_Body2
            $0.textColor = .zw_gray
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        
    }
    
    private func hierarchy() {
        
        addSubviews(
            xButton,
            titleLabel,
            descriptionLabel,
            guideImageView,
            permissionButton)
    }
    
    private func layout() {
        
        xButton.snp.makeConstraints {
            $0.centerY.equalTo(safeAreaLayoutGuide.snp.top).offset(25)
            $0.leading.equalToSuperview().inset(10)
            $0.size.equalTo(42)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(140)
            $0.horizontalEdges.equalToSuperview().inset(28)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(9).priority(.required)
            $0.horizontalEdges.equalToSuperview().inset(28)
        }
        
        guideImageView.snp.makeConstraints {
            let height = 372 * (Device.width - 56) / 339
            $0.top.equalTo(descriptionLabel).inset(60)
            $0.horizontalEdges.equalToSuperview().inset(28)
            $0.height.equalTo(height)
        }
        
        permissionButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(80)
            $0.horizontalEdges.equalToSuperview().inset(28)
            $0.height.equalTo(60)
        }
    }
}

