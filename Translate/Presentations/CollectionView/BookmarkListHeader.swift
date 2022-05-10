//
//  BookmarkListHeader.swift
//  Translate
//
//  Created by 정유진 on 2022/05/09.
//

import UIKit
import SnapKit

class BookmarkListHeader: UICollectionReusableView {
    
    private lazy var nameLabel: UILabel = {
        var label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.sizeToFit()
        return label
    }()
    
    func setNameLabel(_ name: String) {
        nameLabel.text = name
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.equalToSuperview().inset(16)
        }
    }
}
