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
    
    var viewModel: CoreDataViewModel!
    let disposeBag = DisposeBag()
    var bookmarkData: [Item] = []
    var dataCount: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        attribute()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        print("bookmarkviewwillappear", bookmarkData.count, dataCount)
    }
    
    func bind(_ model: CoreDataViewModel) {
        viewModel = model
        
        // 최초 fetch 후 colletion view에 반영
        viewModel
            .bookmarkItems
            .drive(self.rx.bookmarkDataSource)
            .disposed(by: disposeBag)
        
        viewModel
            .bookmarkCount
            .drive(self.rx.isBookmarkUpdated)
            .disposed(by: disposeBag)
            
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
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 3)
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
    
    func setBookmarkData(items: [Item]) {
        print("set bookmark data", items)
        bookmarkData = items
        collectionView.reloadData()
    }
    
    func reloadCollectionView(cnt: Int) {
        dataCount = cnt
        collectionView.reloadData()
    }
}

extension Reactive where Base: BookmarkViewController {
    var bookmarkDataSource: Binder<[Item]> {
        return Binder(base) { base, items in
            base.setBookmarkData(items: items)
        }
    }
    
    var isBookmarkUpdated: Binder<Int> {
        return Binder(base) { base, cnt in
            base.reloadCollectionView(cnt: cnt)
        }
    }
}


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
        return dataCount
    }
    
    // cell 내용 결정
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookmarkListCell", for: indexPath) as? BookmarkListCell else { return UICollectionViewCell() }
        let item = bookmarkData[indexPath.last!]
        cell.setContentOfCell(item.bookmark)
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
