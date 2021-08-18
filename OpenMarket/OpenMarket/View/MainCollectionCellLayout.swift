//
//  MainCollectionCellLayout.swift
//  OpenMarket
//
//  Created by Do Yi Lee on 2021/08/18.
//

import UIKit
struct Layout {
    
    static func setupCollectionViewLayOut(_ view: UIView, _ collectionView: UICollectionView, _ changeScrollDirection: Bool) -> UICollectionViewFlowLayout{
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.minimumLineSpacing = 8
        flowLayout.minimumInteritemSpacing = 8
        flowLayout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        let halfWidth = view.bounds.width / 2.2
        let halfHeight = view.bounds.height / 2.4
        flowLayout.itemSize = CGSize(width: halfWidth , height: halfHeight - 50)
        collectionView.collectionViewLayout = flowLayout
        
        if changeScrollDirection == true {
            flowLayout.scrollDirection = .horizontal
        }
    
        return flowLayout
    }
}
