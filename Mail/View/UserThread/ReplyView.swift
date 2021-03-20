//
//  ReplyView.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 19/03/2021.
//

import UIKit

protocol ReplyViewDelegate {
    func replyDidTap()
    func sendDidTap()
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
    
    // MARK: - Properties
    
    var delegate: ReplyViewDelegate?
    
    private var lowStackViewTopConstraint: NSLayoutConstraint!
    
    var threadList = [Thread]() {
        didSet {
            threadButton.setTitle(threadList.first?.title ?? "No thread", for: .normal)
            addButtonMenu()
        }
    }
    
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
        
        notReplyingState()
    }
    
    // MARK: - Action methods
    
    @IBAction func documentButtonTapped(_ sender: Any) {
    }
    
    @IBAction func replyButtonTapped(_ sender: Any) {
        textView.becomeFirstResponder()
        replyState()
        self.layoutIfNeeded()
        delegate?.replyDidTap()
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        textView.resignFirstResponder()
        self.notReplyingState()
        self.layoutIfNeeded()
        delegate?.sendDidTap()
    }
    
    // MARK: - State transition methods
    
    private func notReplyingState() {
        textView.isHidden = true
        sendButton.isHidden = true
        upperStackView.isHidden = true
        documentCollectionView.isHidden = true
        replyButton.isHidden = false
        lowStackViewTopConstraint.isActive = true
    
    }
    
    private func replyState() {
        textView.isHidden = false
        sendButton.isHidden = false
        upperStackView.isHidden = false
        documentCollectionView.isHidden = false
        replyButton.isHidden = true
        lowStackViewTopConstraint.isActive = false
    }
    
    private func addButtonMenu() {
        var actionList = [UIAction]()
        
        for thread in threadList {
            let action = UIAction(title: thread.title) { _ in
                self.threadButton.setTitle(thread.title, for: .normal)
            }
            actionList.append(action)
        }
        
        let menu = UIMenu(title: "Thread list", children: actionList)
    
        threadButton.role = .normal
        threadButton.menu = menu
        threadButton.showsMenuAsPrimaryAction = true
    }
    
}
