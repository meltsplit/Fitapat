//
//  DefaultCustomDetailUseCase.swift
//  ZOOC
//
//  Created by 류희재 on 2/5/24.
//

import Foundation

import RxSwift
import RxRelay

final class DefaultCustomDetailUseCase: CustomDetailUseCase {
    
    private var characterID: Int
    private var customRepository: CustomRepository
    private var userRepository: UserRepository
    
    
    private let disposeBag = DisposeBag()
    
    var keywordData = PublishRelay<[(CustomKeywordType, PromptDTO?)]>()
    var detailCharacterData = BehaviorRelay<DetailCustomEntity?>(value: nil)
    
    init(
        characterID: Int,
        customRepository: CustomRepository,
        userRepository: UserRepository
    ) {
        self.characterID = characterID
        self.customRepository = customRepository
        self.userRepository = userRepository
    }
}

extension DefaultCustomDetailUseCase {
    func getDetailCustomData(_ detailType: CustomType) {
        switch detailType {
        case .concept:
            customRepository.getDetailSampleCharacter(characterID)
                .subscribe(with: self, onNext: { owner, data in
                    owner.keywordData.accept(data.keywordData)
                    owner.detailCharacterData.accept(data)
                }).disposed(by: disposeBag)
        case .character:
            customRepository.getDetailCharacter(characterID)
                .subscribe(with: self, onNext: { owner, data in
                    owner.keywordData.accept(data.keywordData)
                    owner.detailCharacterData.accept(data)
                }).disposed(by: disposeBag)
            
        }
    }
    
    func checkTicketAvailable() -> Observable<Bool> {
        userRepository.getTicket()
            .map { $0 > 0 }
    }

}
