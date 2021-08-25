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
//    var indexpath = ""
}

extension OpenMarketItemCell {
    // 여기서 메소드를 하나 만들어서 configure에서 메소드를 호출 -> 그 이미지를 반영
    func configure(item: OpenMarketItems.Item, _ indexPath: IndexPath, _ cv: UICollectionView,  _ ch: @escaping (UICollectionView, UICollectionViewCell) -> ()) {
        titleLabel.text = item.title
        
//        if indexPath.item == cv.indexPath(for: self)?.item {
//    downloadImage(reqeustURL: item.thumbnails.first ?? "", indexPath, cv)
//        }
        ch(cv)

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
   
    func downloadImage(reqeustURL: String, _ ip: IndexPath, _ cv: UICollectionView) {
        
        URLSession.shared.dataTask(with: URL(string: reqeustURL)!) { data, error, _ in
            
            if let error = error {
                dump(error)
            }
            
            guard let data = data else { return }
            
            guard let downloadImage = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {

//                guard let test2 = cv.indexPath(for: self)?.item else { return }
                // 원래의 인덱스, 셀 재사용 인덱스같을 때 이미지 => 이게 만족이 안됨
//                if ip.item == cv.indexPath(for: self)?.item {
                self.itemImage.image = downloadImage
//                    self.tag = 0
//                }
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
