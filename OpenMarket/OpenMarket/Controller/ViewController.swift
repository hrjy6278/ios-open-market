//
//  OpenMarket - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

class ViewController: UIViewController {
    var openMarketItems = [OpenMarketItems.Item]()
    let netWorkManager = NetworkManager(session: .shared)
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        setupCollectionViewLayOut()
        getOpenMarketList()
        navigationItem.title = "야아 마켓"
    }
    
    
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return openMarketItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? OpenMarketCollectionViewCell else {
            fatalError()
        }
        let item = openMarketItems[indexPath.item]
        
        let url = URL(string: item.thumbnails.first!)!
        
        netWorkManager.request(httpMethod: .get, url: url, body: nil, .json) { result in
            switch result {
            case .success(let data):
                let image = UIImage(data: data)
                 
                DispatchQueue.main.async {
                   
                    cell.configure(thumbnail: image,
                                   nameLabel: item.title,
                                   discountedPrice: item.discountedPrice,
                                   price: item.price,
                                   stockNumber: item.stock,
                                   currency: item.currency)
                }
            case .failure(let error):
                print(error)
            }
        }
        
        
        return cell
    }
}

extension ViewController {
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
    
    func getOpenMarketList() {
        guard let url = URL(string: String(describing: OpenMarketUrl.listLookUp) + String(1)) else { return }
        netWorkManager.request(httpMethod: .get, url: url, body: nil, .json) { result in
            switch result {
            case .success(let data):
                guard let jsonItem = try? ParsingManager.jsonDecode(data: data, type: OpenMarketItems.self) else {
                    print("에러")
                    return
                }
                DispatchQueue.main.async {
                    self.openMarketItems = jsonItem.items
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}



