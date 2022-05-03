//
//  TranslateViewController.swift
//  Translate
//
//  Created by 정유진 on 2022/04/27.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class TranslateViewController: UIViewController {
    
    let viewModel = TranslateViewModel()
    let disposeBag = DisposeBag()
    let sourcePlaceholderText = "텍스트 입력"
    //var languageButtonTitle: String = ""
    
    private lazy var sourceButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 9
        button.backgroundColor = .systemBackground
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: .semibold)
        button.addTarget(self, action: #selector(didTapSourceButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var targetButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 9
        button.backgroundColor = .systemBackground
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: .semibold)
        button.addTarget(self, action: #selector(didTapTargetButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        [sourceButton, targetButton].forEach {
            stackView.addArrangedSubview($0)
        }
        return stackView
    }()
    
    private lazy var resultBaseView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var sourceBaseView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapSourceBaseView))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
        return view
    }()
    
    private lazy var resultTextLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var sourceTextLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = sourcePlaceholderText
        label.textColor = .tertiaryLabel
        label.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        return label
    }()
    
    private lazy var bookmarkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        button.setImage(UIImage(systemName: "bookmark.fill"), for: .selected)
        return button
    }()
    
    private lazy var copyButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        button.setImage(UIImage(systemName: "doc.on.doc.fill"), for: .selected)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        bind(viewModel)
        attribute()
        layout()
    }
    
    private func bind(_ viewModel: TranslateViewModel){
        viewModel.sourceLabelText
            .drive(self.rx.presentText)
            .disposed(by: disposeBag)
        
        viewModel.languageList
            .emit(to: self.rx.presentAlertViewController)
            .disposed(by: disposeBag)
        
        viewModel.changeLanguageButton
            .emit(to: self.rx.changeLanguageButton)
            .disposed(by: disposeBag)
    }
    
    private func attribute(){
        view.backgroundColor = .secondarySystemBackground
        
        let topAttributes : [NSAttributedString.Key : Any] = [
            .font : UIFont.systemFont(ofSize: 23, weight: .bold),
            .foregroundColor: UIColor.mainTintColor
        ]
        let resultText = "I would like my steak medium rare and add some coke please"
        resultTextLabel.attributedText = NSAttributedString(string: resultText, attributes: topAttributes)
        
        sourceButton.setTitle(viewModel.sourceLanguage.value.title, for: .normal)
        targetButton.setTitle(viewModel.targetLanguage.value.title, for: .normal)
    }
    
    @objc func didTapSourceBaseView() {
        let vc = SourceTextViewController(delegate: self)
        vc.bind(viewModel.sourceTextViewModel)
        present(vc, animated: true, completion: nil)
    }
    
    func presentSourceText(source: String) {
        if source != "" {
            sourceTextLabel.text = source
            sourceTextLabel.textColor = .label
        } else {
            sourceTextLabel.text = sourcePlaceholderText
            sourceTextLabel.textColor = .tertiaryLabel
        }
    }
    
    func setSourceButtonText(from text: String) {
        if let type = LanguageType.allCases.filter({ $0.rawValue == text}).first {
            sourceButton.setTitle(type.title, for: .normal)
            Observable.just(type)
                .bind(to: viewModel.sourceLanguage)
                .disposed(by: disposeBag)
        }
        
    }
    
    func setTargetButtonText(from text:String) {
        if let type = LanguageType.allCases.filter({ $0.rawValue == text}).first {
            targetButton.setTitle(type.title, for: .normal)
            Observable.just(type)
                .bind(to: viewModel.targetLanguage)
                .disposed(by: disposeBag)
        }
    }
    
}

private extension TranslateViewController {
    private func layout() {
        let defaultSpacing: CGFloat = 16.0
        
        [
            buttonStackView,
            resultBaseView,
            resultTextLabel,
            bookmarkButton,
            copyButton,
            sourceBaseView,
            sourceTextLabel
        ].forEach {
            view.addSubview($0)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalToSuperview().inset(defaultSpacing)
            $0.trailing.equalToSuperview().inset(defaultSpacing)
            $0.height.equalTo(50)
        }
        
        resultBaseView.snp.makeConstraints {
            $0.top.equalTo(buttonStackView.snp.bottom).offset(defaultSpacing)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(bookmarkButton.snp.bottom).offset(defaultSpacing)
        }
        
        resultTextLabel.snp.makeConstraints {
            $0.leading.equalTo(resultBaseView.snp.leading).inset(24)
            $0.top.equalTo(resultBaseView.snp.top).inset(24)
            $0.trailing.equalTo(resultBaseView.snp.trailing).inset(24)
        }
        
        bookmarkButton.snp.makeConstraints {
            $0.leading.equalTo(resultTextLabel.snp.leading)
            $0.top.equalTo(resultTextLabel.snp.bottom).offset(24)
            $0.width.equalTo(40)
            $0.height.equalTo(40)
        }
        
        copyButton.snp.makeConstraints {
            $0.leading.equalTo(bookmarkButton.snp.trailing).offset(8)
            $0.top.equalTo(bookmarkButton.snp.top)
            $0.width.equalTo(40)
            $0.height.equalTo(40)
        }
        
        sourceBaseView.snp.makeConstraints {
            $0.top.equalTo(resultBaseView.snp.bottom).offset(defaultSpacing)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(tabBarController?.tabBar.frame.height ?? 0)
        }
        
        sourceTextLabel.snp.makeConstraints {
            $0.top.equalTo(sourceBaseView.snp.top).inset(24)
            $0.leading.equalTo(resultTextLabel.snp.leading)
            $0.trailing.equalTo(resultTextLabel.snp.trailing)
        }
        
        
    }
}

extension TranslateViewController: SourceTextViewDelegate {
    func submitSourceText(source: String) {
//        sourceTextLabel.text = source
//        sourceTextLabel.textColor = .label
    }
    
    @objc func didTapSourceButton() {
        Observable.just("source")
            .bind(to: viewModel.tapLanguageButton)
            .disposed(by: disposeBag)
    }
    
    @objc func didTapTargetButton() {
        Observable.just("target")
            .bind(to: viewModel.tapLanguageButton)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: UIAlertAction {
    
}

extension Reactive where Base: TranslateViewController {
    var presentText: Binder<String> {
        return Binder(base) { base, text in
            base.presentSourceText(source: text)
        }
    }
    
    var changeLanguageButton: Binder<LanguageOption> {
        return Binder(base) { base, option in
            if option.type == "source" {
                base.setSourceButtonText(from: option.title)
            } else if option.type == "target" {
                base.setTargetButtonText(from: option.title)
            }
        }
    }
    
    var presentAlertViewController: Binder<[LanguageType]> {
        return Binder(base) { base, languageList in
            let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let callback: ((UIAlertAction)->Void)  = { action in
                //base.languageButtonTitle = action.title!
                Observable.just(action.title!)
                    .bind(to: base.viewModel.tapAlertActionSheetLanguage)
                    .disposed(by: base.disposeBag)
            }
            
            languageList.forEach {
                let action = UIAlertAction(title: $0.rawValue, style: .default, handler: callback)
                alertViewController.addAction(action)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertViewController.addAction(cancelAction)
            
            base.present(alertViewController, animated: true, completion: nil)
        }
    }
}
