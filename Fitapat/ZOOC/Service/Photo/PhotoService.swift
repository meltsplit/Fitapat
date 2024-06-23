//
//  PhotoService.swift
//  ZOOC
//
//  Created by 장석우 on 4/10/24.
//

import UIKit
import Photos
import Then

/*
 Photos 프레임워크
 - PHAsset: 사진 라이브러리에 있는 이미지, 비디오와 같은 하나의 애셋을 의미
 - PHAssetCollection: PHAsset의 컬렉션
 - PHCachingImageManager: 요청한 크기에 맞게 이미지를 로드하여 캐싱까지 수행
 - PHFetchResult: 앨범 하나
 
 Album(PHFetchResult) 먼저 불러오기
  > Album에 담긴 PHAsset을 가져와, 이미지 or 비디오 획득 (PHAsset)
 */

import RxSwift
import RxRelay

protocol PhotoService {
    func convertAlbumToPHAssets(album: PHFetchResult<PHAsset>)-> Observable<[PHAsset]>
}

final class DefaultPhotoService: NSObject, PhotoService {
    
    weak var delegate: PHPhotoLibraryChangeObserver?
    
    override init() {
        super.init()
        // PHPhotoLibraryChangeObserver 델리게이트
        // PHPhotoLibrary: 변경사항을 알려 데이터 리프레시에 사용
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func convertAlbumToPHAssets(album: PHFetchResult<PHAsset>) -> Observable<[PHAsset]> {
        return Observable<[PHAsset]>.create { observer in
            var phAssets = [PHAsset]()
            
            guard 0 < album.count else { return Disposables.create() }
            album.enumerateObjects { asset, index, stopPointer in
                guard index <= album.count - 1 else {
                    stopPointer.pointee = true
                    return
                }
                phAssets.append(asset)
            }
            
            observer.onNext(phAssets)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    
}

extension DefaultPhotoService: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        delegate?.photoLibraryDidChange(changeInstance)
    }
}
