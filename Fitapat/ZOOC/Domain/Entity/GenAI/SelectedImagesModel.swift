//
//  SelectedImageModel.swift
//  ZOOC
//
//  Created by 장석우 on 4/27/24.
//

import Photos

struct SelectedImagesModel {
    let name: String
    let breed: String?
    var assets: [PHAsset]
    let retryWithPet: PetResult?
}
