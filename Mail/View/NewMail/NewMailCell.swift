//
//  ThreadPresentationCell.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 12/03/2021.
//

import UIKit

class NewMailCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var mail: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var newIndicator: UIImageView!
    @IBOutlet var flag: UIImageView!
    @IBOutlet var sender: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with model: Thread) {
        imageView.image = model.mailList.first!.sender.profilePicture
        title.text = model.title
        mail.text = model.mailList.first!.message
        date.text = model.modifiedDate.relativeDate()
        sender.text = model.mailList.first!.sender.name
        
        // TODO: - Hide flag or new indicator
        newIndicator.isHidden = !model.isNew
        flag.isHidden = !model.isFlagged
        
        imageView.layer.cornerRadius = imageView.frame.width / 2
    }

}
