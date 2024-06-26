//
//  GenAIPetImageCollectionViewCell.swift
//  ZOOC
//
//  Created by 류희재 on 2023/08/18.
//

import UIKit

import SnapKit
import Photos

final class GenAIPetImageCollectionViewCell: UICollectionViewCell {

    // MARK: - UI Components

    var imageManager = PHCachingImageManager()
    public let petImageView = UIImageView()

    // MARK: - Life Cycles

    override init(frame: CGRect) {
        super.init(frame: frame)

        style()
        hierarchy()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Custom Method

    private func style() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        petImageView.do {
            $0.clipsToBounds = true
            $0.contentMode = .scaleAspectFill
        }
    }

    private func hierarchy() {
        contentView.addSubviews(petImageView)
    }

    private func layout() {
        petImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
}

extension GenAIPetImageCollectionViewCell: PHAssetTransformer {
    
    func dataBind(_ asset: PHAsset) {
        Task { @MainActor in
            let image = await transformToUIImage(for: asset,
                                                 targetSize: CGSize(width: 200, height: 200))
            self.petImageView.image = image
        }
    }
}
