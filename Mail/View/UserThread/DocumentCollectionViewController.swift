//
//  DocumentCollectionViewController.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 21/03/2021.
//

import UIKit

class DocumentCollectionViewController {
    
    private enum Section {
        case main
    }
    
    var collectionView: UICollectionView
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, UIImage>!
    
    private var snapshot = NSDiffableDataSourceSnapshot<Section, UIImage>()
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        setup()
    }
    
    private func setup() {
        collectionView.collectionViewLayout = createLayout()
        setDataSource()
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalHeight(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func setDataSource() {
        
        collectionView.register(UINib.init(nibName: "DocumentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "documentCell")
        
        dataSource = UICollectionViewDiffableDataSource<Section, UIImage>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, identifier) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "documentCell", for: indexPath) as! DocumentCollectionViewCell
            cell.configure(collectionVC: self, model: identifier)
            return cell
        })
        
        snapshot.appendSections([Section.main])
    }
    
    func addImage(_ imageList: [UIImage]) {
        snapshot.appendItems(imageList, toSection: .main)
        dataSource.apply(snapshot)
    }
    
    func deleteImage(_ image: UIImage) {
        snapshot.deleteItems([image])
        dataSource.apply(snapshot)
    }
}
