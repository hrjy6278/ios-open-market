//
//  Encoder.swift
//  OpenMarket
//
//  Created by Do Yi Lee on 2021/08/10.
//

import Foundation

struct Encoder: Codable {
    let title: String
    let descriptions: String
    let price : Int
    let currency: String
    let stock: Int
    let discounted_price: Int?
    let password: String
    let images: [String]
}
