//
//  SampleViewController.swift
//  SeSACRxThreads
//
//  Created by 차소민 on 3/31/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SampleViewController: UIViewController {
    private let tableView = UITableView()
    private let okButton = UIButton()
    private let textField = UITextField()
    
    private var items = BehaviorSubject(value: ["item1"])
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
    }
    
    private func bind() {
        okButton.rx.tap
            .bind(with: self) { owner, _ in
                var currentItems = try! owner.items.value()
                currentItems.append(owner.textField.text!)
                owner.items.onNext(currentItems)
            }
            .disposed(by: disposeBag)
        
        items
            .bind(to: tableView.rx.items) { (tableView, row, element) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
                cell.textLabel?.text = "\(element) @ row \(row)"
                return cell
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .bind(with: self) { owner, indexpath in
                var currentItems = try! owner.items.value()
                currentItems.remove(at: indexpath.row)
                owner.items.onNext(currentItems)
            }
            .disposed(by: disposeBag)
            
    }

    private func configureView() {
        view.backgroundColor = .white
        view.addSubview(textField)
        view.addSubview(okButton)
        view.addSubview(tableView)
        textField.snp.makeConstraints { make in
            make.top.leading.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
        okButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(textField)
            make.leading.equalTo(textField.snp.trailing)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        textField.borderStyle = .roundedRect
        textField.placeholder = "textfield"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        okButton.setTitle("추가", for: .normal)
        okButton.setTitleColor(.black, for: .normal)
    }

}
