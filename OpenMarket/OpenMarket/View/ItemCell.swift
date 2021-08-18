//
//  ItemCell.swift
//  OpenMarket
//
//  Created by Do Yi Lee on 2021/08/18.
//

import UIKit

class ItemCell: UICollectionViewCell {
    
    @IBOutlet weak var listImage: UIImageView!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var priceText: UILabel!
    @IBOutlet weak var statusText: UILabel!
    
    func update(_ item: OpenMarketItems.Item?) {
        priceText?.text = item?.currency ?? "Won" + "\(item?.price)"
        titleText.text = item?.title
        if item?.stock == 0 {
            statusText.text = "품절"
        } else {
            statusText.text = "\(item?.stock)"
        }

    }
    
    func updateImage(_ image: UIImage) {
        listImage.image = image
    }


}
