//
//  DocumentCollectionViewCell.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 21/03/2021.
//

import UIKit

class DocumentCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteView: UIImageView!
    
    weak var collectionVC: DocumentCollectionViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imageView.layer.cornerRadius = 5
        deleteView.layer.cornerRadius = 6
        deleteView.transform = CGAffineTransform(translationX: 1, y: -1)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(deleteViewTap))
        deleteView.addGestureRecognizer(tapGesture)
        deleteView.isUserInteractionEnabled = true
    }
    
    func configure(collectionVC: DocumentCollectionViewController, model: UIImage) {
        self.collectionVC = collectionVC
        imageView.image = model
    }
    
    @objc func deleteViewTap() {
        collectionVC?.deleteImage(imageView.image!)
    }
}
