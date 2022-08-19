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
import CoreData
import AVFoundation

class TranslateViewController: UIViewController, SourceTextViewDelegate {
   
    var viewModel: TranslateViewModel!
    let disposeBag = DisposeBag()
    let sourcePlaceholderText = "번역할 텍스트 입력..."
    
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
    
    private lazy var shiftarrow: UIView = {
        let view = UIView()
        let image = UIImageView(image: UIImage(systemName: "arrow.right.circle"))
        view.addSubview(image)
        image.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
            $0.width.equalTo(24)
        }
        return view
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        [sourceButton, shiftarrow, targetButton].forEach {
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
        button.toolTip = "bookmark"
        button.addTarget(self, action: #selector(didTapBookmarkButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var copyButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        button.setImage(UIImage(systemName: "doc.on.doc.fill"), for: .selected)
        button.toolTip = "copy on clipboard"
        button.addTarget(self, action: #selector(didTapCopyButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var voiceButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "speaker.wave.2"), for: .normal)
        button.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .selected)
        button.toolTip = "text to speech"
        button.addTarget(self, action: #selector(didTapSpeechButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var recordButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "mic.badge.plus"), for: .normal)
        button.setImage(UIImage(systemName: "mic.fill.badge.plus"), for: .selected)
        button.addTarget(self, action: #selector(didTapRecordButton), for: .touchUpInside)
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 10.0
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        attribute()
        layout()
    }
    
    func bind(_ model: TranslateViewModel){
        viewModel = model
        viewModel.sourceLabelText
            .drive(self.rx.presentSource)
            .disposed(by: disposeBag)
        
        viewModel.targetLabelText
            .drive(self.rx.presentResult)
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
        sourceButton.setTitle(viewModel.sourceLanguage.value.title, for: .normal)
        targetButton.setTitle(viewModel.targetLanguage.value.title, for: .normal)
    }
    
    func submitSourceText(source: String) {
        // delegate pattern => rxSwift 로 대체
    }
    
    private func layout() {
        let defaultSpacing: CGFloat = 16.0
        
        [
            buttonStackView,
            resultBaseView,
            resultTextLabel,
            bookmarkButton,
            copyButton,
            voiceButton,
            sourceBaseView,
            sourceTextLabel,
            recordButton
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
        
        voiceButton.snp.makeConstraints {
            $0.leading.equalTo(copyButton.snp.trailing).offset(8)
            $0.top.equalTo(copyButton.snp.top)
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
        
        recordButton.snp.makeConstraints {
            $0.trailing.equalTo(sourceBaseView.snp.trailing).inset(16)
            $0.bottom.equalTo(sourceBaseView.snp.bottom).inset(64)
            $0.width.equalTo(80)
            $0.height.equalTo(80)
        }
    }
    
    // rx 관련 함수들
    func presentSourceText(source: String) {
        if source != "" {
            sourceTextLabel.text = source
            sourceTextLabel.textColor = .label
        } else {
            sourceTextLabel.text = sourcePlaceholderText
            sourceTextLabel.textColor = .tertiaryLabel
        }
    }
    
    func presentResultText(result: String) {
        if result != "" {
            let topAttributes : [NSAttributedString.Key : Any] = [
                .font : UIFont.systemFont(ofSize: 23, weight: .bold),
                .foregroundColor: UIColor.mainTintColor
            ]
            let resultText = result
            resultTextLabel.attributedText = NSAttributedString(string: resultText, attributes: topAttributes)
        }
    }
    
    func setSourceButtonText(from language: LanguageType) {
        sourceButton.setTitle(language.title, for: .normal)
        Observable.just(language)
            .bind(to: viewModel.sourceLanguage)
            .disposed(by: disposeBag)
    }
    
    func setTargetButtonText(from language: LanguageType) {
        targetButton.setTitle(language.title, for: .normal)
        Observable.just(language)
            .bind(to: viewModel.targetLanguage)
            .disposed(by: disposeBag)
    }
}

extension TranslateViewController: UIToolTipInteractionDelegate {
    
    // 이벤트 리스너 함수
    @objc func didTapSourceBaseView() {
        let vc = SourceTextViewController(delegate: self)
        vc.bind(viewModel.sourceTextViewModel)
        present(vc, animated: true, completion: nil)
    }
    
    @objc func didTapSourceButton() {
        Observable.just(ButtonType.source)
            .bind(to: viewModel.tapLanguageButton)
            .disposed(by: disposeBag)
    }
    
    @objc func didTapTargetButton() {
        Observable.just(ButtonType.target)
            .bind(to: viewModel.tapLanguageButton)
            .disposed(by: disposeBag)
    }
    
    @objc func didTapBookmarkButton() {
        // validation (번역 결과물이 존재할 때 bookmark에 저장한다.)
        if let _sourceText = sourceTextLabel.text,
           _sourceText != sourcePlaceholderText,
           let _targetText = resultTextLabel.text,
           _targetText != ""
        {
            let bookmark = Bookmark(_sourceLanguage: viewModel.sourceLanguage.value.title,
                                    _targetLanguage: viewModel.targetLanguage.value.title,
                                    _sourceContent: _sourceText,
                                    _targetContent: _targetText)
            Observable.just(bookmark)
                .bind(to: viewModel.tapBookmarkButton)
                .disposed(by: disposeBag)
        }
        
        // 화면 이동
        if let tabBarController = tabBarController {
            tabBarController.selectedIndex = 1
        }
       
    }
    
    @objc func didTapCopyButton() {
        // copy해서 clipboard에 paste 가능하게
        if let translatedText = resultTextLabel.text {
            UIPasteboard.general.string = translatedText
            let firstActivityItem = "번역 결과를 친구에게 공유해보자."
            let secondActivityItem = translatedText
            
            let activityViewController: UIActivityViewController = UIActivityViewController(
                activityItems: [
                    firstActivityItem,
                    secondActivityItem
                ],
                applicationActivities: nil)
            
            activityViewController.activityItemsConfiguration = [
                UIActivity.ActivityType.message
            ] as? UIActivityItemsConfigurationReading
            
            activityViewController.excludedActivityTypes = [
                .copyToPasteboard,
                .message,
                .airDrop,
            ]
            
            activityViewController.isModalInPresentation = true
            self.present(activityViewController, animated: true)
        }
    }
    
    @objc func didTapSpeechButton() {
        // text to speech
        if let translatedText = resultTextLabel.text {
            let speechSynthesizer = SpeechSynthesizer(text: translatedText,
                                                      languageType: viewModel.targetLanguage.value)
            speechSynthesizer.speak()
        }
    }
    
    @objc func didTapRecordButton() {
        let vc = RecorderViewController()
        vc.bind(viewModel.recorderViewModel)
        present(vc, animated: true, completion: nil)
    }
}


// rx 확장
extension Reactive where Base: TranslateViewController {
    var presentSource: Binder<String> {
        return Binder(base) { base, text in
            base.presentSourceText(source: text)
        }
    }
    
    var presentResult: Binder<String> {
        return Binder(base) { base, text in
            base.presentResultText(result: text)
        }
    }
    
    var changeLanguageButton: Binder<ButtonStyle> {
        return Binder(base) { base, buttonStyle in
            if buttonStyle.type == .source {
                base.setSourceButtonText(from: buttonStyle.label)
            } else if buttonStyle.type == .target {
                base.setTargetButtonText(from: buttonStyle.label)
            }
        }
    }
    
    var presentAlertViewController: Binder<[LanguageType]> {
        return Binder(base) { base, languageList in
            let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let callback: ((UIAlertAction)->Void)  = { action in
                guard let language = action.title?.convertRawToLanguageType()
                else { return }
                Observable.just(language)
                    .bind(to: base.viewModel.tapAlertActionSheetLanguage)
                    .disposed(by: base.disposeBag)
            }
            
            // language type의 rawValue => action의 title
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
