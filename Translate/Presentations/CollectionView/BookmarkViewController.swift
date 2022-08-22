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
    var items: [Item] = []
    var dataCount: Int = 0
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, Item> = {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, index, item in
            
            var content = cell.defaultContentConfiguration()
            content.text = item.bookmark.targetContent
            content.secondaryText = item.bookmark.sourceContent
            content.secondaryTextProperties.color = .secondaryLabel
            content.secondaryTextProperties.font = .preferredFont(forTextStyle: .subheadline)
            cell.contentConfiguration = content
            cell.tintColor = .mainTintColor
            cell.accessories = [
                .customView(configuration: .init(
                    customView: UIImageView(image: UIImage(systemName: "speaker.circle")),
                                            placement: .trailing())
                ),
                .reorder(),
                .delete()
            ]
        }
        return UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }()
    
    let disposeBag = DisposeBag()

    private enum Section: CaseIterable {
        case main
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attribute()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applySnapshot()
    }
    
    func bind(_ model: BookmarkViewModel) {
        viewModel = model
        
        // 최초 fetch 후 colletion view에 반영
        viewModel
            .bookmarkItems
            .drive(self.rx.dataSourceBase)
            .disposed(by: disposeBag)
    }
    
    func setdataSource(items: [Item]) {
        self.items = items
        applySnapshot()
    }
    
    private func attribute() {
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItem?.primaryAction = UIAction(title:"Edit") { _ in
            self.setEditing(!self.isEditing, animated: true)
        }
        
        collectionView.backgroundColor = .secondarySystemBackground
        
        // layout
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.backgroundColor = .secondarySystemBackground
        config.trailingSwipeActionsConfigurationProvider = { indexPath in
            let delete = UIContextualAction(style: .destructive,
                                            title: "Delete") { action, view, completion in
                self.deleteItem(at: indexPath)
            }
            let swipe = UISwipeActionsConfiguration(actions: [delete])
            return swipe
        }
        collectionView.collectionViewLayout = layout(config: config)
        
        // datasource 적용
        applySnapshot(animatingDifferences: false)
        self.dataSource.reorderingHandlers.canReorderItem = { item in return true }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.collectionView.isEditing = editing
    }
    
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    private func layout(config: UICollectionLayoutListConfiguration) -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout.list(using: config)
    }
 
    private func deleteItem(at indexPath: IndexPath) {
        var snapshot = self.dataSource.snapshot()
        if let item = self.dataSource.itemIdentifier(for: indexPath) {
            // coredata에서 삭제
            Observable.just(item)
                .bind(to: viewModel.tapDeleteButton)
                .disposed(by: disposeBag)
        }
    }
}

extension Reactive where Base: BookmarkViewController {
    var dataSourceBase: Binder<[Item]> {
        return Binder(base) { base, items in
            base.setdataSource(items: items)
        }
    }
}

extension BookmarkViewController {
    // drag 하더라도 section은 벗어나지 않도록
    override func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveOfItemFromOriginalIndexPath originalIndexPath: IndexPath, atCurrentIndexPath currentIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        if originalIndexPath.section == proposedIndexPath.section {
            return proposedIndexPath
        }
        return originalIndexPath
    }
}
