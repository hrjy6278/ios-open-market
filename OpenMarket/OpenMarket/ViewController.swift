//
//  OpenMarket - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var openMarketItem: [OpenMarketItems.Item]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let session = URLSession.shared
        let networkManager = NetworkManager(session: session)
        guard let url = URL(string: "https://camp-open-market-2.herokuapp.com/items/1") else { return }
        
        let boundary = networkManager.generateBoundary()
        
        let body = networkManager.createHTTPBody(boundary, with: nil, media: nil)
        networkManager.request(boundary, httpMethod: .get, url: url, body: body) { data in
//            self.openMarketItem = try? ParsingManager.parse(data: data, type: OpenMarketItems.Item.self)
            guard let jsonData = try? ParsingManager.parse(data: data, type: [OpenMarketItems].self) else { return }
            self.openMarketItem = jsonData
            self.collectionView.reloadData()
        }
    }
}



//    @IBAction func postButton(_ sender: Any) {
//        let session = URLSession.shared
//        let networkManager = NetworkManager(session: session)
//        guard let url = URL(string: "https://camp-open-market-2.herokuapp.com/") else { return }
//        guard let img = UIImage(named: "cat") else { return }
//        guard let imgMedia = Media(image: img, key: .images, mimeType: .jpeg, fileName: "cat") else { return }
//
//        let parameters: [String: Any] = ["title": "테스트", "descriptions": "테스트제발성공", "price" : 100, "stock": 100, "discounted_price": 10, "currency": "Euro", "password": "12345"]
//        let boundary = networkManager.generateBoundary()
//
//        let body = networkManager.createHTTPBody(boundary, with: parameters, media: [imgMedia])
//        networkManager.request(boundary, httpMethod: .post, url: url, body: body) { result in
//            print(result)
//        }
//    }


extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return openMarketItem?.items.count ?? .zero
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCell else { return UICollectionViewCell() }
        
        // 이미지 가져오기
        
        let session = URLSession.shared
        let networkManager = NetworkManager(session: session)
        let boundary = networkManager.generateBoundary()
        let url = URL(string: (openMarketItem?.items[indexPath.item].thumbnails.first!)!)!
        let body = networkManager.createHTTPBody(boundary, with: nil, media: nil)

        networkManager.request(boundary, httpMethod: .get, url: url, body: body) { image in
            DispatchQueue.main.async {
                cell.thumbnailImage.image = UIImage(data: image)
                self.collectionView.reloadData()
            }
        }

        return cell
    }
    

}
