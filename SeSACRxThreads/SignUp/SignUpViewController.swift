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
    
    let disposeBag = DisposeBag()
    
    private let viewModel = SignUpViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
        configure()
        bind()
    }
    
    private func bind() {
        nextButton.rx.tap
            .bind(to: viewModel.inputNextButtonTapped)
            .disposed(by: disposeBag)
        
        viewModel.outputNextButtonTapped
            .asDriver(onErrorJustReturn: ())
            .drive(with: self, onNext: { owner, _ in
                owner.navigationController?.pushViewController(PasswordViewController(), animated: true)
            })
            .disposed(by: disposeBag)
        
        
        emailTextField.rx.text.orEmpty
            .bind(to: viewModel.inputEmailText)
            .disposed(by: disposeBag)
        
        viewModel.outputValidText
            .asDriver(onErrorJustReturn: "")
            .drive(with: self) { owner, value in
                owner.nextButton.setTitle(value, for: .normal)
            }
            .disposed(by: disposeBag)
        
        viewModel.outputValidStatus
            .asDriver(onErrorJustReturn: false)
            .drive(with: self) { owner, value in
                let color = value ? UIColor.systemBlue : UIColor.gray
                owner.nextButton.backgroundColor = color
            }
            .disposed(by: disposeBag)
        
        viewModel.availableEmail
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)

        validationButton.rx.tap
            .bind(to: viewModel.inputValidationButtonTapped)
            .disposed(by: disposeBag)
        
        viewModel.outputAllValidation
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
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
