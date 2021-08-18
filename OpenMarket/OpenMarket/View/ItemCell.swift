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
    @IBOutlet weak var discountedPrice: UILabel!
    
    func strockLabel(_ item: OpenMarketItems.Item) {
        
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "\(item.price)")
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            priceText?.attributedText = attributeString
            priceText?.textColor = .red
        }
    
    
    func update(_ item: OpenMarketItems.Item?) {
        guard let item = item else { return }
        
        priceText?.text = "\(item.currency)\(item.price)"
        titleText?.text = item.title
        statusText?.text = "잔여수량: \(item.stock)"
        statusText?.textColor = .systemGray
        priceText.textColor = .systemGray
        statusText.textColor = .systemGray
        discountedPrice?.isHidden = true
        
        if item.stock == 0 {
            statusText?.text = "품절"
            statusText?.textColor = .systemYellow
            discountedPrice?.isHidden = true
        }
        
        if let discounted = item.discountedPrice {
            strockLabel(item)
            discountedPrice?.text = "\(item.currency)\(discounted)"
            discountedPrice?.isHidden = false

        }
    }
    
    func updateImage(_ image: UIImage) {
        listImage.image = image
    }
    
    override func prepareForReuse() {
//        self.discountedPrice = nil
//        self.priceText = nil
//        self.statusText = nil
//        self.titleText = nil
    }
    
}
