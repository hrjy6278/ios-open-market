//
//  OpenMarket - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initButtoActions()
    }

    @IBOutlet weak var GETButton: UIButton!
    @IBOutlet weak var POSTButton: UIButton!
}

extension ViewController {
   func initButtoActions() {
    GETButton.addTarget(self, action: #selector(getOpenMarketList(_:)), for: .touchUpInside)
    POSTButton.addTarget(self, action: #selector(postButton(_:)), for: .touchUpInside)
    }
}


extension ViewController {
    @objc func getOpenMarketList(_ sender: UIButton) {
        let url = String(describing: Url.openMarket) + "1"
        guard let request = try? URLSessionManager.createURLRequest(url: url,
                                                                    httpMethod: .get) else {
            return
        }
        
        ParsingManager.parseForRequestData(request: request,
                                           type: OpenMarketItems.self) { result  in
            DispatchQueue.main.async {
                switch result {
                case .success(let openMarket):
                    print(openMarket.items)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
           
        }
    }
    
    @objc func postButton(_ sender: UIButton) {
        let url = String(describing: Url.openMarketItem)
        let dummyParameters = [
            "title" : "hi",
            "descriptions" : "hihi",
            "price" : 100,
            "currency" : "KRW",
            "stock" : 0,
            "images" : [Media(withImage: .remove, forkey: "remove", fileName: "remove", mimeType: .multipartFormData)],
            "password" : "1"
        ] as [String : Any]
        guard let request = try? URLSessionManager.createURLRequest(url: url, httpMethod: .post, parameters: dummyParameters, mimeType: .multipartFormData) else {
            return
        }
        URLSessionManager.dataTask(urlRequest: request) { result in
            switch result {
            case .success(let data):
                guard let openMarket = try? ParsingManager.parse(data: data, type: OpenMarketItems.Item.self) else {
                    print("디코딩에러")
                    return
                }
                print(openMarket)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
