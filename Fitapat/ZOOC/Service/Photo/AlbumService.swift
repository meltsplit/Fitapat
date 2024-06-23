//
//  AlbumService.swift
//  ZOOC
//
//  Created by 장석우 on 4/16/24.
//

import Photos
import UIKit
import Then

import RxSwift
import RxRelay

struct AlbumInfo: Identifiable {
    let id: String?
    let name: String
    let thumbnail: PHAsset?
    let album: PHFetchResult<PHAsset>
    
    init(fetchResult: PHFetchResult<PHAsset>, albumName: String) {
        self.id = nil
        self.thumbnail = fetchResult.firstObject
        self.name = albumName
        self.album = fetchResult
    }
    
    static func unknown() -> AlbumInfo {
        return .init(fetchResult: .init(), albumName: String())
    }
}

protocol AlbumService {
    func getAlbums() -> Observable<[AlbumInfo]>
}

final class DefaultAlbumService: AlbumService {
    
    func getAlbums() -> Observable<[AlbumInfo]> {
        return Observable<[AlbumInfo]>.create { [weak self] observer in
            guard let self else { return Disposables.create()}
            
            // 0. albums 변수 선언
            var albums = [AlbumInfo]()
            
            
            // 1. query 설정
            let fetchOptions = PHFetchOptions().then {
                $0.predicate = self.getPredicate()
                $0.sortDescriptors = self.getSortDescriptors
            }
            
            // 2. standard 앨범을 query로 이미지 가져오기
//            let standardFetchResult = PHAsset.fetchAssets(with: fetchOptions)
//            print("🔥🔥🔥🔥🔥🔥🔥🔥")
//            albums.append(.init(fetchResult: standardFetchResult,
//                                albumName: "최근항목"))
            
            let smartAlbums = PHAssetCollection.fetchAssetCollections(
                with: .smartAlbum,
                subtype: .any,
                options: PHFetchOptions()
            )
            
            smartAlbums.enumerateObjects { [weak self] phAssetCollection, index, pointer in
                guard let self, index <= smartAlbums.count - 1 else {
                    pointer.pointee = true
                    return
                }
                
                // 값을 빠르게 받아오지 못하는 경우
                if phAssetCollection.estimatedAssetCount == NSNotFound {
                    // 쿼리를 날려서 가져오기
                    let fetchOptions = PHFetchOptions().then {
                        $0.predicate = self.getPredicate()
                        $0.sortDescriptors = self.getSortDescriptors
                    }
                    let fetchResult = PHAsset.fetchAssets(in: phAssetCollection, options: fetchOptions)
                    guard fetchResult.count > 0 else { return }
                    albums.append(.init(fetchResult: fetchResult,
                                        albumName: phAssetCollection.localizedTitle ?? "-"))
                }
            }
            
            let justAlbum = PHAssetCollection.fetchAssetCollections(
                with: .album,
                subtype: .any,
                options: PHFetchOptions()
            )
            
            justAlbum.enumerateObjects { [weak self] phAssetCollection, index, pointer in
                guard let self, index <= justAlbum.count - 1 else {
                    pointer.pointee = true
                    return
                }
                
                // 쿼리를 날려서 가져오기
                let fetchOptions = PHFetchOptions().then {
                    $0.predicate = self.getPredicate()
                    $0.sortDescriptors = self.getSortDescriptors
                }
                let fetchResult = PHAsset.fetchAssets(in: phAssetCollection, options: fetchOptions)
                guard fetchResult.count > 0 else { return }
                albums.append(.init(fetchResult: fetchResult,
                                    albumName: phAssetCollection.localizedTitle ?? "-"))
                
            }
         
            
           
            
            observer.onNext(albums)
            observer.onCompleted()
            return Disposables.create()
        }

    }
    
    private func getPredicate() -> NSPredicate {
        let format = "mediaType == %d"
        return .init(
            format: format,
            PHAssetMediaType.image.rawValue
        )
    }
    
    private let getSortDescriptors = [
        NSSortDescriptor(key: "creationDate", ascending: false),
        NSSortDescriptor(key: "modificationDate", ascending: false)
    ]
}
