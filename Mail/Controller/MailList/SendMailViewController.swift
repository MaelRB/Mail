//
//  SendMailViewController.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 23/04/2021.
//

import UIKit

class SendMailViewController: UIViewController {

    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var ccTextField: UITextField!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var keyboardHeightConstraint: NSLayoutConstraint!
    
    private var documentCollectionViewController: DocumentCollectionViewController!
    private var imageList = [UIImage]() {
        didSet {
            documentCollectionViewController.addImage(imageList)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        documentCollectionViewController = DocumentCollectionViewController(collectionView: collectionView)
        
        textView.delegate = self
        
        toTextField.becomeFirstResponder()
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
                self.keyboardHeightConstraint?.constant = -(endFrame!.size.height - 20)
            } else {
                self.keyboardHeightConstraint?.constant = 5
            }
            
        }
        
        UIView.animate(
            withDuration: duration,
            delay: TimeInterval(0),
            options: animationCurve,
            animations: { self.view.layoutIfNeeded() },
            completion: nil)
    }

    @IBAction func closeButtonDidTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendButtonDidTap(_ sender: Any) {
        sendMail()
    }
    
    @IBAction func documentButtonDidTap(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @IBAction func textDidChange(_ sender: UITextField) {
        checkWetherSendEnable()
    }
    
    private func checkWetherSendEnable() {
        sendButton.isEnabled = textView.text != "" && toTextField.text != ""
    }
    
    private func sendMail() {
        let message = Message(to: toTextField.text!, body: textView.text, subject: subjectTextField.text ?? "", cc: ccTextField.text ?? "")
        GraphManager.instance.sendMessage(message) { (error) in
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}

// MARK: - Image picker methods
extension SendMailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        imageList.append(image)
        dismiss(animated: true)
    }
}

// MARK: - Text view delegate methods
extension SendMailViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        checkWetherSendEnable()
    }
}
