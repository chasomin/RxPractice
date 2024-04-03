//
//  ShoppingTableViewCell.swift
//  SeSACRxThreads
//
//  Created by 차소민 on 4/1/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ShoppingTableViewCell: UITableViewCell {
    static let id = ShoppingTableViewCell.description()

    let checkButton = UIButton()
    let todoLabel = UILabel()
    let bookMarkButton = UIButton()
    let moveButton = UIButton()
    let editButton = UIButton()
    
    var disposeBag = DisposeBag()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func configureCell(element: ShoppingData) {
        todoLabel.text = element.todo
        element.check ? checkButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal) : checkButton.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
        element.bookMark ? bookMarkButton.setImage(UIImage(systemName: "star.fill"), for: .normal) : bookMarkButton.setImage(UIImage(systemName: "star"), for: .normal)
    }
    
    private func configureView() {
        selectionStyle = .none
        
        contentView.addSubview(checkButton)
        contentView.addSubview(todoLabel)
        contentView.addSubview(bookMarkButton)
        contentView.addSubview(moveButton)
        contentView.addSubview(editButton)
        
        checkButton.snp.makeConstraints { make in
            make.leading.verticalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(15)
            make.width.equalTo(checkButton.snp.height)
        }
        todoLabel.snp.makeConstraints { make in
            make.leading.equalTo(checkButton.snp.trailing).offset(15)
            make.centerY.equalTo(contentView)
        }
        bookMarkButton.snp.makeConstraints { make in
            make.leading.equalTo(todoLabel.snp.trailing).offset(15)
            make.centerY.equalTo(contentView)
        }
        editButton.snp.makeConstraints { make in
            make.leading.equalTo(bookMarkButton.snp.trailing).offset(15)
            make.centerY.equalTo(contentView)
        }
        moveButton.snp.makeConstraints { make in
            make.leading.equalTo(editButton.snp.trailing).offset(15)
            make.trailing.equalTo(contentView).inset(15)
            make.centerY.equalTo(contentView)
        }

        
        checkButton.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
        bookMarkButton.setImage(UIImage(systemName: "star"), for: .normal)
        moveButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        editButton.setImage(UIImage(systemName: "pencil"), for: .normal)
    }
}
