//
//  OpenMarket - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var openMarketItemList: OpenMarketItems?
//    var openMarketItem: OpenMarketItems.Item?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        
        let networkManager = NetworkManager(session: URLSession.shared)
        let url = URL(string: "https://camp-open-market-2.herokuapp.com/items/1")!
        
        networkManager.request(httpMethod: .get, url: url, body: nil, nil) { result in
            
            switch result {
            case .failure(let error):
                print(error)
            case .success(let success):
                self.openMarketItemList = try ParsingManager.jsonDecode(data: success, type: OpenMarketItems.self)
            }
            
        }
        
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as? ItemCell else { return UICollectionViewCell()}

        let networkManager = NetworkManager.init(session: URLSession.shared)

        
        let openMarketItems = openMarketItemList?.items.flatMap { $0 }
        let thumbnailUrl = openMarketItems?[indexPath.item].thumbnails.first
        guard let url = URL(string: thumbnailUrl!) else { return UICollectionViewCell() }
       
        networkManager.request(httpMethod: .get, url: url, body: nil, nil) { result in
            switch result {
            case .success(let data):
                guard let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    cell.update(openMarketItems?[indexPath.row])

                    cell.updateImage(image)
                }
            case .failure(let error):
                print(error)
            }
        }
        return cell
    
    }


}

