//
//  PostViewController.swift
//  OpenMarket
//
//  Created by Do Yi Lee on 2021/08/10.
//

import UIKit

class PostViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
 

}

extension PostViewController {
    func encode() -> Data? {
        guard let str = textField.text else {
            return nil
        }
        
        let data = Encoder(title: "\(str)", descriptions: "b", price: 1, currency: "c", stock: 2, discounted_price: 3, password: "d", images: ["https://images.unsplash.com/photo-1622495488220-9982960ff3e3?ixid=MnwxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1267&q=80"])
        
        let encoder = JSONEncoder()
        return try? encoder.encode(data)
    }
    
    func createBoday(withPara para: [String:String]?, media: String?, boundary: String) {
        
    }
    
    @IBAction func sendPost(_ sender: Any) {
        let sendData = encode()
        
        let url = URL(string: "https://camp-open-market-2.herokuapp.com/item")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("multipart/form-data", forHTTPHeaderField: "Content-type")
        request.httpBody = sendData
        
        URLSession.shared.uploadTask(with: request, from: sendData) { (data, response, error) in
            if let error = error {
                print("에러")
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("노리스펀스")
                return
            }
            

            guard let data = data else {
                print("노데이터")
                return
            }
            
        }
    }
}
