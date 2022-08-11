//
//  SourceTextViewController.swift
//  Translate
//
//  Created by 정유진 on 2022/04/28.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

protocol SourceTextViewDelegate: AnyObject {
    func submitSourceText(source: String)
}

class SourceTextViewController: UIViewController {
    
    var viewModel: SourceTextViewModel?
    let disposeBag = DisposeBag()
    private let placeholderText = "텍스트 입력"
    private weak var delegate: SourceTextViewDelegate?
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.text = placeholderText
        textView.textColor = .tertiaryLabel
        textView.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        textView.returnKeyType = .done
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attribute()
        layout()
    }
    
    init(delegate: SourceTextViewDelegate?) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(_ viewModel: SourceTextViewModel){
        self.viewModel = viewModel
        
        // textview 에 text가 입력될 때마다 bind
        textView.rx.text
            .bind(to: viewModel.sourceTextViewContent)
            .disposed(by: disposeBag)
    }
    
    func attribute() {
        view.backgroundColor = .systemBackground
    }
    
    func layout() {
        view.addSubview(textView)
        textView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
    }
}

extension SourceTextViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text == "\n" else { return true }
        //vc.submitSourceText(source: textView.text)
        
        //rx
        if let sourceViewModel = self.viewModel {
            Observable.just("tapped")
                .bind(to: sourceViewModel.doneButtonTapped)
                .disposed(by: disposeBag)
        }
   
        
        dismiss(animated: true, completion: nil)
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView.textColor == .tertiaryLabel else { return }
        textView.text = ""
        textView.textColor = .label
    }
 
}


