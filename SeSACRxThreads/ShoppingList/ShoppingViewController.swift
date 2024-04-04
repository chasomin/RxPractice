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
    
    private let disposeBag = DisposeBag()
    
    private let viewModel = ShoppingViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        bind()
    }
    
    private func bind() {
        let checkIndex = PublishRelay<Int>()
        let bookmarkIndex = PublishRelay<Int>()
        let editIndex = PublishRelay<Int>()

        let input = ShoppingViewModel.Input(addTap: addButton.rx.tap, searchTap: searchBar.rx.searchButtonClicked, addText: textField.rx.text, searchText: searchBar.rx.text, tableViewIndex: tableView.rx.itemSelected, checkIndex: checkIndex, bookmarkIndex: bookmarkIndex, editIndex: editIndex)
        let output = viewModel.transform(input: input)
        
        output
            .item
            .drive(tableView.rx.items(cellIdentifier: ShoppingTableViewCell.id, cellType: ShoppingTableViewCell.self)) { [weak self] (row, element, cell) in
                guard let self else { return }
                cell.configureCell(element: element)

                
                cell.checkButton.rx.tap
                    .bind(with: self) { owner, _ in
                        input.checkIndex.accept(row)
                    }
                    .disposed(by: cell.disposeBag)
                
                cell.bookMarkButton.rx.tap
                    .bind(with: self) { owner, _ in
                        input.bookmarkIndex.accept(row)
                    }
                    .disposed(by: cell.disposeBag)
                
                cell.moveButton.rx.tap
                    .bind(with: self) { owner, _ in
                        owner.navigationController?.pushViewController(BirthdayViewController(), animated: true)
                    }
                    .disposed(by: cell.disposeBag)
                
                cell.editButton.rx.tap
                    .withLatestFrom(self.textField.rx.text.orEmpty)
                    .bind(with: self) { owner, text in
                        input.editIndex.accept(row)
                    }
                    .disposed(by: cell.disposeBag)
                
            }
            .disposed(by: disposeBag)
    }
    
//    private func bind() {
//
//        addButton.rx.tap
//            .bind(to: viewModel.inputAddbuttonTapped)
//            .disposed(by: disposeBag)
//
//        textField.rx.text.orEmpty
//            .bind(to: viewModel.inputTextFieldText)
//            .disposed(by: disposeBag)
//
//        searchBar.rx.text.orEmpty
//            .bind(to: viewModel.inputSearchText)
//            .disposed(by: disposeBag)
//
//        searchBar.rx.searchButtonClicked
//            .bind(to: viewModel.inputSearchButtonTapped)
//            .disposed(by: disposeBag)
//
//        tableView.rx.itemSelected
//            .bind(to: viewModel.inputTableViewSelected)
//            .disposed(by: disposeBag)
//
//        tableView.rx.modelSelected(ShoppingData.self)
//            .bind(to: viewModel.inputTableViewSelectedItem)
//            .disposed(by: disposeBag)
//
//        viewModel.outputItem
//            .asDriver()
//            .drive(tableView.rx.items(cellIdentifier: ShoppingTableViewCell.id, cellType: ShoppingTableViewCell.self)) { [weak self] (row, element, cell) in
//                guard let self else { return }
//                cell.configureCell(element: element)
//
//                cell.checkButton.rx.tap
//                    .bind(with: self) { owner, _ in
//                        var item = owner.viewModel.outputItem.value
//                        item[row].check.toggle()
//                        owner.viewModel.outputItem.accept(item)
//                    }
//                    .disposed(by: cell.disposeBag)
//                
//                cell.bookMarkButton.rx.tap
//                    .bind(with: self) { owner, _ in
//                        var item = owner.viewModel.outputItem.value
//                        item[row].bookMark.toggle()
//                        owner.viewModel.outputItem.accept(item)
//                    }
//                    .disposed(by: cell.disposeBag)
//                
//                cell.moveButton.rx.tap
//                    .bind(with: self) { owner, _ in
//                        owner.navigationController?.pushViewController(BirthdayViewController(), animated: true)
//                    }
//                    .disposed(by: cell.disposeBag)
//                
//                cell.editButton.rx.tap
//                    .withLatestFrom(self.textField.rx.text.orEmpty)
//                    .bind(with: self) { owner, value in
//                        var item = owner.viewModel.outputItem.value
//                        item[row].todo = value
//                        owner.viewModel.outputItem.accept(item)
//                    }
//                    .disposed(by: cell.disposeBag)
//                
//            }
//            .disposed(by: disposeBag)
//        
//    }
    
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
