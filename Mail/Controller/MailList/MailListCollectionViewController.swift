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
    private var messageList = [MSGraphMessage]()
    
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
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        
        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }
            
            let message = self.messageList[indexPath.row]
            
            let actionHandler: UIContextualAction.Handler = { action, view, completion in
                
                completion(true)
                self.collectionView.reloadItems(at: [indexPath])
            }
            
            let delete = UIContextualAction(style: .destructive, title: "Delete", handler: actionHandler)
//            delete.image = UIImage(systemName: "trash")

            let more = UIContextualAction(style: .normal, title: "More", handler: actionHandler)
            more.image = UIImage(systemName: "ellipsis")

            return UISwipeActionsConfiguration(actions: [delete, more])
        }
        
        config.leadingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }
            
            let message = self.messageList[indexPath.row]
            
            let actionHandler: UIContextualAction.Handler = { action, view, completion in
                
                completion(true)
                self.collectionView.reloadItems(at: [indexPath])
            }
            
            let read = UIContextualAction(style: .normal, title: message.isRead ? "Unread" : "Read", handler: actionHandler)
            read.backgroundColor = .systemBlue
            
            return UISwipeActionsConfiguration(actions: [read])
        }
        
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
        self.messageList.append(contentsOf: messageList)
        snapshot.appendItems(messageList)
        dataSource.apply(snapshot)
    }
    
    func updateMessages(_ messageList: [MSGraphMessage]) {
        snapshot.reloadItems(messageList)
        dataSource.apply(snapshot)
    }
    
}
