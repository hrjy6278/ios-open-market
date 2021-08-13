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
}

extension ViewController {
    
    @IBAction func sendRequest(_ sender: Any) {
        let url = URL(string: "https://camp-open-market-2.herokuapp.com//items/1")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        var data = Data()
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("에러")
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("노리스펀스")
                return
            }
            print(response)

            guard let data = data else {
                print("노데이터")
                return
            }
            
            do {
                let data = try ParsingManager.parse(data: data, type: OpenMarketItems.self)
                print("\(data.items)")
            } catch {
                print("파싱오류")
                return
            }
        }.resume()
    }
}
