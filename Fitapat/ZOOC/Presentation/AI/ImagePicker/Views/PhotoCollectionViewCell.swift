//
//  ImagePickerCollectionViewCell.swift
//  ZOOC
//
//  Created by 장석우 on 4/10/24.
//

import UIKit

import SnapKit
import Then
import PhotosUI
import RxSwift
import RxCocoa

final class PhotoCollectionViewCell: UICollectionViewCell, PHAssetTransformer {
    
    // MARK: - Properties
    
    private var asset: PHAsset?
    
    internal let imageManager = PHCachingImageManager()
    private var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let imageView = UIImageView()
    private let selectedIndexLabel = UILabel()
    private let selectedView = UIView()
    
    
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
        
        selectedIndexLabel.makeCornerRound(ratio: 2)
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageManager.stopCachingImagesForAllAssets()
        asset = nil
        selectedIndexLabel.text = nil
        disposeBag = DisposeBag()
    }

    
    // MARK: - Custom Method
    
    private func style() {
        contentView.backgroundColor = .zw_background
        
        selectedView.do {
            $0.backgroundColor = .clear
            $0.setBorder(width: 2, color: .clear)
        }
        
        imageView.do {
            $0.clipsToBounds = true
            $0.contentMode = .scaleAspectFill
        }
        
        selectedIndexLabel.do {
            $0.isHidden = true
            $0.textAlignment = .center
            $0.font = .pretendard(font: .semiBold, size: 14)
            $0.textColor = .zw_white
            $0.backgroundColor = .zw_point
        }
        
    }
    
    private func hieararchy() {
        contentView.addSubviews(
            imageView,
            selectedView,
            selectedIndexLabel
        )
    }
    
    private func layout() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        selectedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        selectedIndexLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(10)
            $0.trailing.equalToSuperview().inset(10)
            $0.size.equalTo(24)
        }
    }
    
    private func updateUI(_ state: Bool) {
        let isSelected = state
        let backgroundColor: UIColor = isSelected ? .black.withAlphaComponent(0.5) : .clear
        let borderColor: UIColor = isSelected ? .zw_point : .clear
        
        selectedIndexLabel.isHidden = !isSelected
        selectedView.backgroundColor = backgroundColor
        selectedView.layer.borderColor = borderColor.cgColor
    }
    
    
    func observe(at selectedImages: BehaviorRelay<[PHAsset]>) {
        selectedImages
            .asDriver(onErrorJustReturn: [])
            .drive(with: self,
                       onNext: { owner, images in
                
                if let asset = owner.asset, let index = images.firstIndex(of: asset) {
                    let order = index + 1
                    owner.updateUI(true)
                    owner.selectedIndexLabel.text = String(order)
                } else {
                    owner.updateUI(false)
                }
        })
            .disposed(by: disposeBag)
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


