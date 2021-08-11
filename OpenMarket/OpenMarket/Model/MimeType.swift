//
//  MimeType.swift
//  OpenMarket
//
//  Created by KimJaeYoun on 2021/08/11.
//

import Foundation

enum MimeType: CustomStringConvertible {
    case applicationJSON
    case imageJPEG
    case multipartFormData
    
    var description: String {
        switch self {
        case .applicationJSON:
            return "applications/json"
        case .imageJPEG:
            return "image/jpeg"
        case .multipartFormData:
            return "multipart/form-data"
        }
    }
}
