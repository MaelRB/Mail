//
//  TableViewController.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 12/03/2021.
//

import UIKit

class ThreadListCollectionViewController {
    
    private enum Section {
        case main
    }
    
    enum Kind {
        case list
        case grid
    }
    
    var kind: Kind
    
    var collectionView: UICollectionView
    private var dataSource: UICollectionViewDiffableDataSource<Section, Thread>!
    
    init(collectionView: UICollectionView, kind: Kind = .list) {
        self.kind = kind
        self.collectionView = collectionView
        
        setup()
    }
    
    private func setup() {
        collectionView.collectionViewLayout = createListLayout()
        setDatasource()
        // TODO: - Create a grid layout for grid kind collection view
    }
    
    private func createListLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    private func setDatasource() {
        
        collectionView.register(UINib.init(nibName: "ThreadListCell", bundle: nil), forCellWithReuseIdentifier: "ThreadList")
        
        dataSource = UICollectionViewDiffableDataSource<Section, Thread>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, identifier) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThreadList", for: indexPath) as! ThreadListCell
            cell.configure(with: identifier)
            return cell
        })
        
    }
    
    func addThread(_ threadList: [Thread]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Thread>()
        snapshot.appendSections([.main])
        snapshot.appendItems(threadList)
        dataSource.apply(snapshot)
    }
}
