//
//  MailCollectionViewCell.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 15/03/2021.
//

import UIKit

class MailCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var labelHeightConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with model: Mail) {
        imageView.image = model.sender.profilePicture
        label.text = model.message
        
        let headerText = "\(model.sender.name)  \(model.date.relativeDate())"
        let mutableString = NSMutableAttributedString(string: headerText, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)])
        mutableString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 16), range: NSRange(location: 0, length: model.sender.name.count))
        headerLabel.attributedText = mutableString
        
        imageView.layer.cornerRadius = imageView.frame.width / 2
        
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        
        labelHeightConstraint.constant = label.frame.height
    }

}
