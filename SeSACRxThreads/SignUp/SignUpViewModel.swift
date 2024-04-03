//
//  SignUpViewModel.swift
//  SeSACRxThreads
//
//  Created by 차소민 on 4/3/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SignUpViewModel {
    let inputNextButtonTapped = PublishRelay<Void>()
    let inputEmailText = BehaviorRelay(value: "")
    let inputValidationButtonTapped = PublishRelay<Void>()
    
    let outputNextButtonTapped = PublishRelay<Void>()
    let outputValidText = PublishRelay<String>()
    let outputValidStatus = PublishRelay<Bool>()
    var outputAllValidation = Observable.just(false)
    
    let userEmail = ["a@a.com", "b@b.com"]
    var availableEmail = BehaviorSubject(value: false)
    
    
    private let disposeBag = DisposeBag()
    
    init() { transform() }
    
    private func transform() {
        inputNextButtonTapped
            .bind(with: self) { owner, _ in
                owner.outputNextButtonTapped
                    .accept(())
            }
            .disposed(by: disposeBag)


        let userEmailValid = inputEmailText
            .map { $0.count >= 7 }
        
        userEmailValid
            .bind(with: self) { owner, value in
                let text = value ? "중복 체크" : "7자 이상"
                owner.outputValidText
                    .accept(text)
                owner.outputValidStatus
                    .accept(value)
            }
            .disposed(by: disposeBag)
        
        
        inputValidationButtonTapped
            .asDriver(onErrorJustReturn: ())
            .drive(with: self) { owner, _ in
                owner.availableEmail.onNext(!owner.userEmail.contains(owner.inputEmailText.value))
                print(try! owner.availableEmail.value())
            }
            .disposed(by: disposeBag)

        outputAllValidation = Observable.combineLatest(userEmailValid, availableEmail) { $0 && $1 }
        outputAllValidation
            .bind(with: self) { owner, value in
                owner.outputValidStatus
                    .accept(value)
            }
            .disposed(by: disposeBag)
        
        availableEmail
            .bind(with: self) { owner, value in
                let text = value ? "사용 가능" : "사용 불가능"
                owner.outputValidText
                    .accept(text)
                owner.outputValidStatus
                    .accept(value)
            }
            .disposed(by: disposeBag)
    }
}
