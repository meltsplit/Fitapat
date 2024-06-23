//
//  GenAISelectImageUseCase.swift
//  ZOOC
//
//  Created by 류희재 on 2023/09/21.
//

import RxSwift
import RxCocoa
import PhotosUI

protocol GenAISelectedImageUseCase {
    
    var registerError: PublishRelay<String> { get }
    var makeDataSetError: PublishRelay<String> { get }
    var imageUploadDidBegin: PublishRelay<Void> { get }
    
    func handlePetData(with model: SelectedImagesModel)
}

