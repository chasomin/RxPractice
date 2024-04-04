//
//  PasswordViewModel.swift
//  SeSACRxThreads
//
//  Created by 차소민 on 4/3/24.
//

import Foundation
import RxSwift
import RxCocoa

final class PasswordViewModel {
    
    struct Input {
        let nextTap: ControlEvent<Void>
        let password: ControlProperty<String?>
    }
    
    struct Output {
        let nextTap: ControlEvent<Void>
        let validation: Driver<Bool>
        let description: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let validation = input.password.orEmpty
            .map {
                $0.count >= 8
            }
            .asDriver(onErrorJustReturn: false)
        
        let text = validation
            .map {
                $0 ? "" : "8자 이상"
            }
            .asDriver()//?
        
        return Output(nextTap: input.nextTap, validation: validation, description: text)
    }

}
