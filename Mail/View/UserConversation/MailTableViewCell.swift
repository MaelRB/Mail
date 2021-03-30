//
//  MailTableViewCell.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 17/03/2021.
//

import UIKit

class MailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with model: Mail) {
        profileImageView.image = model.sender.profilePicture
        contentLabel.text = model.message
        
        let headerText = "\(model.sender.name)  \(model.date.relativeDate())"
        let mutableString = NSMutableAttributedString(string: headerText, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)])
        mutableString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 16), range: NSRange(location: 0, length: model.sender.name.count))
        titleLabel.attributedText = mutableString
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        
        contentLabel.numberOfLines = 0
        contentLabel.lineBreakMode = .byWordWrapping
        contentLabel.sizeToFit()
        
        imageCollectionView.isHidden = true // Hide if no content
    }
    
}
