//
//  Data + Extension.swift
//  OpenMarket
//
//  Created by KimJaeYoun on 2021/08/11.
//

import Foundation

extension Data {
    mutating func append(_ string: String) {
        let data = Data(string.utf8)
            append(data)
    }
}
