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
    struct Input {
        let nextButtonTap: ControlEvent<Void>
        let birthday: ControlProperty<Date>
    }
    
    struct Output {
        let tap: ControlEvent<Void>
        let year: Driver<String>
        let month: Driver<String>
        let day: Driver<String>
        let validation: Driver<Bool>
        let description: Driver<String>
    }

    func transform(input: Input) -> Output {
        
        let date = input.birthday
            .map { value in
                Calendar.current.dateComponents([.year, .month, .day], from: value)
            }
        
        let year = date
            .map { value in
                "\(value.year!)년"
            }
            .asDriver(onErrorJustReturn: "")
        
        let month = date
            .map { value in
                "\(value.month!)월"
            }
            .asDriver(onErrorJustReturn: "")
        
        let day = date
            .map { value in
                "\(value.day!)일"
            }
            .asDriver(onErrorJustReturn: "")
        
        let validation = date
               .map { date in
                   let today = Calendar.current.dateComponents([.year], from: Date())
                   return (today.year! - date.year!) >= 17
               }
               .asDriver(onErrorJustReturn: false)

          let description = validation
            .map {
                $0 ? "가입 가능한 나이입니다" : "만 17세 이상만 가입 가능합니다"
            }
            .asDriver()
        
        return Output.init(tap: input.nextButtonTap, year: year, month: month, day: day, validation: validation, description: description)
    }
}
