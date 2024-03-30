//
//  SignUpViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class SignUpViewController: UIViewController {

    let emailTextField = SignTextField(placeholderText: "이메일을 입력해주세요")
    let validationButton = UIButton()
    let nextButton = PointButton(title: "다음")
    
    let userEmail = ["a@a.com", "b@b.com"]
    let disposeBag = DisposeBag()
    let availableEmail = BehaviorSubject(value: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
        configure()
        bind()
    }
    
    private func bind() {
        nextButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(PasswordViewController(), animated: true)
            }
            .disposed(by: disposeBag)
        
        let userEmailValid = emailTextField.rx.text.orEmpty
            .map { $0.count >= 7 }
        userEmailValid
            .bind(with: self) { owner, value in
                let text = value ? "중복 확인 해주세요" : "7자 이상 입력해주세요"
                owner.nextButton.setTitle(text, for: .normal)
            }
            .disposed(by: disposeBag)
        
        availableEmail
            .bind(with: self) { owner, value in
                let text = value ? "사용 가능한 이메일" : "사용 불가능한 이메일"
                owner.nextButton.setTitle(text, for: .normal)
                let color = value ? UIColor.systemBlue : UIColor.gray
                owner.nextButton.backgroundColor = color
            }
            .disposed(by: disposeBag)
        
        availableEmail
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        validationButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.availableEmail.onNext(!owner.userEmail.contains(owner.emailTextField.text!))
            }
            .disposed(by: disposeBag)
        
        let everythingValid = Observable.combineLatest(userEmailValid, availableEmail) { $0 && $1 }
        
    }
        
    func configure() {
        validationButton.setTitle("중복확인", for: .normal)
        validationButton.setTitleColor(Color.black, for: .normal)
        validationButton.layer.borderWidth = 1
        validationButton.layer.borderColor = Color.black.cgColor
        validationButton.layer.cornerRadius = 10
    }
    
    func configureLayout() {
        view.addSubview(emailTextField)
        view.addSubview(validationButton)
        view.addSubview(nextButton)
        
        validationButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.width.equalTo(100)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.trailing.equalTo(validationButton.snp.leading).offset(-8)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(emailTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    

}
