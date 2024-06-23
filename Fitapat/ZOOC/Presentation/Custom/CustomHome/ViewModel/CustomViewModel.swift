//
//  CustomViewModel.swift
//  ZOOC
//
//  Created by 류희재 on 2/2/24.
//

import Foundation

import RxSwift
import RxRelay

final class CustomViewModel: ViewModelType {
    
    //MARK: - Dependency
    
    private var useCase: CustomUseCase
    
    //MARK: - Properties
    
    struct Input {
        let viewDidLoadEvent: Observable<Void>
        let conceptButtonDidTapEvent: Observable<Void>
        let albumButtonDidTapEvent: Observable<Void>
        let customViewRefreshEvent: Observable<Void>
        let emptyConceptButtonDidTapEvent: Observable<Void>
        let customAIButtonDidTapEvent: Observable<CustomViewType>
        let refreshNotificationEvent: Observable<Void>
    }
    
    struct Output {
        let conceptData = PublishRelay<[ConceptItemEntity]>()
        let albumData = PublishRelay<[[String : [CustomCharacterResult]]]>()
        let pushToChooseConcpetVC = PublishRelay<Bool>()
        let pushToSelfCustomWeb = PublishRelay<Void>()
        let presentFirstTicket = PublishRelay<Void>()
        let ticketCnt = PublishRelay<Int>()
    }
    
    //MARK: - Life Cycle
    
    init(
        useCase: CustomUseCase
    ) {
        self.useCase = useCase
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        self.bindOutput(output: output, disposeBag: disposeBag)
        
        input.viewDidLoadEvent
            .filter { UserDefaultsManager.isFirstAttemptCustom }
            .map { _ in }
            .do(onNext: { UserDefaultsManager.isFirstAttemptCustom = false })
            .bind(to: output.presentFirstTicket)
            .disposed(by: disposeBag)
            
        
        Observable.merge(input.viewDidLoadEvent, 
                         input.customViewRefreshEvent,
                         input.refreshNotificationEvent)
            .bind(onNext: useCase.getCustomData)
            .disposed(by: disposeBag)

        input.customAIButtonDidTapEvent
            .filter { $0 == .album }
            .map { _ in }
            .bind(to: output.pushToSelfCustomWeb)
            .disposed(by: disposeBag)
        
        input.customAIButtonDidTapEvent
            .filter { $0 == .concept }
            .map { _ in }
            .flatMap(useCase.checkTicketAvailable)
            .bind(to: output.pushToChooseConcpetVC)
            .disposed(by: disposeBag)
        
        input.emptyConceptButtonDidTapEvent
            .flatMap(useCase.checkTicketAvailable)
            .bind(to: output.pushToChooseConcpetVC)
            .disposed(by: disposeBag)
        

        return output
    }
    
    private func bindOutput(output: Output, disposeBag: DisposeBag) {
        useCase.conceptItemData
            .bind(to: output.conceptData)
            .disposed(by: disposeBag)
        
        useCase.characterData
            .bind(to: output.albumData)
            .disposed(by: disposeBag)
        
        useCase.ticketCnt
            .bind(to: output.ticketCnt)
            .disposed(by: disposeBag)
    }
}

