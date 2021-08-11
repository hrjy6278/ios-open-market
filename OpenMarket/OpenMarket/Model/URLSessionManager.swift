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

enum requestType: CustomStringConvertible {
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
        
//    guard let url = URL(string: String(describing: url)) else {
//            completionHanler(.failure(.URLError))
//            return
//        }
//
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard error == nil else {
                completionHanler(.failure(.invalidURL))
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode) else {
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
    
    static func generateBoundaryID() -> String {
        return UUID().uuidString
    }
    
    static func createBodyData(withParamters parameters: [String : Any],
                               boundary: String,
                               images: [Media]?) -> Data {
        let boundaryPrefix = "--\(boundary)\r\n"
        var data = Data()
        
        for (key, value) in parameters {
            data.append(Data(boundaryPrefix.utf8))
            data.append(Data("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".utf8))
            data.append(Data("\(value)\r\n".utf8))
        }
        
        if let images = images {
            for image in images {
                data.append(Data(boundaryPrefix.utf8))
                data.append(Data("Content-Disposition: form-data; name=\"\(image.key)\"; filename=\"\(image.fileName)\"\r\n".utf8))
                data.append(Data("Content-Type: \(image.mimeType)\r\n\r\n".utf8))
                data.append(image.data)
                data.append(Data("\r\n".utf8))
            }
        }
        data.append(Data("--\(boundary)-\r\n".utf8))
        return data
    }
    
    static func createURLRequest(url: URL,
                                 httpMethod: String,
                                 parameters: [String : Any]?,
                                 컨텐츠타입: String,
                                 medias: [Media]?) -> URLRequest {
        
        
        guard let url = URL(string: String(describing: Url.openMarket)) else { return }
        
        let boundary = UUID().uuidString
        var URLRequset = URLRequest(url: url)
        URLRequset.httpMethod = httpMethod
        
        
        URLRequset.setValue("\(컨텐츠타입); boundary=\(boundary)",
                            forHTTPHeaderField: "Content-Type")
        //기본일때
        //153부터 155 스위치 컨텐츠 타입에따라
        //제이슨 오브젝트는 제이슨 형태의 데이터를 바디에 담아 보내야함.
        let data = createBodyData(withParamters: parameters,
                                  boundary: boundary,
                                  images: medias)
        
        URLRequset.httpBody = data
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

