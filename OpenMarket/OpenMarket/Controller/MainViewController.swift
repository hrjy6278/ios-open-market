//
//  OpenMarket - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var openMarketItemList: OpenMarketItems?
    
    func test() {
        let urlSession = URLSession.shared
        let networkManager = NetworkManager(session: urlSession)
        let url = URL(string: "https://camp-open-market-2.herokuapp.com/items/1")!
        
        networkManager.request(httpMethod: .get, url: url, body: nil, .json) { data in
            switch data {
            case .failure(let error):
                print(error)
            case .success(let result):
                let jsonData = try? ParsingManager.jsonDecode(data: result, type: OpenMarketItems.self)
                DispatchQueue.main.async {
                    self.openMarketItemList = jsonData
                    
                    self.collectionView.reloadData()
                    // discard the dataSource and delegate data and requery as necessary
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        test()
        setupCollectionViewLayOut()
        
    }
}

extension MainViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        openMarketItemList?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as? ItemCell else { return UICollectionViewCell()}

        let openMarketItemArray = openMarketItemList?.items
        let networkManager = NetworkManager(session: URLSession.shared)
        
        let thumbnailUrl = openMarketItemArray?[indexPath.item].thumbnails.first
        
        guard let url = URL(string: thumbnailUrl!) else { return UICollectionViewCell() }
        
        networkManager.request(httpMethod: .get, url: url, body: nil, nil) { result in
            switch result {
            case .success(let data):
                guard let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    cell.update(openMarketItemArray?[indexPath.item])
                    cell.updateImage(image)
                }
            case .failure(let error):
                print(error)
            }
        }
        return cell
    }
    
    
    func setupCollectionViewLayOut() {
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.minimumLineSpacing = 8
        flowLayout.minimumInteritemSpacing = 8
        flowLayout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        let halfWidth = view.bounds.width / 2.2
        let halfHeight = view.bounds.height / 2
        flowLayout.itemSize = CGSize(width: halfWidth , height: halfHeight - 50)
        collectionView.collectionViewLayout = flowLayout
    }
}
