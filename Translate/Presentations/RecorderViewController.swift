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
        
        var label: String {
            switch self {
            case .start: return "시작하기"
            case .stop: return "번역하기"
            }
        }
    }
    
    var status: RecorderStatus = .start
    var viewModel: RecorderViewModel?
    let disposeBag = DisposeBag()
    private var animationView: AnimationView?
    
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
        // record 중단 시 event
    }
    
    func attribute() {
        view.backgroundColor = .systemBackground
    }
    
    func layout() {
        lottieViewLoad()
        
        [
            recorderButton,
            cancelButton
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
    }
    
    private func lottieViewLoad() {
        animationView = .init(name: "78296-record")
        animationView!.frame = view.bounds
        animationView!.contentMode = .scaleAspectFit
        animationView!.loopMode = .loop
        animationView!.animationSpeed = 0.5
        view.addSubview(animationView!)
        animationView!.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalToSuperview().inset(16)
        }
        animationView!.play()
    }
    
    @objc func didTapRecorderButton() {
        cancelButton.isHidden = status == .stop
        status = status == .start ? .stop : .start
        recorderButton.setTitle(status.label, for: .normal)
        
        if status == .start {
            dismiss(animated: true)
        }
    }
    
    @objc func didTapCancelButton() {
        dismiss(animated: true)
    }

}
