//
//  NicknameViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class NicknameViewController: UIViewController {
   
    let nicknameTextField = SignTextField(placeholderText: "닉네임을 입력해주세요")
    let nextButton = PointButton(title: "다음")
    
    let viewModel = NicknameViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
       
        bind()
    }
    
    private func bind() {
//        nextButton.rx.tap
//            .bind(to: viewModel.inputNextButton)
//            .disposed(by: disposeBag)
//        
//        viewModel.outputNextButton
//            .bind(with: self){ owner, _ in
//                owner.navigationController?.pushViewController(BirthdayViewController(), animated: true)
//            }
//            .disposed(by: disposeBag)
//        
//        nicknameTextField.rx.text.orEmpty
//            .bind(to: viewModel.inputNickname)
//            .disposed(by: disposeBag)
//            
//        viewModel.outputValidation
//            .bind(to: nextButton.rx.isEnabled)
//            .disposed(by: disposeBag)
//        
//        viewModel.outputValidation
//            .bind(with: self) { owner, value in
//                let color = value ? UIColor.systemPink : UIColor.gray
//                owner.nextButton.backgroundColor = color
//                let text = value ? "다음" : "3글자 이상 입력해주세요"
//                owner.nextButton.setTitle(text, for: .normal)
//            }
//            .disposed(by: disposeBag)
        
        let input = NicknameViewModel.Input(tap: nextButton.rx.tap, text: nicknameTextField.rx.text)
        let output = viewModel.transform(input: input)
        
        output.tap
            .bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(BirthdayViewController(), animated: true)
            }
            .disposed(by: disposeBag)
        
        output.text
            .drive(nextButton.rx.title())
            .disposed(by: disposeBag)
        
        output.validation
            .drive(nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.validation
            .drive(with: self) { owner, value in
                let color = value ? UIColor.systemPink : UIColor.gray
                owner.nextButton.backgroundColor = color
                let text = value ? "다음" : "3글자 이상 입력해주세요"
                owner.nextButton.setTitle(text, for: .normal)
            }
            .disposed(by: disposeBag)

    }

    
    func configureLayout() {
        view.addSubview(nicknameTextField)
        view.addSubview(nextButton)
         
        nicknameTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(nicknameTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

}
