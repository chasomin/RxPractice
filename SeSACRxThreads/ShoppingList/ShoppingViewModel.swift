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
    private let baseItem = BehaviorRelay(value: [ShoppingData(todo: "커피 구매"), ShoppingData(todo: "지갑 구매"), ShoppingData( todo: "비타민 구매")])
    private lazy var items = BehaviorRelay(value: baseItem.value)

    let disposeBag = DisposeBag()

    struct Input {
        let addTap: ControlEvent<Void>
        let searchTap: ControlEvent<Void>
        let addText: ControlProperty<String?>
        let searchText: ControlProperty<String?>
        let tableViewIndex: ControlEvent<IndexPath>
        let checkIndex: PublishRelay<Int>
        let bookmarkIndex: PublishRelay<Int>
        let editIndex: PublishRelay<Int>
    }
    
    struct Output {
        let item: Driver<[ShoppingData]>
    }
    
    func transform(input: Input) -> Output {
        input.checkIndex
            .bind(with: self, onNext: { owner, row in
                var item = owner.items.value
                item[row].check.toggle()
                owner.items.accept(item)

            })
            .disposed(by: disposeBag)
        
        input.bookmarkIndex
            .bind(with: self) { owner, row in
                var item = owner.items.value
                item[row].bookMark.toggle()
                owner.items.accept(item)
            }
            .disposed(by: disposeBag)
        input.editIndex
            .bind(with: self) { owner, row in
                var item = owner.items.value
                item[row].todo = "수정" //!!!: 수정
                owner.items.accept(item)
            }
            .disposed(by: disposeBag)
        
        input.addTap
            .withLatestFrom(input.addText.orEmpty)
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: "")
            .distinctUntilChanged()
            .drive(with: self) { owner, value in
                var item = owner.items.value
                item.insert(ShoppingData(todo: value), at: 0)
                owner.baseItem.accept(item)
                owner.items.accept(item)
            }
            .disposed(by: disposeBag)
        
        input.searchText.orEmpty
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: "")
            .distinctUntilChanged()
            .drive(with: self) { owner, value in
                let item = owner.baseItem.value
                let result = value.isEmpty ? item : item.filter { $0.todo.contains(value) }
                owner.items.accept(result)
            }
            .disposed(by: disposeBag)
        
        
        input.searchTap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(input.searchText.orEmpty)
            .asDriver(onErrorJustReturn: "")
            .distinctUntilChanged()
            .drive(with: self) { owner, value in
                print("검색 버튼 클릭 ", value)
                let item = owner.baseItem.value
                let result = value.isEmpty ? item : item.filter { $0.todo.contains(value) }
                owner.items.accept(result)
            }
            .disposed(by: disposeBag)
        
        
        input.tableViewIndex
            .bind(with: self) { owner, value in
                let row = value.row
                var data = owner.items.value
                data.remove(at: row)
                owner.items.accept(data)
                
            }
            .disposed(by: disposeBag)

        return Output(item: items.asDriver())
        
    }
}
