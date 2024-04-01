//
//  ShoppingViewController.swift
//  SeSACRxThreads
//
//  Created by 차소민 on 4/1/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ShoppingViewController: UIViewController {
    private let textField = UITextField()
    private let addButton = UIButton()
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    
    private var data = [ShoppingData(todo: "커피 구매"), ShoppingData(todo: "지갑 구매"), ShoppingData( todo: "비타민 구매")]
    private lazy var items = BehaviorSubject(value: data)
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        bind()
    }
    
    private func bind() {
        items
            .bind(to: tableView.rx.items(cellIdentifier: ShoppingTableViewCell.id, cellType: ShoppingTableViewCell.self)) { [weak self] (row, element, cell) in
                guard let self else { return }
                cell.configureCell(element: element)
                
                cell.checkButton.rx.tap
                    .bind(with: self) { owner, _ in
                        owner.data[row].check.toggle()
                        owner.items.onNext(owner.data)
                    }
                    .disposed(by: cell.disposeBag)
                
                cell.bookMarkButton.rx.tap
                    .bind(with: self) { owner, _ in
                        owner.data[row].bookMark.toggle()
                        owner.items.onNext(owner.data)
                    }
                    .disposed(by: cell.disposeBag)

                cell.moveButton.rx.tap
                    .bind(with: self) { owner, _ in
                        owner.navigationController?.pushViewController(BirthdayViewController(), animated: true)
                    }
                    .disposed(by: cell.disposeBag)

                cell.editButton.rx.tap
                    .withLatestFrom(self.textField.rx.text.orEmpty)
                    .bind(with: self) { owner, value in
                        owner.data[row].todo = value
                        owner.items.onNext(owner.data)
                    }
                    .disposed(by: cell.disposeBag)

            }
            .disposed(by: disposeBag)
        
        addButton.rx.tap
            .withLatestFrom(textField.rx.text.orEmpty)
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                owner.data.insert(ShoppingData(todo: value), at: 0)
                owner.items.onNext(owner.data)
                owner.textField.text = ""
            }
            .disposed(by: disposeBag)
        
        searchBar.rx.text.orEmpty
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                print("실시간 검색 ", value)
                let result = value.isEmpty ? owner.data : owner.data.filter { $0.todo.contains(value) }
                owner.items.onNext(result)
            }
            .disposed(by: disposeBag)
        
        searchBar.rx.searchButtonClicked
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(searchBar.rx.text.orEmpty)
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                print("검색 버튼 클릭 ", value)
                let result = value.isEmpty ? owner.data : owner.data.filter { $0.todo.contains(value) }
                owner.items.onNext(result)
            }
            .disposed(by: disposeBag)
        
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(ShoppingData.self))
            .bind(with: self) { owner, value in
                let row = value.0.row
                let item = value.1
                
                owner.data.remove(at: row)
                owner.items.onNext(owner.data)
                
                owner.showAlert(text: item.todo)
            }
            .disposed(by: disposeBag)
    }
    
    private func configureView() {
        view.backgroundColor = .white
        navigationItem.titleView = searchBar
        
        view.addSubview(textField)
        view.addSubview(addButton)
        view.addSubview(tableView)
        
        textField.snp.makeConstraints { make in
            make.top.leading.equalTo(view.safeAreaLayoutGuide).inset(15)
            make.height.equalTo(30)
        }
        addButton.snp.makeConstraints { make in
            make.verticalEdges.equalTo(textField)
            make.leading.equalTo(textField.snp.trailing).offset(5)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(15)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(15)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(15)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        tableView.register(ShoppingTableViewCell.self, forCellReuseIdentifier: ShoppingTableViewCell.id)
        textField.placeholder = "무엇을 구매하실 건가요?"
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemPink
        config.baseForegroundColor = .white
        config.title = "추가"
        config.cornerStyle = .capsule
        addButton.configuration = config
        searchBar.placeholder = "구매 TODO 항목을 검색해보세요"
    }
}


struct ShoppingData {
    var check: Bool = false
    var todo: String
    var bookMark: Bool = false
}


extension UIViewController {
    func showAlert(text: String) {
        let alert = UIAlertController(title: "삭제", message: "\(text)가 삭제되었습니다", preferredStyle: .alert)
        let button1 = UIAlertAction(title: "확인", style: .default)
        alert.addAction(button1)
        present(alert, animated: true)
    }
}
