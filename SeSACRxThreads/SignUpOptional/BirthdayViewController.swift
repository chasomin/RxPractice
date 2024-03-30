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
    
    let yearText = PublishSubject<Int>()
    let monthText = PublishSubject<Int>()
    let dayText = PublishSubject<Int>()

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Color.white
        
        configureLayout()
        bind()
    }
    
    private func bind() {
        // Subscribe
        yearText
            .map { "\($0)년"}
            .bind(to: yearLabel.rx.text)
            .disposed(by: disposeBag)
        
        monthText
            .map { "\($0)월"}
            .bind(to: monthLabel.rx.text)
            .disposed(by: disposeBag)
        
        dayText
            .map { "\($0)일" }
            .bind(to: dayLabel.rx.text)
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .bind(onNext: { _ in
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                
                let sceneDelegate = windowScene?.delegate as? SceneDelegate
                
                let nav = UINavigationController(rootViewController: SampleViewController())
                
                sceneDelegate?.window?.rootViewController = nav
                sceneDelegate?.window?.makeKeyAndVisible()

            })
            .disposed(by: disposeBag)

        birthDayPicker.rx.date
            .bind(with: self) { owner, date in
                let component = Calendar.current.dateComponents([.year, .month, .day], from: date)
                // Emit
                owner.yearText.onNext(component.year!)
                owner.monthText.on(.next(component.month!))
                owner.dayText.onNext(component.day!)
            }
            .disposed(by: disposeBag)
        
        // Observable
        let validation = birthDayPicker.rx.date
            .map {
                let selectDate = Calendar.current.dateComponents([.year], from: $0)
                let today = Calendar.current.dateComponents([.year], from: Date())
                return (today.year! - selectDate.year!) >= 17
            }
        
        // Observer
        validation
            .bind(with: self) { owner, value in
                let text = value ? "가입 가능한 나이입니다" : "만 17세 이상만 가입 가능합니다"
                owner.infoLabel.text = text
                let textColor = value ? UIColor.systemBlue : UIColor.systemRed
                let buttonColor = value ? UIColor.systemBlue : UIColor.gray
                owner.infoLabel.textColor = textColor
                owner.nextButton.backgroundColor = buttonColor
            }
            .disposed(by: disposeBag)
        
        validation
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
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
