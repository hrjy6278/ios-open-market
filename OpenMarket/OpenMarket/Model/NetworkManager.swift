//
//  NetworkManager.swift
//  OpenMarket
//
//  Created by Do Yi Lee on 2021/08/13.
//

import UIKit

enum HTTPMethod: String {
    case GET, POST, PATCH, DELETE
}

enum ContentType {
    static let multipart = "multipart/form-data"
}

enum APIKey: String {
    case title = "title"
    case descriptions = "descriptions"
    case price = "price"
    case currency = "currency"
    case stock = "stock"
    case discountedPrice = "discounted_price"
    case images = "images[]"
    case password = "password"
}

enum MimeType: String {
    case jpeg = "image/jpeg"
    case png = "image/png"
}

struct Medias {
    let key: String
    let filename: String
    let mimeType: MimeType
    let data: Data

    // image, audio 등 들어가 수 있도록 구현하기
    init?(with jpegImage: UIImage, compressionQuality: CGFloat = 0.7) {
        self.key = APIKey.images.rawValue
        self.filename = "\(arc4random()).jpeg"
        guard let data = jpegImage.jpegData(compressionQuality: compressionQuality) else { return nil }
        self.data = data
        // 모든 이미지가 jpeg로 되는 것 리팩토링 할 필요가 있을 듯
        self.mimeType = MimeType.jpeg
    }
    
    init?(with pngImage: UIImage) {
        self.key = APIKey.images.rawValue
        self.filename = "\(arc4random()).png"
        guard let data = pngImage.pngData() else { return nil }
        self.data = data
        self.mimeType = MimeType.png
    }
}

struct NetworkManager {
    typealias userInputDictionary = [String: Any]
    // creatHTTPBody할 때만 하는 행동이기 때문에 private
    private func makeBoundary() -> String {
        return "--Boundary\(UUID().uuidString)"
    }
    
    private func makeContentDispositionLine() -> String {
        return "Content-Disposition: form-data; "
    }
    
    // http 바디 만들기, 바운더리 만들기, ? 쓰는 이유 : get에서도 사용해 주기 위해????
    private func creatHTTPBody(parameter: userInputDictionary, media: [Medias], contentType: String) -> Data {
        var body = Data()
        
        let boundary = makeBoundary()
        let lineBreak = "\r\n"
        
        
        for (key, value) in parameter {
            body.append(boundary + lineBreak)
            body.append("\(makeContentDispositionLine())name=\"\(key)\"\(lineBreak + lineBreak)")
            body.append("\(value) + \(lineBreak)")
        }
        
        for media in media {
            body.append(boundary + lineBreak)
//            body.append(Data)
        }
        
        return body
    }
    
}

// string을 utf8 로바꿔서 추가해주는 메소드
//extension Data {
//    mutating func append(_ string: String) {
//        if let data = string.data(using: .utf8) {
//            append(data)
//        }
//    }
//}
