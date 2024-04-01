//
//  SearchViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2024/04/01.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {
    
    private let tableView: UITableView = {
        let view = UITableView()
        view.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.identifier)
        view.backgroundColor = .white
        view.rowHeight = 180
        view.separatorStyle = .none
        return view
    }()
    
    let searchBar = UISearchBar()
    
    var data = ["A", "B", "C", "AB", "D", "ABC", "BBB", "EC", "SA", "AAAB", "ED", "F", "G", "H"]
    
    lazy var items = BehaviorSubject(value: data)
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        configure()
        setSearchController()
        bind()
    }
    
    private func bind() {
        items
            .bind(to: tableView.rx.items(cellIdentifier: SearchTableViewCell.identifier, cellType: SearchTableViewCell.self)) { (row, element, cell) in
                cell.configureCell(element: element)

                cell.downloadButton.rx.tap
                    .throttle(.seconds(2), scheduler: MainScheduler.instance)
                    .bind(with: self) { owner, _ in
                        print("download")
                        owner.navigationController?.pushViewController(BirthdayViewController(), animated: true)
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(String.self))
            .bind(with: self) { owner, value in
                let row = value.0.row
                let item = value.1
                owner.data.remove(at: row)
                print("\(item) 삭제")
                owner.items.onNext(owner.data)
            }
            .disposed(by: disposeBag)
        
        searchBar.rx.text.orEmpty
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
        // distinctUntilChanged가 debounce 보다 위에 있으면
        // 1초 기다리지 않고 계속 반영돼서 값이 계속 바뀐다고 판단 -> 같은 값이어도 계속 검색
            .bind(with: self) { owner, value in
                print("검색: ", value)
                let result = value.isEmpty ? owner.data : owner.data.filter { $0.contains(value) }
                owner.items.onNext(result)
            }
            .disposed(by: disposeBag)
        
        searchBar.rx.searchButtonClicked
//            .debounce(.seconds(3), scheduler: MainScheduler.instance)
            .throttle(.seconds(3), scheduler: MainScheduler.instance)
            /// debounce는   버튼 클릭 -> 3초 기다림 -> 적용
            /// throttle은       버튼 클릭 -> 적용 -> 3초 기다림           ==> 버튼이랑 더 적합한 것 같다.
            .withLatestFrom(searchBar.rx.text.orEmpty)  // Void -> String 로 변경됨
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                print("검색 버튼 클릭: ", value)
                let result = value.isEmpty ? owner.data : owner.data.filter { $0.contains(value) }
                owner.items.onNext(result)
            }
            .disposed(by: disposeBag)
            
    }
    
    private func setSearchController() {
        view.addSubview(searchBar)
        navigationItem.titleView = searchBar
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "추가", style: .plain, target: self, action: #selector(plusButtonClicked))
    }
    
    @objc func plusButtonClicked() {
        let sample = ["1", "2", "3", "4", "5"]
        data.insert(sample.randomElement()!, at: 0)
        items.on(.next(data))
    }
    
    
    private func configure() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
    }
}
