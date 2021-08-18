//
//  ImageCache.swift
//  OpenMarket
//
//  Created by KimJaeYoun on 2021/08/18.
//

import UIKit

class ImageCache: NSCache<AnyObject, AnyObject> {
    func add(_ image: UIImage, forkey key: Int) {
        setObject(image, forKey: key as AnyObject)
    }
    
    func image(forkey key: Int) -> UIImage? {
        guard let image = object(forKey: key as AnyObject) as? UIImage else {
            return nil
        }
        return image
    }
}


