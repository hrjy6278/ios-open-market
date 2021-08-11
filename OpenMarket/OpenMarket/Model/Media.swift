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
    let mimeType: MimeType
    
    init?(withImage image: UIImage?, forkey key: String, fileName: String, mimeType: MimeType) {
        self.key = key
        self.fileName = fileName
        guard let data = image?.jpegData(compressionQuality: 0.7) else { return nil }
        self.data = data
        self.mimeType = mimeType
    }
}
