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
    
    struct Input {
        let tap: ControlEvent<Void>
        let phoneNum: ControlProperty<String?>
    }
    
    struct Output {
        let tap: ControlEvent<Void>
        let description: Driver<String>
        let validation: Driver<Bool>
        let commonNumber: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        
        let commonNumber = BehaviorSubject(value: "010")
        
        let numberCheck = input.phoneNum.orEmpty
            .map { Int($0) != nil }
        
        let lengthCheck = input.phoneNum.orEmpty
            .map { $0.count >= 10 }
        
        let validation = Observable.combineLatest(numberCheck, lengthCheck) { $0 && $1 }
            .asDriver(onErrorJustReturn: false)
        
        let description = validation
            .map { value in
                value ? "" : "10자 이상, 숫자만 적어주세요"
            }
            .asDriver()
        
        let commonNumberResult = commonNumber
            .asDriver(onErrorJustReturn: "")
                
        return Output(tap: input.tap, description: description, validation: validation, commonNumber: commonNumberResult)
    }
    
//    let inputNextButtonTapped = BehaviorRelay(value: ())
//    let inputPhoneText = BehaviorRelay(value: "")
//    
//
//    let outputNextButton = PublishRelay<Void>()
//    let descriptionText = BehaviorRelay(value: "")
//    let outputPhoneNumber = BehaviorRelay(value: "")
//    let outputValidation = BehaviorRelay(value: false)
//    
//    init() { transform() }
//    
//    private func transform() {
//        inputNextButtonTapped
//            .asDriver()
//            .drive(with: self) { owner, _ in
//                owner.outputNextButton.accept(())
//            }
//            .disposed(by: disposeBag)
//        
//        validText
//            .asDriver()
//            .drive(descriptionText)
//            .disposed(by: disposeBag)
//        
//        commonNumber
//            .bind(to: outputPhoneNumber)
//            .disposed(by: disposeBag)
//        
//
//        
//    }
}
