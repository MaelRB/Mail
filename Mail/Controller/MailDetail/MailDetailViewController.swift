//
//  ThreadsViewController.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 14/03/2021.
//

import UIKit

class MailDetailViewController: UIViewController {
    
    // User
    var user: User!
    
    var threadList: Loadable<[Thread]> = .notRequested {
        didSet {
            updateViewState()
        }
    }

    // Outlets
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var replyView: ReplyView!
    @IBOutlet weak var replyViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var keyboardHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Object life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        updateViewState()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        self.title = user.name
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - View state
    
    private func updateViewState() {
        switch threadList {
            case .notRequested:
                threadList = .loading
            case .loading:
                loadingView()
                
            case .loaded(let value):
                presentationView(with: value)
            case .error(let err):
                // TODO: - Handle error
                print(err)
                break
        }
    }
    
    private func loadingView() {
        tableView.isHidden = true
        replyView.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func presentationView(with value: [Thread]) {
        activityIndicator.stopAnimating()
        setup()
        tableView.isHidden = false
        tableView.reloadData()
        replyView.isHidden = false
    }
    
    // MARK: - Setup methods
    
    private func setup() {
        navItemSetup()
        tableViewSetup()
        replyViewSetup()
    }
    
    fileprivate func navItemSetup() {
        let navigationItemView = UserConversationNavigationItem()
        navigationItemView.imageView.image = user.profilePicture
        navigationItemView.name.text = user.name
        navigationItemView.info.text = "\(threadList.value!.count) threads"
        navigationItem.titleView = navigationItemView
    }
    
    fileprivate func tableViewSetup() {
        tableView.register(UINib.init(nibName: "MailTableViewCell", bundle: nil), forCellReuseIdentifier: "MailCell")
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 400
        tableView.sectionHeaderHeight = 70
    }
    
    fileprivate func replyViewSetup() {
        replyView.delegate = self
        replyView.threadList = threadList.value!
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let endFrameY = endFrame?.origin.y ?? 0
        let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
        
        if endFrameY >= UIScreen.main.bounds.size.height {
            self.keyboardHeightConstraint?.constant = 0
        } else {
            if endFrame != nil {
                self.keyboardHeightConstraint?.constant = endFrame!.size.height - 20
            } else {
                self.keyboardHeightConstraint?.constant = 0
            }
            
        }
        
        UIView.animate(
            withDuration: duration,
            delay: TimeInterval(0),
            options: animationCurve,
            animations: { self.view.layoutIfNeeded() },
            completion: nil)
    }
    
    @IBAction func paperclipTapped(_ sender: Any) {
    }
    
}

// MARK: - Table view data source methods
extension MailDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return threadList.value![section].mailList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return threadList.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MailCell", for: indexPath) as! MailTableViewCell
        cell.configure(with: threadList.value![indexPath.section].mailList[indexPath.row])
        return cell
    }
    
}

// MARK: - Tbale view delegate methods
extension MailDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect.zero)
        headerView.backgroundColor = .systemBackground
        
        let infoLabel = UILabel()
        infoLabel.text = "\(threadList.value![section].mailList.count) messages"
        infoLabel.font = .systemFont(ofSize: 14)
        infoLabel.textColor = .secondaryLabel
        headerView.addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "\(threadList.value![section].title)"
        titleLabel.font = .boldSystemFont(ofSize: 22)
        headerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let inset: CGFloat = 10
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: inset),
            infoLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 2*inset),
            infoLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -2*inset),
            infoLabel.heightAnchor.constraint(equalToConstant: 16),
            
            titleLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 2*inset),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: 2),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -inset)
        ])
        
        return headerView
    }
    
}

// MARK: - Reply view delegate methods

extension MailDetailViewController: ReplyViewDelegate {

    func replyDidTap() {
        replyViewHeightConstraint.constant = 200
        UIView.animate(
            withDuration: 0.15,
            delay: TimeInterval(0),
            options: [.curveEaseOut],
            animations: { self.view.layoutIfNeeded() },
            completion: nil)
    }
    
    func sendDidTap(_ mail: Mail, to thread: Thread) {
        
        replyViewHeightConstraint.constant = 38
        UIView.animate(
            withDuration: 0.15,
            delay: TimeInterval(0),
            options: [.curveEaseOut],
            animations: { self.view.layoutIfNeeded() },
            completion: nil)
    }
    
    func closeDidTap() {
        replyViewHeightConstraint.constant = 38
        UIView.animate(
            withDuration: 0.15,
            delay: TimeInterval(0),
            options: [.curveEaseOut],
            animations: { self.view.layoutIfNeeded() },
            completion: nil)
    }
    
    func documentDitTap() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
}

// MARK : - Image picker methods
extension MailDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        replyView.addImage([image])
        dismiss(animated: true)
    }
}

