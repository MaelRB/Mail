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
    
    // User
//    var user: User!
    
    var mail: MSGraphMessage!

    // Outlets
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var replyView: ReplyView!
    @IBOutlet weak var replyViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var keyboardHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Object life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        setup()
        
        self.title = mail.sender?.emailAddress?.name
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.isHidden = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup methods
    
    private func setup() {
        replyViewSetup()
        webView.loadHTMLString(mail.body!.content!, baseURL: nil)
        titleLabel.text = mail.subject
    }
    
    fileprivate func replyViewSetup() {
        replyView.delegate = self
//        replyView.threadList = mail.value!
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

