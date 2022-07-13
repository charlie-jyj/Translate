//
//  BookmarkListCell.swift
//  Translate
//
//  Created by 정유진 on 2022/05/09.
//

import UIKit
import SnapKit

class BookmarkListCell: UICollectionViewCell {
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .leading
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private lazy var sourceLanguageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var sourceTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var targetLanguageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor.mainTintColor
        return label
    }()
    
    private lazy var targetTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = UIColor.mainTintColor
        label.numberOfLines = 0
        return label
    }()
    
    func setContentOfCell(_ bookmark: Bookmark) {
        sourceLanguageLabel.text = bookmark.sourceLanguage.title
        sourceTextLabel.text = bookmark.sourceContent
        targetLanguageLabel.text = bookmark.targetLanguage.title
        targetTextLabel.text = bookmark.targetContent
        
    }
    
    func setSampleCell(sourceLanguage: String, sourceText:String, targetLanguage:String, targetText: String) {
        sourceLanguageLabel.text = sourceLanguage
        sourceTextLabel.text = sourceText
        targetLanguageLabel.text = targetLanguage
        targetTextLabel.text = targetText
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
        
        contentView.addSubview(scrollView)
        
        scrollView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(16)
            $0.leading.equalToSuperview().inset(16)
            $0.width.equalToSuperview().inset(16)
        }
        
        scrollView.addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.top.bottom.equalTo(scrollView)
            $0.width.equalTo(scrollView.snp.width)
        }
        
        [
            sourceLanguageLabel,
            sourceTextLabel,
            targetLanguageLabel,
            targetTextLabel
        ].forEach {
            stackView.addArrangedSubview($0)
        }
        
    }
}
