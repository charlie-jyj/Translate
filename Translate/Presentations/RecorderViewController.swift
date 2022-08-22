//
//  RecorderViewController.swift
//  Translate
//
//  Created by 정유진 on 2022/08/11.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Lottie

class RecorderViewController: UIViewController {
    enum RecorderStatus {
        case start
        case stop
        case cancel
        
        var label: String {
            switch self {
            case .start: return "시작하기"
            case .stop: return "번역하기"
            case .cancel: return "취소하기"
            }
        }
    }
    
    var status: RecorderStatus = .start
    var viewModel: RecorderViewModel?
    var speakerLanguage: Locale?
    private var animationView: AnimationView?
    let disposeBag = DisposeBag()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.backgroundColor = .systemBackground
        label.textColor = .label
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
   
    private lazy var recorderButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .secondarySystemBackground
        button.setTitle(status.label, for: .normal)
        button.setTitleColor(UIColor.label, for: .normal)
        button.addTarget(self, action: #selector(didTapRecorderButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemRed
        button.setTitle("취소", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attribute()
        layout()
    }
    
    func bind(_ viewModel: RecorderViewModel) {
        self.viewModel = viewModel
       
        viewModel.recordedText
            .drive(self.rx.presentRecordedText)
            .disposed(by: disposeBag)
        
    }
    
    func attribute() {
        view.backgroundColor = .systemBackground
    }
    
    func layout() {
        lottieViewLoad()
        
        [
            recorderButton,
            cancelButton,
            textLabel,
        ].forEach {
            view.addSubview($0)
        }
        
        
        recorderButton.snp.makeConstraints {
            $0.height.equalTo(60)
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(animationView!.snp.bottom).inset(24)
        }
        
        cancelButton.snp.makeConstraints {
            $0.height.equalTo(60)
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(recorderButton.snp.bottom).offset(24)
        }
        
        textLabel.snp.makeConstraints {
            $0.height.equalTo(60)
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(cancelButton.snp.bottom).offset(24)
            
        }
        
    }
    
    private func lottieViewLoad() {
        animationView = .init(name: "78296-record")
        animationView!.frame = view.bounds
        animationView!.contentMode = .scaleAspectFit
        animationView!.loopMode = .loop
        animationView!.animationSpeed = 0.5
        view.addSubview(animationView!)
        animationView!.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(48)
            $0.trailing.equalToSuperview().inset(48)
        }
        animationView!.play()
    }
    
    func presentTextLabel(text: String) {
        textLabel.text = text
    }
    
    @objc func didTapRecorderButton() {
        cancelButton.isHidden = status == .stop
        textLabel.isHidden = status == .stop
        status = status == .start ? .stop : .start
        recorderButton.setTitle(status.label, for: .normal)
        
        guard let recorderButton = viewModel?.tapRecorderButton else { return }
       
        if status == .start {
            dismiss(animated: true)
            // recording 완료
            Observable.just(RecorderStatus.stop)
                .bind(to: recorderButton)
                .disposed(by: disposeBag)
        } else {
            // recording 시작
            Observable.just(RecorderStatus.start)
                .bind(to: recorderButton)
                .disposed(by: disposeBag)
        }
    }
    
    @objc func didTapCancelButton() {
        guard let recorderButton = viewModel?.tapRecorderButton else { return }
        Observable.just(RecorderStatus.cancel)
            .bind(to: recorderButton)
            .disposed(by: disposeBag)
        dismiss(animated: true)
    }

}

extension Reactive where Base: RecorderViewController {
    var presentRecordedText: Binder<String> {
        return Binder(base) { base, text in
            base.presentTextLabel(text: text)
        }
    }
}
