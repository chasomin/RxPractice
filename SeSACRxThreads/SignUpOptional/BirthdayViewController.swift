//
//  BirthdayViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//
 
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class BirthdayViewController: UIViewController {
    
    let birthDayPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko-KR")
        picker.maximumDate = Date()
        return picker
    }()
    
    let infoLabel: UILabel = {
       let label = UILabel()
        label.textColor = Color.black
//        label.text = "만 17세 이상만 가입 가능합니다."
        return label
    }()
    
    let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 10 
        return stack
    }()
    
    let yearLabel: UILabel = {
       let label = UILabel()
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
    
    let monthLabel: UILabel = {
       let label = UILabel()
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
    
    let dayLabel: UILabel = {
       let label = UILabel()
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
  
    let nextButton = PointButton(title: "가입하기")
    
    let disposeBag = DisposeBag()
    
    private let viewModel = BirthdayViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Color.white
        
        configureLayout()
        bind()
    }
    
    private func bind() {
        let input = BirthdayViewModel.Input(nextButtonTap: nextButton.rx.tap, birthday: birthDayPicker.rx.date)
        let output = viewModel.transform(input: input)
        
        output.year
            .drive(yearLabel.rx.text)
            .disposed(by: disposeBag)

        output.month
            .drive(monthLabel.rx.text)
            .disposed(by: disposeBag)

        output.day
            .drive(dayLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.tap
            .bind(with: self) { owner, _ in
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                let sceneDelegate = windowScene?.delegate as? SceneDelegate
                let nav = UINavigationController(rootViewController: ShoppingViewController())
                sceneDelegate?.window?.rootViewController = nav
                sceneDelegate?.window?.makeKeyAndVisible()
            }
            .disposed(by: disposeBag)
        
        output.validation
            .drive(nextButton.rx.isEnabled)
            .disposed(by: disposeBag)

        output.validation
            .drive(with: self) { owner, value in
                let color = value ? UIColor.systemPink : UIColor.gray
                owner.nextButton.backgroundColor = color
            }
            .disposed(by: disposeBag)
        
        output.description
            .drive(infoLabel.rx.text)
            .disposed(by: disposeBag)
    }
//    private func bind() {
//        viewModel.outputYearLabel
//            .asDriver(onErrorJustReturn: "")
//            .drive(yearLabel.rx.text)
//            .disposed(by: disposeBag)
//        
//        viewModel.outputMonthLabel
//            .asDriver(onErrorJustReturn: "")
//            .drive(monthLabel.rx.text)
//            .disposed(by: disposeBag)
//
//        viewModel.outputDayLabel
//            .asDriver(onErrorJustReturn: "")
//            .drive(dayLabel.rx.text)
//            .disposed(by: disposeBag)
//        
//        viewModel.outputNextButtonTapped
//            .asDriver(onErrorJustReturn: ())
//            .drive(onNext: { _ in
//                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
//                
//                let sceneDelegate = windowScene?.delegate as? SceneDelegate
//                
//                let nav = UINavigationController(rootViewController: SampleViewController())
//                
//                sceneDelegate?.window?.rootViewController = nav
//                sceneDelegate?.window?.makeKeyAndVisible()
//            })
//            .disposed(by: disposeBag)
//            
//        nextButton.rx.tap
//            .bind(to: viewModel.inputNextButtonTapped)
//            .disposed(by: disposeBag)
//        
//
//        birthDayPicker.rx.date
//            .bind(to: viewModel.inputPicker)
//            .disposed(by: disposeBag)
//        
//        viewModel.outputInfoLabelText
//            .bind(to: infoLabel.rx.text)
//            .disposed(by: disposeBag)
//        
//        viewModel.outputValidation
//            .asDriver()
//            .drive(with: self) { owner, value in
//                let textColor = value ? UIColor.systemBlue : UIColor.systemRed
//                let buttonColor = value ? UIColor.systemBlue : UIColor.gray
//                owner.infoLabel.textColor = textColor
//                owner.nextButton.backgroundColor = buttonColor
//                owner.nextButton.isEnabled = value
//            }
//            .disposed(by: disposeBag)
//    }
    
    func configureLayout() {
        view.addSubview(infoLabel)
        view.addSubview(containerStackView)
        view.addSubview(birthDayPicker)
        view.addSubview(nextButton)
 
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(150)
            $0.centerX.equalToSuperview()
        }
        
        containerStackView.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
        }
        
        [yearLabel, monthLabel, dayLabel].forEach {
            containerStackView.addArrangedSubview($0)
        }
        
        birthDayPicker.snp.makeConstraints {
            $0.top.equalTo(containerStackView.snp.bottom)
            $0.centerX.equalToSuperview()
        }
   
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(birthDayPicker.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

}
