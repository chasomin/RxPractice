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
    
    let inputNextButton = BehaviorSubject(value: ())
    let inputNickname = BehaviorSubject(value: "")
    
    let outputNextButton = PublishSubject<Void>()
    let outputValidation = BehaviorSubject(value: false)    // 초기값 false 없으면 처음에 button 누를 수 있음
    
    init() { transform() }
    
    private func transform() {
        inputNextButton
            .bind(to: outputNextButton)
            .disposed(by: disposeBag)
        
        let nicknameCheck = inputNickname
            .map { $0.count > 2 }
            .debug()
        
        nicknameCheck
            .bind(to: outputValidation)
            .disposed(by: disposeBag)
            
    }
}
