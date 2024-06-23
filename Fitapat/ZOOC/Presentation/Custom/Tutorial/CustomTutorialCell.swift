//
//  CustomTutorialCell.swift
//  ZOOC
//
//  Created by 장석우 on 3/22/24.
//

import UIKit

import SnapKit
import Then

final class CustomTutorialCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let imageView = UIImageView()
    
    // MARK: - UI Components
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        style()
        hieararchy()
        layout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        

        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Custom Method
    
    private func style() {
        
        contentView.backgroundColor = .zw_background
        
        titleLabel.do {
            $0.font = .zw_Subhead1
            $0.textColor = .zw_black
            $0.textAlignment = .center
        }
        
        descriptionLabel.do {
            $0.font = .zw_Body2
            $0.textColor = .zw_gray
            $0.textAlignment = .center
        }
        
        imageView.do {
            $0.clipsToBounds = true
            $0.contentMode = .scaleAspectFill
        }

    }
    
    private func hieararchy() {
        contentView.addSubviews(
            titleLabel,
            descriptionLabel,
            imageView
        )
    }
    
    private func layout() {
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().priority(.required)
            $0.horizontalEdges.equalToSuperview()
        }
        
        descriptionLabel.setContentHuggingPriority(.required, for: .vertical)
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(9).priority(.required)
            $0.horizontalEdges.equalToSuperview()
        }
        
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        imageView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(9).priority(.required)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
        }
        

    }
}

extension CustomTutorialCell {
    
    func dataBind(_ step: CustomTutorialViewController.TutorialStep) {
        titleLabel.text = step.title
        descriptionLabel.text = step.description
        imageView.image = step.image
    }
}

