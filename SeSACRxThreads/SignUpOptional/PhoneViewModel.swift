//
//  PhoneViewModel.swift
//  SeSACRxThreads
//
//  Created by 차소민 on 4/3/24.
//

import Foundation
import RxSwift
import RxCocoa

final class PhoneViewModel {
    let disposeBag = DisposeBag()
    
    let inputNextButtonTapped = BehaviorRelay(value: ())
    let inputPhoneText = BehaviorRelay(value: "")
    
    let validText = Observable.just("10자 이상, 숫자만 적어주세요")
    let commonNumber = Observable.just("010")

    let outputNextButton = PublishRelay<Void>()
    let descriptionText = BehaviorRelay(value: "")
    let outputPhoneNumber = BehaviorRelay(value: "")
    let outputValidation = BehaviorRelay(value: false)
    
    init() { transform() }
    
    private func transform() {
        inputNextButtonTapped
            .asDriver()
            .drive(with: self) { owner, _ in
                owner.outputNextButton.accept(())
            }
            .disposed(by: disposeBag)
        
        validText
            .bind(to:descriptionText)
            .disposed(by: disposeBag)
        
        commonNumber
            .bind(to: outputPhoneNumber)
            .disposed(by: disposeBag)
        
        
        let numberCheck = inputPhoneText.map { Int($0) != nil }
        let lengthCheck = inputPhoneText.map { $0.count >= 10 }
        
        let result = Observable.combineLatest(numberCheck, lengthCheck) { num, length in
            return num && length
        }
        
        result
            .bind(to: outputValidation)
            .disposed(by: disposeBag)
        
    }
}
