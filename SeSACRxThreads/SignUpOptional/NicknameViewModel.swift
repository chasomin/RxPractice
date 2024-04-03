//
//  NicknameViewModel.swift
//  SeSACRxThreads
//
//  Created by 차소민 on 4/3/24.
//

import Foundation
import RxSwift
import RxCocoa

final class NicknameViewModel {
    let disposeBag = DisposeBag()
//    
//    let inputNextButton = BehaviorSubject(value: ())
//    let inputNickname = BehaviorSubject(value: "")
//    
//    let outputNextButton = PublishSubject<Void>()
//    let outputValidation = BehaviorSubject(value: false)    // 초기값 false 없으면 처음에 button 누를 수 있음
    
    struct Input {
        let tap: ControlEvent<Void>
        let text: ControlProperty<String?>
    }
    
    struct Output {
        let tap: ControlEvent<Void>
        let text: Driver<String>
        let validation: Observable<Bool>
    }
    
    func transform(input: Input) -> Output {
//        inputNextButton
//            .bind(to: outputNextButton)
//            .disposed(by: disposeBag)
//        
//        let nicknameCheck = inputNickname
//            .map { $0.count > 2 }
//            .debug()
//        
//        nicknameCheck
//            .bind(to: outputValidation)
//            .disposed(by: disposeBag)
        
        let validation = input.text.orEmpty.map { $0.count > 2 }
        let validationText = BehaviorRelay(value: "3자 이상").asDriver()
            
        return Output(tap: input.tap, text: validationText, validation: validation)
    }
    

}
