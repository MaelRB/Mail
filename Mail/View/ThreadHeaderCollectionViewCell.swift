//
//  ThreadHeaderCollectionViewCell.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 15/03/2021.
//

import UIKit

class ThreadHeaderCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(info: String, title: String) {
        infoLabel.text = info
        titleLabel.text = title
    }

}
