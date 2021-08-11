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
//step1 : 이미지를 보낼 Media타입 만들기, 해당 타입에는 ContentDisposition에들어갈 정보, 이미지 자체의 데이터를 만드는 과정 등이 포함된다
//stpe2 : 바운더리 만들기
//step3 : http바디 만들기
//stpe4 : postRequest함수만들기


extension PostViewController {
    //MARK:- Step2
    func generateBoundary() -> String {
        let randomBoundaryString = UUID.init()
        return "Boundary-\(randomBoundaryString)"
    }
    
    //MARK:- Step3
    func createHTTPBody(withParameters para: [String:Any]?, image: [Media?], boundary: String) -> Data {
        
        let lineBreak = "\r\n" // 개행
        var body = Data() // 데이터 담을 곳
        
        // key-value의 사전형태로 post할 정보가 파라미터로 들어감
        if let parameters = para {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value)\(lineBreak)")
            }
        }
        // 이미지의 경우 따로 처리해준다.
        for photo in image {
            body.append("--\(boundary + lineBreak)")
            body.append("Content-Disposition: form-data; name=\"\(photo?.key)\"; filename=\"\(photo?.filename)\"\(lineBreak)")
            body.append("Content-Type: \(photo?.mimeType ?? "에러" +  lineBreak + lineBreak)")
            body.append(photo?.data ?? Data())
            body.append(lineBreak)
        }
        
        
        //body끝나는 부분은 -- 를 말미에 추가해준다.
        body.append("--\(boundary)--\(lineBreak)")
        
        return body
    }
    
    @IBAction func sendPost(_ sender: Any) {
        //MARK:-Step4
        guard let testImages = UIImage(named: "testImage") else { return }
        let imagesArray = [Media(withImage: testImages, forkey: "testImage", mimeType: "image/jpeg", filename: "testImage.jpg")]
        
        let parameters = ["title": "테스트", "descriptions": "테스트제발성공", "price" : 100, "stock": 100, "discounted_price": 10, "password": "12345"] as [String : Any]
        
        //메소드 해당 부분
        guard let url = URL(string: "https://camp-open-market-2.herokuapp.com/item") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
    
        let boundary = generateBoundary()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let dataBody = createHTTPBody(withParameters: parameters, image: imagesArray, boundary: boundary)
        request.httpBody = dataBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            
            if let data = data {
                do {
                    let json = try ParsingManager.parse(data: data, type: OpenMarketItems.Item.self)
                    print(json)
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
}


extension Data {
    //MARK:- Step3.1 : 해당 파라미터를 데이터타입으로 바꾸어서 추가
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}




//    func encode() -> Data? {
//        guard let str = textField.text else {
//            return nil
//        }
//
//        let data = Encoder(title: "\(str)", descriptions: "b", price: 1, currency: "c", stock: 2, discounted_price: 3, password: "d", images: ["https://images.unsplash.com/photo-1622495488220-9982960ff3e3?ixid=MnwxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1267&q=80"])
//
//        let encoder = JSONEncoder()
//        return try? encoder.encode(data)
//    }
