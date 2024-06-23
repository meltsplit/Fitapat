//
//  DefaultCustomUseCase.swift
//  ZOOC
//
//  Created by 류희재 on 2/2/24.
//

import RxSwift
import RxCocoa
import Foundation

final class DefaultCustomUseCase: CustomUseCase {
    
    private let customRepository: CustomRepository
    private let userRepository: UserRepository
    
    private let disposeBag = DisposeBag()
    
    //컨셉뷰
    var conceptItemData = PublishRelay<[ConceptItemEntity]>()
    var conceptData: [CustomConceptResult] = []
    var sampleCharacterData = PublishRelay<[[CharacterResult]]>()
    var ticketCnt = BehaviorRelay<Int>(value: 0)
    
    //앨범뷰
    var characterData = PublishRelay<[[String : [CustomCharacterResult]]]>()
    
    init(
        userRepository: UserRepository,
        customRepository: CustomRepository
    ) {
        self.userRepository = userRepository
        self.customRepository = customRepository
    }
}

extension DefaultCustomUseCase {
    func getCustomData() {
        getConceptData()
        getAlbumData()
        getTicketData()
    }
    
    func getConceptData() {
        customRepository.getConcept()
            .do(onNext: { [weak self] conceptData in
                self?.conceptData = conceptData
            })
            .map { $0.map { $0.id } }
            .flatMap(customRepository.getSampleCharacter)
            .subscribe(with: self, onNext: { owner, sampleCharacterList in
                var conceptItemData: [ConceptItemEntity] = []
                for index in 0..<sampleCharacterList.count {
                    let conceptItem = ConceptItemEntity(
                        conceptData: owner.conceptData[index],
                        sampleCharacterData: sampleCharacterList[index]
                    )
                    conceptItemData.append(conceptItem)
                }
                owner.conceptItemData.accept(conceptItemData)
            }).disposed(by: disposeBag)
    }
    
    func getAlbumData() {
        customRepository.getCharacter()
            .map { $0.toDomain() }
            .bind(to: characterData)
            .disposed(by: disposeBag)
    }
    
    func getTicketData() {
        userRepository.getTicket()
            .bind(to: ticketCnt)
            .disposed(by: disposeBag)
    }
    
    
    func checkTicketAvailable() -> Observable<Bool> {
        userRepository.getTicket()
            .map { $0 > 0 }
    }
}
