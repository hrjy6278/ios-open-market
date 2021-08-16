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
        let networkManager = NetworkManager(session: session)
        guard let url = URL(string: "https://camp-open-market-2.herokuapp.com/") else { return }
        guard let img = UIImage(named: "cat") else { return }
        guard let imgMedia = Media(image: img, key: .images, mimeType: .jpeg, fileName: "cat") else { return }
        
        let parameters: [String: Any] = ["title": "테스트", "descriptions": "테스트제발성공", "price" : 100, "stock": 100, "discounted_price": 10, "currency": "Euro", "password": "12345"]
        let boundary = networkManager.generateBoundary()
        
        let body = networkManager.createHTTPBody(boundary, with: parameters, media: [imgMedia])
        networkManager.request(boundary, httpMethod: .post, url: url, body: body) { result in
            print(result)
        }
    }
}

