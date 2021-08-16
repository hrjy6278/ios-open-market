//
//  NetworkManager.swift
//  OpenMarket
//
//  Created by KimJaeYoun on 2021/08/13.
//

import Foundation

enum NetworkError: Error {
    case urlInvalid
    case requestError
    case responseError
}

struct NetworkManager {
    let session: URLSession
//    let url: URLSession
    typealias userInput = [String: Any]
    
    func generateBoundary() -> String {
        return "Boundary\(UUID().uuidString)"
    }
    
    private func makeContentDispositionLine() -> String {
        return "Content-Disposition: form-data; "
    }
    
    func createHTTPBody(_ boundary: String, with parameters: userInput?, media: [Media]?) -> Data {
        let boundary = boundary
        let lineBreak = "\r\n"
        var body = Data()
        
        if let parameters = parameters {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("\(makeContentDispositionLine())name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value)\(lineBreak)")
            }
        }
        
        if let media = media {
            for image in media {
                body.append("--\(boundary + lineBreak)")
                body.append("\(makeContentDispositionLine())name=\"\(image.key.description)\"; filename=\"\(image.fileName)\"\(lineBreak)")
                body.append("Content-Type: \(image.mimeType.description + lineBreak + lineBreak)") 
                body.append(image.data)
                body.append(lineBreak)
            }
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        
        return body
    }
    
    private func createRequest(httpMethod: HTTPMethod, url: URL, body: Data) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.description
        request.httpBody = body
        print("createRequest의 바디\(dump(body))")
        return request
    }
    
//    private func makeUrl(path: String) -> Result<URL, NetworkError> {
//        guard let url = URL(string: "https://camp-open-market-2.herokuapp.com/item/\(path)") else { return .failure(NetworkError.urlInvalid) }
//        return .success(url)
//    }
    
    func request(_ boundary: String, httpMethod: HTTPMethod, url: URL, body: Data, completionHandler: @escaping (Result<Data, NetworkError>) -> ()) {
        var request = createRequest(httpMethod: httpMethod, url: url, body: body)
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        dump(request.allHTTPHeaderFields)
        dump(String(data: body, encoding: .utf8))
        
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completionHandler(.failure(.requestError))
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                completionHandler(.failure(.responseError))
                print(response)
                return
            }
            
            if let data = data {
                completionHandler(.success(data))
            }
        }.resume()
    }
}

//
//func createHTTPBody(withParameters para: [String: Any]?, image: [Media]?, boundary: String) -> Data {
//
//    let lineBreak = "\r\n" // 개행
//    var body = Data() // 데이터 담을 곳
//
//    // key-value의 사전형태로 post할 정보가 파라미터로 들어감
//    if let parameters = para {
//        for (key, value) in parameters {
//            body.append("--\(boundary + lineBreak)")
//            body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
//            body.append("\(value)\(lineBreak)")
//        }
//    }
//    // 이미지의 경우 따로 처리해준다.
//    if let image = image {
//    for photo in image {
//        body.append("--\(boundary + lineBreak)")
//        body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
//        body.append("Content-Type: \(photo.mimeType +  lineBreak + lineBreak)")
//        body.append(photo.data)
//        body.append(lineBreak)
//    }
//    }
//    //body끝나는 부분은 -- 를 말미에 추가해준다.
//    body.append("--\(boundary)--\(lineBreak)")
////        print(body)
//    return body
//}
//
//@IBAction func sendPost(_ sender: Any) {
//    //MARK:-Step4

//    let img = #imageLiteral(resourceName: "cat")
//    guard let testImage = Media(withImage: img, forkey: "images[]", mimeType: "image/jpg", filename: "asdf.jpg") else { return }
//    let parameters: [String: Any] = ["title": "테스트", "descriptions": "테스트제발성공", "price" : 100, "stock": 100, "discounted_price": 10, "currency": "Euro", "password": "12345"]
//
//    //메소드 해당 부분
//    guard let url = URL(string: "https://camp-open-market-2.herokuapp.com/item") else { return }
//    var request = URLRequest(url: url)
//    request.httpMethod = "POST"
//
//    let boundary = generateBoundary()
//
//    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
////        request.addValue("", forHTTPHeaderField: "Content-Encoding")
//
//
