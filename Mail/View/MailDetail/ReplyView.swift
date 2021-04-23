//
//  ReplyView.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 19/03/2021.
//

import UIKit

protocol ReplyViewDelegate {
    func replyDidTap()
    func sendDidTap(_ comment: String)
    func closeDidTap()
    func documentDidTap()
}

class ReplyView: UIView {
    
    // MARK: - Outlets

    @IBOutlet private var contentView: UIView!

    @IBOutlet private weak var documentCollectionView: UICollectionView!
    @IBOutlet private weak var sendButton: UIButton!
    
    @IBOutlet private weak var replyButton: UIButton!
    @IBOutlet private weak var textView: UITextView!
    
    @IBOutlet weak var threadButton: UIButton!
    
    @IBOutlet private weak var addPersonButton: UIButton!
    @IBOutlet private weak var forwardButton: UIButton!
    
    @IBOutlet private weak var upperStackView: UIStackView!
    @IBOutlet private weak var downStackView: UIStackView!
    
    @IBOutlet private weak var separator: UIView!
    @IBOutlet weak var seperatorHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var downStackViewHeightConstraint: NSLayoutConstraint!
    // MARK: - Properties
    
    var delegate: ReplyViewDelegate?
    
    private var lowStackViewTopConstraint: NSLayoutConstraint!
    
    private var documentCollectionViewController: DocumentCollectionViewController!
    
//    var threadList = [Thread]() {
//        didSet {
//            threadButton.setTitle(threadList.first?.title ?? "No thread", for: .normal)
//            currentThread = threadList.first!
//            addButtonMenu()
//        }
//    }
    
//    private var currentThread: Thread!
    
    private var isReplying = false
    
    private var documentImageList = [UIImage]()
    
    // MARK: - Init and setup methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        Bundle.main.loadNibNamed("ReplyView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        lowStackViewTopConstraint = downStackView.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 5)
        seperatorHeightConstraint.constant = 0.5
        
        let config = UIImage.SymbolConfiguration(pointSize: 22)
        sendButton.setImage(UIImage(systemName: "arrow.up.circle.fill", withConfiguration: config), for: .normal)
        
        documentCollectionViewController = DocumentCollectionViewController(collectionView: documentCollectionView)
        
        notReplyingState()
    }
    
    // MARK: - Action methods
    
    @IBAction func documentButtonTapped(_ sender: Any) {
        delegate?.documentDidTap()
        if isReplying == false {
            isReplying = true
            replyState()
            delegate?.replyDidTap()
        }
    }
    
    @IBAction func replyButtonTapped(_ sender: Any) {
        isReplying = true
        textView.becomeFirstResponder()
        replyState()
        self.layoutIfNeeded()
        delegate?.replyDidTap()
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        delegate?.sendDidTap(textView.text)
        closeReplyView()
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        closeReplyView()
        delegate?.closeDidTap()        
    }
    
    // MARK: - State transition methods
    
    private func notReplyingState() {
        textView.isHidden = true
        sendButton.isHidden = true
        upperStackView.isHidden = true
        documentCollectionView.isHidden = true
        replyButton.isHidden = false
        lowStackViewTopConstraint.isActive = true
        downStackViewHeightConstraint.constant = 32
    }
    
    private func replyState() {
        textView.isHidden = false
        sendButton.isHidden = false
        upperStackView.isHidden = false
        documentCollectionView.isHidden = false
        replyButton.isHidden = true
        lowStackViewTopConstraint.isActive = false
        downStackViewHeightConstraint.constant = 42
    }
    
//    private func addButtonMenu() {
//        var actionList = [UIAction]()
//
//        for thread in threadList {
//            let action = UIAction(title: thread.title) { _ in
//                self.threadButton.setTitle(thread.title, for: .normal)
//                self.currentThread = thread
//            }
//            actionList.append(action)
//        }
//
//        let menu = UIMenu(title: "Thread list", children: actionList)
//
//        threadButton.role = .normal
//        threadButton.menu = menu
//        threadButton.showsMenuAsPrimaryAction = true
//    }
    
    func addImage(_ imageList: [UIImage]) {
        documentImageList.append(contentsOf: imageList)
        documentCollectionViewController.addImage(imageList)
    }
    
    private func closeReplyView() {
        isReplying = false
        textView.resignFirstResponder()
        self.notReplyingState()
        self.layoutIfNeeded()
        textView.text = ""
    }
    
}
