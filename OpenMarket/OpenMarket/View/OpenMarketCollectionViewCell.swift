//
//  OpenMarketCollectionViewCell.swift
//  OpenMarket
//
//  Created by KimJaeYoun on 2021/08/18.
//

import UIKit

class OpenMarketCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var itemDescriptionStackView: UIStackView!
    @IBOutlet weak var thumnailImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var stockNumberLabel: UILabel!
    let label = UILabel()
    func configure(thumbnail: UIImage?, nameLabel: String, discountedPrice: Int?, price: Int, stockNumber: Int, currency: String) {
        
        setupStockLabel(stockNumber)
        let price = convertToString.convert(of: price)
        
        
        self.nameLabel.text = nameLabel
        self.thumnailImage.image = thumbnail
        if discountedPrice == nil {
            self.priceLabel.text = "\(currency) \(price)"
        } else {
            let discountedText = convertToString.convert(of: discountedPrice)
            let attributeString = NSMutableAttributedString(string: "\(currency) \(discountedText)")
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            priceLabel.attributedText = attributeString
            priceLabel.textColor = .systemRed
            
            
            label.text = "\(currency) \(discountedText)"
            label.textAlignment = .center
            stackView.addArrangedSubview(label)
        }
        
    }
    
    private func setupStockLabel(_ stockNumber: Int) {
        if stockNumber == 0 {
            self.stockNumberLabel.text = "품절"
            self.stockNumberLabel.textColor = .systemOrange
        } else {
            let stock = convertToString.convert(of: stockNumber)
            self.stockNumberLabel.text = "잔여수량 : \(stock)"
        }
    }
    
    
    override func prepareForReuse() {
        self.nameLabel.text = nil
        self.stockNumberLabel.text = nil
        self.stockNumberLabel.textColor = .black
        self.priceLabel.attributedText = nil
        self.priceLabel.textColor = .black
        self.label.text = nil
    }
}
