//
//  AlbumCollectionViewCell.swift
//  ZOOC
//
//  Created by 장석우 on 4/16/24.
//

import UIKit

import SnapKit
import Then
import Photos

final class AlbumCollectionViewCell: UICollectionViewCell, PHAssetTransformer {
    
    // MARK: - Properties
    
    var imageManager = PHCachingImageManager()

    // MARK: - UI Components
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let countLabel = UILabel()
    
    private let vStackView = UIStackView()
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        style()
        hieararchy()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageManager.stopCachingImagesForAllAssets()
    }
    
    // MARK: - Custom Method
    
    private func style() {
        contentView.backgroundColor = .zw_background
  
        imageView.do {
            $0.image = .default
            $0.makeCornerRound(radius: 2)
            $0.clipsToBounds = true
            $0.contentMode = .scaleAspectFill
        }
        
        titleLabel.do {
            $0.font = .pretendard(font: .semiBold, size: 16)
            $0.textColor = .zw_black
        }
        
        countLabel.do {
            $0.font = .pretendard(font: .medium, size: 14)
            $0.textColor = .zw_gray
        }
        
        vStackView.do {
            $0.axis = .vertical
            $0.distribution = .fill
            $0.alignment = .leading
            $0.spacing = 4
        }
        

    }
    
    private func hieararchy() {
        contentView.addSubviews(
            imageView,
            vStackView
        )
        
        vStackView.addArrangedSubViews(
            titleLabel,
            countLabel
        )
    }
    
    private func layout() {
        
        imageView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(10)
            $0.leading.equalToSuperview().inset(20)
            $0.width.equalTo(imageView.snp.height)
        }
        
        vStackView.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(20)
            $0.centerY.equalToSuperview()
        }

    }
    
    func dataBind(_ albumInfo: AlbumInfo) {
        
        titleLabel.text = albumInfo.name
        countLabel.text = String(albumInfo.album.count)
        
        
        if let thumbnail = albumInfo.thumbnail {
            Task { @MainActor in
                let image = await transformToUIImage(for: thumbnail,
                                                     targetSize: CGSize(width: 200, height: 200))
                self.imageView.image = image
            }
        } else {
            self.imageView.image = .default
        }
       
        
    }
}


