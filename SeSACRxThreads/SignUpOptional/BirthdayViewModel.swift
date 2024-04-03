//
//  BirthdayViewModel.swift
//  SeSACRxThreads
//
//  Created by 차소민 on 4/3/24.
//

import Foundation
import RxSwift
import RxCocoa

final class BirthdayViewModel {
    private let disposeBag = DisposeBag()
    
    private let yearText = PublishSubject<Int>()
    private let monthText = PublishSubject<Int>()
    private let dayText = PublishSubject<Int>()
    
    let inputNextButtonTapped = PublishRelay<Void>()
    let inputPicker = PublishRelay<Date>()

    
    let outputYearLabel = PublishRelay<String>()
    let outputMonthLabel = PublishRelay<String>()
    let outputDayLabel = PublishRelay<String>()
    let outputNextButtonTapped = PublishRelay<Void>()
    let outputInfoLabelText = BehaviorRelay(value: "")
    let outputValidation = BehaviorRelay(value: false)
    
    init() { transform() }
    
    private func transform() {
        // Subscribe
        yearText
            .map { "\($0)년"}
            .bind(to: outputYearLabel)
            .disposed(by: disposeBag)
        
        monthText
            .map { "\($0)월"}
            .bind(to: outputMonthLabel)
            .disposed(by: disposeBag)
        
        dayText
            .map { "\($0)일" }
            .bind(to: outputDayLabel)
            .disposed(by: disposeBag)

        inputNextButtonTapped
            .asDriver(onErrorJustReturn: ())
            .drive(with: self){ owner, _ in
                owner.outputNextButtonTapped.accept(())
            }
            .disposed(by: disposeBag)

        inputPicker
            .bind(with: self) { owner, date in
                let component = Calendar.current.dateComponents([.year, .month, .day], from: date)
                // Emit
                owner.yearText.onNext(component.year!)
                owner.monthText.on(.next(component.month!))
                owner.dayText.onNext(component.day!)
            }
            .disposed(by: disposeBag)
        
        let validation = inputPicker
            .map {
                let selectDate = Calendar.current.dateComponents([.year], from: $0)
                let today = Calendar.current.dateComponents([.year], from: Date())
                return (today.year! - selectDate.year!) >= 17
            }

        validation
            .bind(with: self) { owner, value in
                let text = value ? "가입 가능한 나이입니다" : "만 17세 이상만 가입 가능합니다"
                owner.outputInfoLabelText.accept(text)
                owner.outputValidation.accept(value)
            }
            .disposed(by: disposeBag)
        
    }
    
}
