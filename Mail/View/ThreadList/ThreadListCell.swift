//
//  ThreadPresentationCell.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 12/03/2021.
//

import UIKit
import MSGraphClientModels

class ThreadListCell: UICollectionViewCell {

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
    
    func configure(with model: MSGraphMessage) {
        
        title.text = model.subject!
        mail.text = model.bodyPreview!
        date.text = model.sentDateTime!.relativeDate()
        sender.text = model.sender!.emailAddress!.name
        
        // TODO: - Hide flag or new indicator
        newIndicator.isHidden = model.isRead
        flag.isHidden = true
    }

}
