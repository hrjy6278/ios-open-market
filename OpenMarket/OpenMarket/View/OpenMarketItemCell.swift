//
//  OpenMarketItemCell.swift
//  OpenMarket
//
//  Created by KimJaeYoun on 2021/08/20.
//

import UIKit

class OpenMarketItemCell: UICollectionViewCell, StrockText, DigitStyle {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var discountedPriceLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    var indexpath = ""
}

extension OpenMarketItemCell {
    func configure(item: OpenMarketItems.Item, _ indexPath: IndexPath, _ cv: UICollectionView,  _ ch: @escaping (UICollectionView, IndexPath) -> ()) {
        
        ch(cv, indexPath)

        titleLabel.text = item.title
 

        if item.stock == 0 {
            statusLabel.text = "품절"
            statusLabel.textColor = .systemYellow
        } else {
            let stock = apply(to: item.stock)
            statusLabel.textColor = .systemGray
            statusLabel.text = "잔여수량: \(stock)"
        }
        
        if let discountedPrice = item.discountedPrice {
            discountedPriceLabel.textColor = .systemGray
            discountedPriceLabel.text = "\(item.currency) \(apply(to: discountedPrice))"
            let strockText = strock(text: "\(item.currency)" + apply(to: item.price))
            priceLabel.attributedText = strockText
            priceLabel.textColor = .systemRed
        } else {
            discountedPriceLabel.isHidden = true
            priceLabel.textColor = .systemGray
            priceLabel.text = "\(item.currency) \(apply(to: item.price))"
        }
    }
   
    func downloadImage(reqeustURL: String, _ ip: IndexPath, _ cv: UICollectionView, _ completionHandler: @escaping (UIImage) -> ()) {
        
        URLSession.shared.dataTask(with: URL(string: reqeustURL)!) { data, error, _ in
            
            if let error = error {
                dump(error)
            }
            
            guard let data = data else { return }
            
            guard let downloadImage = UIImage(data: data) else { return }
            
            // 문제가 되는 부분, cv, indexPath는 잘 전달이 되는데 cv.indexPath(for:cell)의 값이 계속  nil 입니다!
            DispatchQueue.main.async {
                if ip.item == cv.indexPath(for: self)?.item {
                    self.itemImage.image = downloadImage
                }
            }
        }.resume()
    }

    override func prepareForReuse() {
        priceLabel.attributedText = nil
        discountedPriceLabel.textColor = .black
        discountedPriceLabel.text = nil
        discountedPriceLabel.isHidden = false
        
        titleLabel.text = nil
        priceLabel.text = nil
        statusLabel.textColor = .black
        statusLabel.text = nil
        itemImage.image = nil
        priceLabel.textColor = .black
    }
}
//                print(cv)
//                print("\(self) 셀")
//                print(ip ,cv.indexPath(for: self))
//                if self.tag == indexPath.item {
//                큐 안에 있는지 확인하기!!!!!!!!!!
