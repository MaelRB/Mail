//
//  ViewController.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 12/03/2021.
//

import UIKit
import MSGraphClientModels

class MailListViewController: UIViewController {
    
    
    // MARK: - Properties
    
    // Title view
    @IBOutlet var mailboxesButton: UIButton!
    
    // Collection view
    @IBOutlet weak var collectionView: UICollectionView!
    private var collectionViewController: MailListCollectionViewController!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    
    private var mailBoxes = [MSGraphMailFolder]() {
        didSet {
            addButtonMenu();
        }
    }
    
    
    private var messagesList: Loadable<[MSGraphMessage]> = .notRequested {
        didSet {
            updateViewState()
        }
    }
    
    // MARK: - Object life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        collectionViewController = MailListCollectionViewController(collectionView: collectionView)
        collectionView.delegate = self
        
        getMe()
        getMailFolder()
        
        blurEffectView.effect = UIBlurEffect(style: .systemMaterial)
        blurEffectView.alpha = 0.8
        
        updateViewState()
    }
    
    // MARK: - View state
    
    private func updateViewState() {
        switch messagesList {
            case .notRequested:
                messagesList = .loading
            case .loading:
                loadingView()
                getUserInbox()
            case .loaded(let value):
                presentationView(with: value)
            case .error(let err):
                // TODO: - Handle error
                print(err)
                break
        }
    }
    
    private func loadingView() {
        collectionView.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func presentationView(with value: [MSGraphMessage]) {
        activityIndicator.stopAnimating()
        collectionView.isHidden = false
        collectionViewController.addMessages(value)
    }
    
    
    // MARK: - Title view action

    @IBAction func mailboxesButtonTapped(_ sender: Any) {
    }
    
    private func addButtonMenu() {
        var actionList = [UIAction]()
        
        for mailbox in mailBoxes {
            let action = UIAction(title: mailbox.displayName!) { _ in
                let text = NSMutableAttributedString(string: "\(mailbox.displayName!)   \(mailbox.unreadItemCount)")
                text.setAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 28),
                                    NSAttributedString.Key.foregroundColor: UIColor.systemBlue],
                                   range: NSMakeRange(0, mailbox.displayName!.count))
                self.mailboxesButton.setAttributedTitle(text, for: .normal)
            }
            actionList.append(action)
        }
        
        let menu = UIMenu(title: "Mailboxes", children: actionList)
        
        mailboxesButton.role = .normal
        mailboxesButton.menu = menu
        mailboxesButton.showsMenuAsPrimaryAction = true
        mailboxesButton.sizeToFit()
        
    }
    
    // MARK: - Graph manager methods
    
    private func getMe() {
        GraphManager.instance.getMe {
            (user: MSGraphUser?, error: Error?) in
            
            DispatchQueue.main.async {
                
                guard let currentUser = user, error == nil else {
                    print("Error getting user: \(String(describing: error))")
                    return
                }
                
                self.title = currentUser.displayName ?? "Unknown"
                
                // Save the user's time zone
                GraphManager.instance.userTimeZone = currentUser.mailboxSettings?.timeZone ?? "UTC"
            }
        }
    }
    
    private func getMailFolder() {
        GraphManager.instance.getMailFolders { (foldersArray, error) in
            DispatchQueue.main.async {
                
                guard let foldersArray = foldersArray, error == nil else {
                    print("Error getting user: \(String(describing: error))")
                    return
                }
                
                self.mailBoxes = foldersArray
                
            }
        }
    }
    
    private func getUserInbox() {
        GraphManager.instance.getMailInbox { (messages, error) in
            DispatchQueue.main.async {
                
                guard let messages = messages, error == nil else {
                    print("Error getting user: \(String(describing: error))")
                    return
                }
                
                self.messagesList = .loaded(messages)
            }
        }
    }
    
    private func getInboxNextPage() {
        GraphManager.instance.getNextInboxPage { (messages, error) in
            DispatchQueue.main.async {
                
                guard let messages = messages, error == nil else {
                    print("Error getting user: \(String(describing: error))")
                    return
                }
                
                self.messagesList = .loaded(self.messagesList.value! + messages)
            }
        }
    }
}

// MARK: - Collection view delegate methods

extension MailListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "MailDetailVC", bundle: nil )
        let mailDetail = storyboard.instantiateViewController(withIdentifier: "mailDetailVC") as! MailDetailViewController
        mailDetail.mail = messagesList.value![indexPath.row]
        self.navigationController!.pushViewController(mailDetail, animated: true)
        GraphManager.instance.markAsRead(messagesList.value![indexPath.row]) { (message, error) in
            DispatchQueue.main.async {
                
                guard error == nil else {
                    print("Error getting user: \(String(describing: error))")
                    return
                }
                
                self.messagesList.value![indexPath.row].isRead = true
                self.collectionViewController.updateMessages([self.messagesList.value![indexPath.row]])
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == messagesList.value!.count - 2 {
            getInboxNextPage()
        }
    }
    
}

