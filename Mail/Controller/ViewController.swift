//
//  ViewController.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 12/03/2021.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    
    // MARK: - Properties
    
    // Title view
    @IBOutlet var mailboxesButton: UIButton!
    @IBOutlet var mailboxesTitle: UILabel!
    @IBOutlet var mailboxesInfo: UILabel!
    
    // Collection view
    @IBOutlet weak var collectionView: UICollectionView!
    private var collectionViewController: NewMailCollectionViewController!
    
    
    // MARK: - Object life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        addButtonMenu()
        collectionViewController = NewMailCollectionViewController(collectionView: collectionView)
        collectionView.delegate = self
    
    }
    
    // MARK: - Title view action

    @IBAction func mailboxesButtonTapped(_ sender: Any) {
    }
    
    private func addButtonMenu() {
        var actionList = [UIAction]()
        
        for mailbox in Mailboxes.allCases {
            let action = UIAction(title: mailbox.rawValue, image: UIImage(systemName: mailbox.symbol)) { _ in
                self.mailboxesTitle.text = mailbox.rawValue
                let conifg = UIImage.SymbolConfiguration(scale: .large)
                self.mailboxesButton.setImage(UIImage(systemName: mailbox.symbol, withConfiguration: conifg), for: .normal)
            }
            actionList.append(action)
        }
        
        let menu = UIMenu(title: "Mailboxes", children: actionList)
        
        mailboxesButton.role = .normal
        mailboxesButton.menu = menu
        mailboxesButton.showsMenuAsPrimaryAction = true
    }
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let threadVC = self.storyboard!.instantiateViewController(withIdentifier: "ThreadVC") as! UserThreadViewController
        threadVC.user = Thread.mockedDataArray[indexPath.row].user
        self.navigationController!.pushViewController(threadVC, animated: true)
    }
}


