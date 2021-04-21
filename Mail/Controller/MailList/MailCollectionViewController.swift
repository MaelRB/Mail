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
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, MSGraphMessage>!
    
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
            
            let deleteHandler: UIContextualAction.Handler = { action, view, completion in
                self.mailController?.deleteMessage(self.mailController!.mail(at: indexPath), completion: completion)
            }
            
            let actionHandler: UIContextualAction.Handler = { action, view, completion in
                
                completion(true)
            }
            
            let delete = UIContextualAction(style: .destructive, title: "Delete", handler: deleteHandler)
//            delete.image = UIImage(systemName: "trash")

            let more = UIContextualAction(style: .normal, title: "More", handler: actionHandler)
            more.image = UIImage(systemName: "ellipsis")

            return UISwipeActionsConfiguration(actions: [delete, more])
        }
        
        config.leadingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }
            
            let selectedMessage = self.mailController!.mail(at: indexPath)
            
            let readHandler: UIContextualAction.Handler = { action, view, completion in
                self.mailController?.updateIsRead(for: selectedMessage, with: completion)
            }
            
            let read = UIContextualAction(style: .normal, title: selectedMessage.isRead ? "Unread" : "Read", handler: readHandler)
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

    }
    
    private func updateDataSource(with mailList: [MSGraphMessage]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MSGraphMessage>()
        snapshot.appendSections([.main])
        snapshot.appendItems(mailList)
        dataSource.apply(snapshot)
    }
}

// MARK: - MailController dataSource methods

extension MailCollectionViewController: MailControllerMailCollectionDataSource {
    
    func updateDataSource(_ mailList: [MSGraphMessage]) {
        updateDataSource(with: mailList)
    }
}
