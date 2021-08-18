//
//  ImageCell.swift
//  OpenMarket
//
//  Created by Do Yi Lee on 2021/08/18.
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var itemDiscountedPrice: UILabel!
    @IBOutlet weak var itemStatus: UILabel!
    
    func updateUI(_ item: OpenMarketItems) {
//        thumbnailImage.image = UIImage(data: <#T##Data#>)
//
//
//        item.thumbnails[1]
    }
}
