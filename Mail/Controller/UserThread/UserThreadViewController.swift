//
//  ThreadsViewController.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 14/03/2021.
//

import UIKit

class UserThreadViewController: UIViewController {
    
    // User
    var user: User!

    // Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reply: UITextField!
    
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    
    // MARK: - Object life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navItemSetup()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        tableView.register(UINib.init(nibName: "MailTableViewCell", bundle: nil), forCellReuseIdentifier: "MailCell")
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 400
        tableView.sectionHeaderHeight = 60
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func navItemSetup() {
        self.title = user.name
        let navigationItemView = UserThreadNavigationItem()
        navigationItemView.imageView.image = user.profilePicture
        navigationItemView.name.text = user.name
        navigationItemView.info.text = "3 threads"
        navigationItem.titleView = navigationItemView
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
            self.keyboardHeightLayoutConstraint?.constant = 20
        } else {
            self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 20
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
extension UserThreadViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Thread.mockedDataArray[section].mailList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Thread.mockedDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MailCell", for: indexPath) as! MailTableViewCell
        cell.configure(with: Thread.mockedDataArray[indexPath.section].mailList[indexPath.row])
        return cell
    }
    
}

// MARK: - Tbale view delegate methods
extension UserThreadViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect.zero)
        headerView.backgroundColor = .systemBackground
        
        let infoLabel = UILabel()
        infoLabel.text = "\(Thread.mockedDataArray[section].mailList.count) messages"
        infoLabel.font = .systemFont(ofSize: 14)
        infoLabel.textColor = .secondaryLabel
        headerView.addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "\(Thread.mockedDataArray[section].mailList.first!.object)"
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
