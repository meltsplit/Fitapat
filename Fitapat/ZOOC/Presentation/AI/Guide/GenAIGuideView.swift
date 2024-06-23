//
//  GenAIView.swift
//  ZOOC
//
//  Created by 류희재 on 2023/08/15.
//

import UIKit

import SnapKit
import Then

final class GenAIGuideView: UIView {
    
    //MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let guide0ImageView = UIImageView(image: .guide0)
    private let guide1ImageView = UIImageView(image: .guide1)
    private let guide2ImageView = UIImageView(image: .guide2)
    private let guide3ImageView = UIImageView(image: .guide3)
    
    public lazy var selectImageButton = FapBottomButton(title: "8 - 15장의 사진 업로드")
    
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
        scrollView.bounces = false
        [guide0ImageView,
         guide1ImageView,
         guide2ImageView,
         guide3ImageView
        ].forEach {
            $0.clipsToBounds = true
            $0.contentMode = .scaleAspectFit
        }
        
    }
    
    private func hierarchy() {
        self.addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        scrollView.contentInsetAdjustmentBehavior = .never
        
        contentView.addSubviews(
            guide0ImageView,
            guide1ImageView,
            guide2ImageView,
            guide3ImageView,
            selectImageButton
        )
    }
    
    private func layout() {
    
        scrollView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
            $0.height.greaterThanOrEqualTo(scrollView).priority(.low)
        }
        
        
        guide0ImageView.snp.makeConstraints {
            let height = 108 * (Device.width - 106) / 268
            $0.top.equalToSuperview().inset(32)
            $0.horizontalEdges.equalToSuperview().inset(50)
            $0.height.equalTo(height)
        }
        
         guide1ImageView.snp.makeConstraints {
             let height = 130 * (Device.width) / 375
             $0.top.equalTo(guide0ImageView.snp.bottom).offset(60)
             $0.horizontalEdges.equalToSuperview()
             $0.height.equalTo(height)
         }
        
        guide2ImageView.snp.makeConstraints {
            let height = 534 * (Device.width - 56) / 319
            $0.top.equalTo(guide1ImageView.snp.bottom).offset(50)
            $0.horizontalEdges.equalToSuperview().inset(28)
            $0.height.equalTo(height)
        }
        
        
         guide3ImageView.snp.makeConstraints {
             let height = 739 * (Device.width - 56) / 319
             $0.top.equalTo(guide2ImageView.snp.bottom).offset(50)
             $0.horizontalEdges.equalToSuperview().inset(28)
             $0.height.equalTo(height)
         }
        
 
        
        selectImageButton.snp.makeConstraints {
            $0.top.equalTo(guide3ImageView.snp.bottom).offset(50)
            $0.bottom.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(90)
        }
    }
}


