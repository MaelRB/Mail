//
//  AttachmentButton.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 25/04/2021.
//

import UIKit

class AttachmentButton: UIButton {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var docNameLabel: UILabel!
    @IBOutlet weak var docSizeLabel: UILabel!
    
    var attachment: Attachment? {
        didSet {
            docNameLabel.text = attachment!.name
            docSizeLabel.text = attachment!.size
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        Bundle.main.loadNibNamed("AttachmentButton", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.layer.borderWidth = 0.5
        contentView.layer.cornerRadius = 10
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        contentView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func didTap() {
        print(String(data: Data(base64Encoded: attachment!.contentBytes)!, encoding: .utf8))
    }

}
