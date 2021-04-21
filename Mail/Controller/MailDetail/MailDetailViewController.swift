//
//  ThreadsViewController.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 14/03/2021.
//

import UIKit
import MSGraphClientModels
import WebKit

class MailDetailViewController: UIViewController {
    
   // MARK: Properties
    
    var mail: MSGraphMessage!
    weak var mailController: MailController!

    // Outlets
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var replyView: ReplyView!
    @IBOutlet weak var replyViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var tabBarView: UIVisualEffectView!
    @IBOutlet weak var keyboardHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mailInfoLabel: UILabel!
    
    // MARK: - Object life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        mail = mailController.selectedMail!
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.isHidden = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup methods
    
    private func setupUI() {
        replyViewSetup()
        webViewSetup()
        tabBarSetup()
        textSetup()
    }
    
    fileprivate func replyViewSetup() {
        replyView.delegate = self
    }
    
    private func webViewSetup() {
        webView.loadHTMLString(mail.body!.content!, baseURL: nil)
        webView.scrollView.showsVerticalScrollIndicator = false
    }
    
    private func tabBarSetup() {
        tabBarView.effect = UIBlurEffect(style: .systemMaterial)
        tabBarView.alpha = 0.8
    }
    
    private func textSetup() {
        self.title = mail.sender?.emailAddress?.name
        mailInfoLabel.text = mail.receivedDateTime!.relativeDate()
        titleLabel.text = mail.subject
    }
    
    // MARK: - Keyboard methods
    
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
    
    private func changeKeyBoardheight(_ height: CGFloat) {
        replyViewHeightConstraint.constant = height
        UIView.animate(
            withDuration: 0.15,
            delay: TimeInterval(0),
            options: [.curveEaseOut],
            animations: { self.view.layoutIfNeeded() },
            completion: nil)
    }
    
    // MARK: - Action methods
    
    @IBAction func replyButtonDidTap(_ sender: Any) {
    }
    
    @IBAction func trashButtonDidTap(_ sender: Any) {
        showAlert()
    }
    
    @IBAction func shareButtonDidTap(_ sender: Any) {
    }
    
    @IBAction func moreButtonDidTap(_ sender: Any) {
    }
    
    private func showAlert() {
        let alertController = UIAlertController(title: "Are you sure ?", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.mailController.deleteMessage(self.mail)
            self.navigationController?.popToRootViewController(animated: true)
            
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    
}

// MARK: - Reply view delegate methods

extension MailDetailViewController: ReplyViewDelegate {

    func replyDidTap() {
        changeKeyBoardheight(200)
    }
    
    func sendDidTap(_ mail: Mail, to thread: Thread) {
        changeKeyBoardheight(38)
    }
    
    func closeDidTap() {
        changeKeyBoardheight(38)
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

