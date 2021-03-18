//
//  ThreadsCollectionViewController.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 15/03/2021.
//

import UIKit

class ThreadsCollectionViewController {
    
    var collectionView: UICollectionView
    private var dataSource: UICollectionViewDiffableDataSource<Thread, Mail>!
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        
        setup()
    }
    
    private func setup() {
        collectionView.collectionViewLayout = createListLayout()
        setDatasource()
    }
    
    private func createListLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    private func setDatasource() {
        
        collectionView.register(UINib.init(nibName: "ThreadHeaderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ThreadHeader")
        
        collectionView.register(UINib.init(nibName: "MailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MailCollectionViewCell")
        
        dataSource = UICollectionViewDiffableDataSource<Thread, Mail>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, identifier) -> UICollectionViewCell? in
            
            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThreadHeader", for: indexPath) as? ThreadHeaderCollectionViewCell
                cell?.configure(info: "23 messages", title: "MVP docs >")
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MailCollectionViewCell", for: indexPath) as! MailCollectionViewCell
                cell.configure(with: identifier)
                return cell
            }
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Thread, Mail>()
        snapshot.appendSections([Thread.mockedData])
        
        var mailList = [Mail.headerMail]
        mailList.append(contentsOf: Mail.mockedDataArray)
        snapshot.appendItems(mailList, toSection: Thread.mockedData)
        dataSource.apply(snapshot)
        
    }
}
