//
//  ViewController.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 12/03/2021.
//

import UIKit
import MSGraphClientModels

class ViewController: UIViewController {
    
    
    // MARK: - Properties
    
    // Title view
    @IBOutlet var mailboxesButton: UIButton!
    @IBOutlet var mailboxesTitle: UILabel!
    @IBOutlet var mailboxesInfo: UILabel!
    
    // Collection view
    @IBOutlet weak var collectionView: UICollectionView!
    private var collectionViewController: ThreadListCollectionViewController!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
        
        collectionViewController = ThreadListCollectionViewController(collectionView: collectionView)
        collectionView.delegate = self
        
        getMe()
        getMailFolder()
        
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
        collectionViewController.addThread(value)
    }
    
    
    // MARK: - Title view action

    @IBAction func mailboxesButtonTapped(_ sender: Any) {
    }
    
    private func addButtonMenu() {
        var actionList = [UIAction]()
        
        print(mailBoxes)
        
        for mailbox in mailBoxes {
            let action = UIAction(title: mailbox.displayName!) { _ in
                self.mailboxesTitle.text = mailbox.displayName!
                let conifg = UIImage.SymbolConfiguration(scale: .large)
                self.mailboxesButton.setImage(UIImage(systemName: "tray.fill", withConfiguration: conifg), for: .normal)
                self.mailboxesInfo.text = "\(mailbox.unreadItemCount) new messages"
            }
            actionList.append(action)
        }
        
        let menu = UIMenu(title: "Mailboxes", children: actionList)
        
        mailboxesButton.role = .normal
        mailboxesButton.menu = menu
        mailboxesButton.showsMenuAsPrimaryAction = true
    }
    
    @IBAction func signIn(_ sender: Any) {
    
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

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let threadVC = self.storyboard!.instantiateViewController(withIdentifier: "ThreadVC") as! UserConversationViewController
//        threadVC.user = messagesList.value![indexPath.row].mailList.first!.sender
        self.navigationController!.pushViewController(threadVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == messagesList.value!.count - 2 {
            getInboxNextPage()
        }
    }
    
}

