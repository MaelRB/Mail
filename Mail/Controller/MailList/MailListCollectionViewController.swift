//
//  TableViewController.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 12/03/2021.
//

import UIKit
import MSGraphClientModels

class MailListCollectionViewController {
    
    private enum Section {
        case main
    }
    
    var collectionView: UICollectionView
    private var dataSource: UICollectionViewDiffableDataSource<Section, MSGraphMessage>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, MSGraphMessage>()
    
    init(collectionView: UICollectionView) {
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
        
        collectionView.register(UINib.init(nibName: "MailListCell", bundle: nil), forCellWithReuseIdentifier: "MailList")
        
        dataSource = UICollectionViewDiffableDataSource<Section, MSGraphMessage>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, identifier) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MailList", for: indexPath) as! MailListCell
            cell.configure(with: identifier)
            return cell
        })
        snapshot.appendSections([.main])
    }
    
    func addMessages(_ messageList: [MSGraphMessage]) {
        snapshot.appendItems(messageList)
        dataSource.apply(snapshot)
    }
    
    func updateMessages(_ messageList: [MSGraphMessage]) {
        snapshot.reloadItems(messageList)
        dataSource.apply(snapshot)
    }
    
}
