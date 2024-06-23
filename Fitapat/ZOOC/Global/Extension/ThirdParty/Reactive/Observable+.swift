//
//  Observable+.swift
//  ZOOC
//
//  Created by 장석우 on 3/19/24.
//

import RxSwift

extension ObservableType {
    func replacingNetworkError(
        of target: NetworkServiceError,
        with replacement: Error
    ) -> Observable<Element> {
        self.catch { error in
            guard let error = error as? NetworkServiceError else { return .error(error) }
            return error == target ? .error(replacement) : .error(error)
        }
    }
    
    func catchNetworkAndReturn(
         of target: NetworkServiceError,
         with element: Element
    ) -> Observable<Element> {
        self.catch { error in
            guard let error = error as? NetworkServiceError else { return .error(error) }
            return error == target ? .just(element) : .error(error)
        }
    }
}

