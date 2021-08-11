//
//  Media.swift
//  OpenMarket
//
//  Created by KimJaeYoun on 2021/08/11.
//

import Foundation
import UIKit

struct Media {
    let key: String
    let fileName: String
    let data: Data
    let mimeType = "Image/jpeg"
    
    init?(withImage image: UIImage?, forkey key: String) {
        self.key = key
        self.fileName = "\(arc4random()).jpeg"
        guard let data = image?.jpegData(compressionQuality: 0.7) else { return nil }
        self.data = data
    }
}
