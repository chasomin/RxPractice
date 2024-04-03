//
//  ShoppingViewModel.swift
//  SeSACRxThreads
//
//  Created by 차소민 on 4/3/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ShoppingViewModel {
    let items = BehaviorRelay(value: [ShoppingData(todo: "커피 구매"), ShoppingData(todo: "지갑 구매"), ShoppingData( todo: "비타민 구매")])
   
    let inputAddbuttonTapped = PublishRelay<Void>()
    let inputTextFieldText = PublishRelay<String>()
    let inputSearchText = PublishRelay<String>()
    let inputSearchButtonTapped = PublishRelay<Void>()
    let inputTableViewSelected = PublishRelay<IndexPath>()
    let inputTableViewSelectedItem = PublishRelay<ShoppingData>()
    
    let outputItem = BehaviorRelay(value: [ShoppingData(todo: "")])
    
    let disposeBag = DisposeBag()

    init() { transform() }
    
    private func transform() {
        
        inputAddbuttonTapped
            .withLatestFrom(inputTextFieldText)
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: "")
            .distinctUntilChanged()
            .drive(with: self) { owner, value in
                var item = owner.items.value
                item.insert(ShoppingData(todo: value), at: 0)
                owner.items.accept(item)
                owner.outputItem.accept(item)
//                owner.textField.text = ""
            }
            .disposed(by: disposeBag)
        
        inputSearchText
            .debug()
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: "")
            .distinctUntilChanged()
            .drive(with: self) { owner, value in
                print("실시간 검색 ", value)
                let item = owner.items.value
                let result = value.isEmpty ? item : item.filter { $0.todo.contains(value) }
                owner.outputItem.accept(result)
            }
            .disposed(by: disposeBag)
        
        
        inputSearchButtonTapped
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(inputSearchText)
            .asDriver(onErrorJustReturn: "")
            .distinctUntilChanged()
            .drive(with: self) { owner, value in
                print("검색 버튼 클릭 ", value)
                let item = owner.items.value
                let result = value.isEmpty ? item : item.filter { $0.todo.contains(value) }
                owner.outputItem.accept(result)
            }
            .disposed(by: disposeBag)
        
        
        Observable.zip(inputTableViewSelected, inputTableViewSelectedItem)
            .bind(with: self) { owner, value in
                let row = value.0.row
                let item = value.1
                
                var data = owner.items.value
                data.remove(at: row)
                owner.outputItem.accept(data)
                
//                owner.showAlert(text: item.todo)
            }
            .disposed(by: disposeBag)

    }
}
