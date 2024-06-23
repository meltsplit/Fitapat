//
//  PHAssetTransformer.swift
//  ZOOC
//
//  Created by 장석우 on 4/25/24.
//

import UIKit
import Photos

protocol PHAssetTransformer {
    var imageManager: PHCachingImageManager { get }
    func transformToUIImage(for asset: PHAsset, targetSize: CGSize) async -> UIImage?
    func transformToUIImages(for assets: [PHAsset], targetSize: CGSize) async -> [UIImage]
}

extension PHAssetTransformer {
    func transformToUIImage(for asset: PHAsset, targetSize: CGSize) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions().then {
                $0.isNetworkAccessAllowed = true // iCloud
                $0.deliveryMode = .highQualityFormat
            }
            
            imageManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: options,
                resultHandler: { image, _ in
                    return continuation.resume(returning: image)
                }
            )
        }
    }
    
    func transformToUIImages(
        for assets: [PHAsset],
        targetSize: CGSize) async -> [UIImage]
    {
        var images: [UIImage] = []
        
        for asset in assets {
            if let image = await transformToUIImage(for: asset, targetSize: targetSize) {
                images.append(image)
            }
        }
        
        return images
    }
}
