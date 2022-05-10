//
//  BookmarkViewController.swift
//  Translate
//
//  Created by 정유진 on 2022/04/27.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import CoreData

class BookmarkViewController: UICollectionViewController {
    
    var viewModel: BookmarkViewModel!
    var sampleData: [[[String:String]]] = [
        [
            [
            "sourceLanguage":"Korean",
            "sourceText": "이 호텔은 어디에 있나요? 어떤 교통수단을 탈 수 있을까요?",
            "targetLanguage": "English",
            "targetText": "Where is this hotel? what kind of transportation I can take? and I need more long setence to know if the cell scroll is working or not: I think there is the right property to controll the scroll vertically or horizontally then I should looking out all over the place"
            ],
            [
            "sourceLanguage":"Korean",
            "sourceText": "이 호텔은 어디에 있나요? 어떤 교통수단을 탈 수 있을까요?",
            "targetLanguage": "English",
            "targetText": "Where is this hotel? what kind of transportation I can take?"
            ],
            [
            "sourceLanguage":"Korean",
            "sourceText": "이 호텔은 어디에 있나요? 어떤 교통수단을 탈 수 있을까요?",
            "targetLanguage": "English",
            "targetText": "Where is this hotel? what kind of transportation I can take?"
            ],
            [
            "sourceLanguage":"Korean",
            "sourceText": "이 호텔은 어디에 있나요? 어떤 교통수단을 탈 수 있을까요?",
            "targetLanguage": "English",
            "targetText": "Where is this hotel? what kind of transportation I can take?"
            ],
            [
            "sourceLanguage":"Korean",
            "sourceText": "이 호텔은 어디에 있나요? 어떤 교통수단을 탈 수 있을까요?",
            "targetLanguage": "English",
            "targetText": "Where is this hotel? what kind of transportation I can take?"
            ],
            [
            "sourceLanguage":"Korean",
            "sourceText": "이 호텔은 어디에 있나요? 어떤 교통수단을 탈 수 있을까요?",
            "targetLanguage": "English",
            "targetText": "Where is this hotel? what kind of transportation I can take?"
            ],
            [
            "sourceLanguage":"Korean",
            "sourceText": "이 호텔은 어디에 있나요? 어떤 교통수단을 탈 수 있을까요?",
            "targetLanguage": "English",
            "targetText": "Where is this hotel? what kind of transportation I can take?"
            ],
            [
            "sourceLanguage":"Korean",
            "sourceText": "이 호텔은 어디에 있나요? 어떤 교통수단을 탈 수 있을까요?",
            "targetLanguage": "English",
            "targetText": "Where is this hotel? what kind of transportation I can take?"
            ]
        ]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        attribute()
    }
    
    func bind(_ model: BookmarkViewModel) {
        viewModel = model
    }
    
    private func attribute() {
        
        collectionView.backgroundColor = .secondarySystemBackground
        
        // register
        collectionView.register(BookmarkListCell.self, forCellWithReuseIdentifier: "BookmarkListCell")
        collectionView.register(BookmarkListHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "BookmarkListHeader")
        
        // layout
        collectionView.collectionViewLayout = layout()
    }
    
    /*
     typealias UICollectionViewCompositionalLayoutSectionProvider = (Int, NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection?
     */
    
    private func layout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] index, environment -> NSCollectionLayoutSection? in
            return self?.getCollectionLayoutSection()
        }
    }
    
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(32))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        return header
    }
    
    private func getCollectionLayoutSection() -> NSCollectionLayoutSection {
        
        //1. item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 8.0, leading: 16.0, bottom: 8.0, trailing: 16.0)
        
        // 2. group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .fractionalHeight(0.75))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 2)
        //let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        // 3. section
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = .init(top: 24.0, leading: 16.0, bottom: 0.0, trailing: 16.0)
        
        // 4. header
        let header = createSectionHeader()
        section.boundarySupplementaryItems = [header]
        
        return section
    }
}

//TOBE: Rx로 변환하기
extension BookmarkViewController {

    /*
     DataSource
     */
    
    // section 수
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // section 별 item 수
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    // cell 내용 결정
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookmarkListCell", for: indexPath) as? BookmarkListCell else { return UICollectionViewCell() }
        let content = sampleData[0][indexPath.row]
        cell.setSampleCell(
            sourceLanguage: content["sourceLanguage"]!,
            sourceText: content["sourceText"]!,
            targetLanguage: content["targetLanguage"]!,
            targetText: content["targetText"]!
        )
        return cell
    }
    
    // header 결정
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "BookmarkListHeader", for: indexPath) as? BookmarkListHeader else { return UICollectionReusableView() }
            header.setNameLabel("Bookmark")
            return header
        } else {
            return UICollectionReusableView()
        }
    }
    
    /*
     Delegate
     */
    
    
}
