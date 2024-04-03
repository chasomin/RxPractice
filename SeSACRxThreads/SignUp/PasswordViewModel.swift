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
    private let disposeBag = DisposeBag()
    
    let inputNextButtonTapped = PublishSubject<Void>()
    let inputPasswordText = PublishRelay<String>()
    
    let outputValidation = PublishRelay<Bool>()
    
    let outputNextButton = PublishSubject<Void>()
    

    init() { transform() }
    
    private func transform() {
        inputNextButtonTapped
            .bind(with: self) { owner, _ in
                owner.outputNextButton
                    .onNext(())
            }
            .disposed(by: disposeBag)
        
        
        let validation = inputPasswordText
            .map { $0.count >= 8 }
        
        validation
            .bind(to: outputValidation)
            .disposed(by: disposeBag)
    }
}
