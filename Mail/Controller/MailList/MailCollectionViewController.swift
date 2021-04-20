//
//  TableViewController.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 12/03/2021.
//

import UIKit
import MSGraphClientModels

class MailCollectionViewController {
    
    private enum Section {
        case main
    }
    
    var collectionView: UICollectionView
    var dataSource = [MSGraphMessage]() {
        didSet {
            updateDiffableDataSource()
        }
    }
    
    private var diffableDataSource: UICollectionViewDiffableDataSource<Section, MSGraphMessage>!
    
    weak var mailController: MailController?
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        setup()
    }
    
    private func setup() {
        collectionView.collectionViewLayout = createListLayout()
        setDatasource()
    }
    
    private func createListLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        
        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }
            
            let message = self.dataSource[indexPath.row]
            
            let deleteHandler: UIContextualAction.Handler = { action, view, completion in
                GraphManager.instance.delete(message: message) { (error) in
                    DispatchQueue.main.async {
                        guard error == nil else {
                            print("Error getting user: \(String(describing: error))")
                            completion(false)
                            return
                        }
                        if let mailController = self.mailController {
                            mailController.mailList.removeAll { $0 == message }
                        }
                        completion(true)
                    }
                }
            }
            
            let actionHandler: UIContextualAction.Handler = { action, view, completion in
                
                completion(true)
//                self.updateMessages(new: [], [message])
            }
            
            let delete = UIContextualAction(style: .destructive, title: "Delete", handler: deleteHandler)
//            delete.image = UIImage(systemName: "trash")

            let more = UIContextualAction(style: .normal, title: "More", handler: actionHandler)
            more.image = UIImage(systemName: "ellipsis")

            return UISwipeActionsConfiguration(actions: [delete, more])
        }
        
        config.leadingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }
            
            let selectedMessage = self.dataSource[indexPath.row]
            
            let readHandler: UIContextualAction.Handler = { action, view, completion in
                GraphManager.instance.updateRead(for: selectedMessage, newValue: !selectedMessage.isRead) { (message, error) in
                    DispatchQueue.main.async {
                        guard let message = message, error == nil else {
                            print("Error getting user: \(String(describing: error))")
                            completion(false)
                            return
                        }
                        
                        self.dataSource[indexPath.row] = message
                        completion(true)
                    }
                }
            }
            
            let read = UIContextualAction(style: .normal, title: selectedMessage.isRead ? "Unread" : "Read", handler: readHandler)
            read.backgroundColor = .systemBlue
            
            return UISwipeActionsConfiguration(actions: [read])
        }
        
        return UICollectionViewCompositionalLayout.list(using: config)
        
    }
    
    private func setDatasource() {
        
        collectionView.register(UINib.init(nibName: "MailListCell", bundle: nil), forCellWithReuseIdentifier: "MailList")
        
        diffableDataSource = UICollectionViewDiffableDataSource<Section, MSGraphMessage>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, identifier) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MailList", for: indexPath) as! MailListCell
            cell.configure(with: identifier)
            return cell
        })

    }
    
    private func updateDiffableDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MSGraphMessage>()
        snapshot.appendSections([.main])
        snapshot.appendItems(dataSource)
        diffableDataSource.apply(snapshot)
    }
    
}
