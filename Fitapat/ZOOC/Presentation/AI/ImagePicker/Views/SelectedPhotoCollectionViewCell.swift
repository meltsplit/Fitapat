//
//  SelectedPhotoCollectionViewCell.swift
//  ZOOC
//
//  Created by 장석우 on 4/27/24.
//

import UIKit

import SnapKit
import Then
import PhotosUI
import RxSwift
import RxRelay

final class SelectedPhotoCollectionViewCell: UICollectionViewCell, PHAssetTransformer {
    
    // MARK: - Properties
    
    private var asset: PHAsset?
    
    internal let imageManager = PHCachingImageManager()
    private var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let imageView = UIImageView()
    private let xButton = UIImageView()
    
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
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        xButton.makeCornerRound(ratio: 2)
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageManager.stopCachingImagesForAllAssets()
        asset = nil
        
        disposeBag = DisposeBag()
    }

    
    // MARK: - Custom Method
    
    private func style() {
        contentView.backgroundColor = .zw_background
        
        imageView.do {
            $0.clipsToBounds = true
            $0.contentMode = .scaleAspectFill
            $0.makeCornerRound(radius: 4)
        }
        
        xButton.do {
            $0.backgroundColor = .zw_darkgray
            $0.image = .btnX.withTintColor(.zw_white)
            $0.alpha = 0.85
        }
        
        
    }
    
    private func hieararchy() {
        contentView.addSubviews(
            imageView,
            xButton
        )
    }
    
    private func layout() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        xButton.snp.makeConstraints {
            $0.centerX.equalTo(imageView.snp.trailing).offset(-5)
            $0.centerY.equalTo(imageView.snp.top).offset(5)
            $0.size.equalTo(16)
        }
    }
    
    func dataBind(_ asset: PHAsset) {
        self.asset = asset
        Task { @MainActor in
            let image = await transformToUIImage(for: asset,
                                                 targetSize: CGSize(width: 200, height: 200))
            self.imageView.image = image
        }
    }
}


