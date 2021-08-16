//
//  OpenMarket - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func postButton(_ sender: Any) {
        let session = URLSession.shared
        let test = NetworkManager(session: session)
        guard let url = URL(string: "https://camp-open-market-2.herokuapp.com/item") else { return }
        guard let img = UIImage(named: "cat") else { return }
        guard let imgMedia = Media(image: img, key: .images, mimeType: .jpeg, fileName: "cat") else { return }
        
//                guard let testImages = UIImage(named: "2") else { return }
//        //        let imagesArray = [Media(withImage: testImages, forkey: "testImage", mimeType: "image/jpeg", filename: "phototestImage.jpeg")]
//
//            guard let testImage = Media(withImage: img, forkey: "images[]", mimeType: "image/jpg", filename: "asdf.jpg") else { return }
        
            let parameters: [String: Any] = ["title": "테스트", "descriptions": "테스트제발성공", "price" : 100, "stock": 100, "discounted_price": 10, "currency": "Euro", "password": "12345"]
        
        
        let body = test.createHTTPBody(with: parameters, media: [imgMedia])
        test.request(httpMethod: .post, url: url, body: body) { result in
            print(result)
        }
    }
    
}

