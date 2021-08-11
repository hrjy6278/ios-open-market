//
//  Encoder.swift
//  OpenMarket
//
//  Created by Do Yi Lee on 2021/08/10.
//

import UIKit
//
//struct Encoder: Codable {
//    let title: String
//    let descriptions: String
//    let price : Int
//    let currency: String
//    let stock: Int
//    let discounted_price: Int?
//    let password: String
////    let images: Media
//}

struct Media {
    let key: String
    let filename: String
    let data: Data
    let mimeType: String
    
    init?(withImage image: UIImage, forkey key: String, mimeType: String, filename: String) {
        self.key = key
        self.mimeType = mimeType
        self.filename = filename
        guard let data = image.jpegData(compressionQuality: 0.7) else { return nil }
        // 사진을 Data타입으로 바꿈
        self.data = data
    }
}
