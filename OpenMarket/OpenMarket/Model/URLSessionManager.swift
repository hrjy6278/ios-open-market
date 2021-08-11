//
//  URLSessionManager.swift
//  OpenMarket
//
//  Created by KimJaeYoun on 2021/08/10.
//

import Foundation
import UIKit

enum NetWorkError: LocalizedError {
    case URLError
    case invalidURL
    case failureResponse
    case unknownError
    case failureData
    case decodeError
    
    var errorDescription: String? {
        switch self {
        case .URLError:
            return "URL을 잘못쓰셨어요"
        case .invalidURL:
            return "URL이 유효하지 않습니다. "
        case .failureResponse:
            return "접속에 실패하였습니다."
        case .unknownError:
            return "알 수 없는 에러가 발생하였습니다."
        case .failureData:
            return "데이터를 가져오는데 실패하였습니다."
        case .decodeError:
            return "데이터를 디코딩하는데 실패하였습니다."
        }
    }
}

enum HTTPMethod: CustomStringConvertible {
    case get
    case post
    case delete
    case put
    case patch
    
    var description: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        case .delete:
            return "DELETE"
        case .put:
            return "PUT"
        case .patch:
            return "PATCH"
        }
    }
}

enum Url: CustomStringConvertible {
    case openMarket
    case openMarketItem
    
    var description: String {
        switch self {
        case .openMarket:
            return "https://camp-open-market-2.herokuapp.com/items/"
        case .openMarketItem:
            return "https://camp-open-market-2.herokuapp.com/item/"
        }
    }
}


enum URLSessionManager {
    
    static func dataTask(urlRequest: URLRequest,
                         completionHanler: @escaping (Result<Data, NetWorkError>) -> ()) {
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard error == nil else {
                completionHanler(.failure(.invalidURL))
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode) else {
                print(response)
                completionHanler(.failure(.failureResponse))
                return
            }
            
            guard let data = data else {
                completionHanler(.failure(.failureData))
                return
            }
            completionHanler(.success(data))
        }.resume()
    }
    
    private static func generateBoundaryID() -> String {
        return UUID().uuidString
    }
    
    private static func createMultiPartBodyData(withParamters parameters: [String : Any]?,
                                                boundary: String) -> Data? {
        
        guard let parameters = parameters else {
            return nil
        }
        
        let lineBreak = "\r\n" // 개행
        var data = Data()
        
        for (key, value) in parameters {
            if let medias = value as? [Media] {
                medias.forEach { media in
                    data.append("--\(boundary + lineBreak)")
                    data.append("Content-Disposition: form-data; name=\"\(media.key)\"; filename=\"\(media.fileName)\"\(lineBreak)")
                    data.append("Content-Type: \(media.mimeType)\(lineBreak + lineBreak)")
                    data.append(media.data)
                    data.append(lineBreak)
                }
            }
            data.append("--\(boundary + lineBreak)")
            data.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
            data.append("\(value)\(lineBreak)")
            
//            data.append(boundaryPrefix)
//            data.append("Content-Disposition: form-data; name=\"\(media.key)\"; filename=\"\(media.fileName)\"\r\n")
//            data.append("Content-Type: \(media.mimeType)\r\n\r\n")
//            data.append(media.data)
//            data.append("\r\n")
//
//            data.append(boundaryPrefix)
//            data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
//            data.append("\(value)\r\n")
        }
        data.append("--\(boundary)--\(lineBreak)")
        return data
        
//        let lineBreak = "\r\n" // 개행
//        var body = Data() // 데이터 담을 곳
//
//        // key-value의 사전형태로 post할 정보가 파라미터로 들어감
//        if let parameters = para {
//            for (key, value) in parameters {
//                body.append("--\(boundary + lineBreak)")
//                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
//                body.append("\(value)\(lineBreak)")
//            }
//        }
//        // 이미지의 경우 따로 처리해준다.
//        for photo in image {
//            body.append("--\(boundary + lineBreak)")
//            body.append("Content-Disposition: form-data; name=\"\(photo?.key)\"; filename=\"\(photo?.filename)\"\(lineBreak)")
//            body.append("Content-Type: \(photo?.mimeType ?? "에러" +  lineBreak + lineBreak)")
//            body.append(photo?.data ?? Data())
//            body.append(lineBreak)
//        }
//
//
//        //body끝나는 부분은 -- 를 말미에 추가해준다.
//        body.append("--\(boundary)--\(lineBreak)")
    }
    
    private static func createJSONBodyData(parameters: [String : Any]?) -> Data? {
        guard let parameters = parameters else { return nil }
        
        for (_, value) in parameters {
            if let password = value as? itemLoginPassword {
                guard let encodeData = try? ParsingManager.encode(value: password) else {
                    return nil
                }
                return encodeData
            }
        }
        return nil
    }
    
    static func createURLRequest(url: String,
                                 httpMethod: HTTPMethod,
                                 parameters: [String : Any]? = nil,
                                 mimeType: MimeType? = nil) throws -> URLRequest {
        
        guard let url = URL(string: url) else {
            throw NetWorkError.URLError
        }
        let boundary = UUID().uuidString
        var URLRequset = URLRequest(url: url)
        URLRequset.httpMethod = String(describing: httpMethod)
        
        if let mimeType = mimeType {
            switch mimeType {
            case .applicationJSON:
                let data = createJSONBodyData(parameters: parameters)
                URLRequset.httpBody = data
            case .multipartFormData:
                let data = createMultiPartBodyData(withParamters: parameters,
                                                   boundary: boundary)
                URLRequset.httpBody = data
            default:
                break
            }
            URLRequset.setValue("\(mimeType); boundary=\(boundary)",
                                forHTTPHeaderField: "Content-Type")
        }
        return URLRequset
    }
}


//
//struct ParsingManager {
//    private let session: URLSessionManager
//
//
//    init(URLSessionManager: URLSessionManager) {
//        self.session = URLSessionManager
//    }
//
//    func dataParsing<T: Codable>(dataType: T.Type,
//                                 url: Url,
//                                 completion: @escaping (Result<T, NetWorkError>) -> ()) {
//        session.dataTask(resource: String(describing: url)) { result in
//            switch result {
//            case .success(let data):
//                guard let data = try? JSONDecoder().decode(dataType, from: data) else {
//                    completion(.failure(.decodeError))
//                    return
//                }
//                completion(.success(data))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//}

