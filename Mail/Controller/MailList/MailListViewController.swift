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
    
    // Title
    @IBOutlet var mailboxesButton: UIButton!
    
    // Collection view
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Loading
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Tab bar
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    @IBOutlet weak var createMailButton: UIButton!
    
    private var mailCollectionVC: MailCollectionViewController!
    private var mailController: MailController!
    
    private var viewSate: State = .notRequested {
        didSet {
            updateViewState()
        }
    }
    
    // MARK: - Object life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        updateViewState()
        setupController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - View state
    
    private func updateViewState() {
        switch viewSate {
            case .notRequested:
                viewSate = .loading
            case .loading:
                loadingView()
            case .loaded:
                presentView()
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
    
    private func presentView() {
        activityIndicator.stopAnimating()
        collectionView.isHidden = false
    }
    
    // MARK: - Setup methods
    
    private func setupUI() {
        setupCollectionView()
        setupTabBar()
        setupMailboxexButton()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
    }
    
    private func setupTabBar() {
        blurEffectView.effect = UIBlurEffect(style: .systemMaterial)
        blurEffectView.alpha = 0.8
        
        createMailButton.layer.shadowOffset = CGSize(width: 5, height: 5)
        createMailButton.layer.shadowColor = createMailButton.tintColor.cgColor
        createMailButton.layer.shadowRadius = 5
        createMailButton.layer.shadowOpacity = 0.4
    }
    
    private func setupMailboxexButton() {
        mailboxesButton.role = .normal
        mailboxesButton.showsMenuAsPrimaryAction = true
        mailboxesButton.sizeToFit()
    }
    
    private func setupController() {
        setupMailCollectionVC()
        setupMailController()
        mailCollectionVC.mailController = mailController
    }
    
    private func setupMailController() {
        mailController = MailController()
        mailController.mailListDelegate = self
        mailController.dataSource = mailCollectionVC
        mailController.getUserMailContext()
    }
    
    private func setupMailCollectionVC() {
        mailCollectionVC = MailCollectionViewController(collectionView: collectionView)
    }
    
    
    // MARK: - Title methods
    
    private func addButtonMenu(_ mailFolderList: [MSGraphMailFolder]) {
        var actionList = [UIAction]()
        
        for mailbox in mailFolderList {
            let action = UIAction(title: mailbox.displayName!) { _ in
                self.viewSate = .loading
                self.mailController.switchFolder(mailbox)
            }
            actionList.append(action)
        }
        
        let menu = UIMenu(title: "Mailboxes", children: actionList)
        mailboxesButton.menu = menu
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
    
    // MARK: - Action methods
    
    @IBAction func newMessageDidTap(_ sender: Any) {
        let message = Message(to: "mael.rb@outlook.com", body: "Premier mail envoyer depuis mon app", subject: "First !!!!")
//        GraphManager.instance.sendMessage(message) { (_, _) in
//            
//        }
    }
    
    
}

// MARK: - Mail controller mail delegate methods

extension MailListViewController: MailControllerMailListDelegate {
    func updateFolderMenu(_ folderList: [MSGraphMailFolder]) {
        addButtonMenu(folderList)
    }
    
    func updateTitle(_ title: NSAttributedString) {
        self.mailboxesButton.setAttributedTitle(title, for: .normal)
    }
    
    func updateViewSate(_ state: State) {
        viewSate = state
    }
}

// MARK: - Collection view delegate methods

extension MailListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "MailDetailVC", bundle: nil )
        let mailDetail = storyboard.instantiateViewController(withIdentifier: "mailDetailVC") as! MailDetailViewController
        mailController.setSelectedMail(indexPath)
        mailDetail.mailController = mailController
        self.navigationController!.pushViewController(mailDetail, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == mailController.mailList.count - 2 {
            mailController.getNextPage()
        }
    }
    
}

