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

    @IBAction func post(_ sender: Any) {
        let session = URLSession()
        let test = NetworkManager(session: session)
        let url = URL(string: "https://camp-open-market-2.herokuapp.com/item")!
        let par = []
        test.createHTTPBody(with: , media: <#T##[Media]?#>)
        test.request(httpMethod: HTTPMethod.post, url: url, body: <#T##Data?#>, completionHandler: <#T##(Result<Data, NetworkError>) -> ()#>)
    }
    
}

