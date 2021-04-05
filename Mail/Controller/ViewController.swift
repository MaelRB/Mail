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
    private var collectionViewController: ThreadListCollectionViewController!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    private var firestoreController = FirestoreThreadListController()
    private var threadList: Loadable<[Thread]> = .notRequested {
        didSet {
            updateViewState()
        }
    }
    
    // MARK: - Object life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        addButtonMenu()
        collectionViewController = ThreadListCollectionViewController(collectionView: collectionView)
        collectionView.delegate = self
        
        firestoreController.delegate = self
        
        // TODO: - Implement log screen and get of rid of the following lines
        Auth.auth().signIn(withEmail: "0@1.com", password: "123456") { (result, err) in
            if let error = err {
                print(error)
            } else {
                self.firestoreController.fetchUser(Auth.auth().currentUser!.uid) { user in
                    Constant.logUser = user
                }
                self.updateViewState()
            }
        }
    }
    
    // MARK: - View state
    
    private func updateViewState() {
        switch threadList {
            case .notRequested:
                threadList = .loading
            case .loading:
                loadingView()
                firestoreController.fetchMail(for: .Inbox)
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
    
    private func presentationView(with value: [Thread]) {
        activityIndicator.stopAnimating()
        collectionView.isHidden = false
        collectionViewController.addThread(value)
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

// MARK: - Collection view delegate methods

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let threadVC = self.storyboard!.instantiateViewController(withIdentifier: "ThreadVC") as! UserConversationViewController
        threadVC.user = threadList.value![indexPath.row].mailList.first!.sender
        self.navigationController!.pushViewController(threadVC, animated: true)
    }
}

// MARK: - Firestore VC delegate methods

extension ViewController: FirestoreThreadListControllerDelegate {
    func newMailsRetrieved(_ fetchThreadList: [Thread], _ error: Error?) {
        if let safeError = error {
            threadList = .error(safeError)
        } else {
            threadList = .loaded(fetchThreadList)
        }
    }
}
