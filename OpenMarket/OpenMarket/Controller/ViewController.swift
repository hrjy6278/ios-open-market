//
//  OpenMarket - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

class ViewController: UIViewController {
    var openMarketItems = [OpenMarketItems.Item]()
    let netWorkManager = NetworkManager(session: .shared)
    let imageCache = ImageCache()
    var marketPage = 1
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        setupCollectionViewLayOut()
        getOpenMarketList(page: marketPage)
        navigationItem.title = "야아 마켓"
    }
    
    
}

extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return openMarketItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? OpenMarketCollectionViewCell else {
            fatalError()
        }
        let item = openMarketItems[indexPath.item]
        
        let url = item.thumbnails.first!
        var thumbnail: UIImage?
        getImage(for: url, id: item.id) { image in
            thumbnail = image
            DispatchQueue.main.async {
                
                cell.configure(thumbnail: thumbnail, nameLabel: item.title, discountedPrice: item.discountedPrice, price: item.price, stockNumber: item.stock, currency: item.currency)
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
    
    func getOpenMarketList(page: Int) {
        guard let url = URL(string: String(describing: OpenMarketUrl.listLookUp) + String(page)) else { return }
        netWorkManager.request(httpMethod: .get,
                               url: url,
                               body: nil,
                               .json) { [weak self] result in
            switch result {
            case .success(let data):
                guard let jsonItem = try? ParsingManager.jsonDecode(data: data, type: OpenMarketItems.self) else {
                    print("에러")
                    return
                }
                DispatchQueue.main.async {
                    self?.openMarketItems = jsonItem.items
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getImage(for url: String,
                  id: Int,
                  completion: @escaping (UIImage) -> ()) {
        
        if let image = imageCache.image(forkey: id) {
            completion(image)
            return
        }
        
        guard let url = URL(string: url) else { return }
        netWorkManager.request(httpMethod: .get, url: url, body: nil, .json) { result in
            switch result {
            case .success(let data):
                guard let image = UIImage(data: data) else { return }
                self.imageCache.add(image, forkey: id)
                completion(image)
            case .failure(let error):
                print(error)
            }
        }
    }
}

//페이지를 더 불러오는 부분
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print(indexPath.section)
//        if indexPath.row == collectionView.numberOfItems(inSection: indexPath.section) - 1 {
//            marketPage += 1
//            getOpenMarketList(page: marketPage)
//            collectionView.reloadData()
//            //DispatchQueue.main.async(execute: collectionView.reloadData)
//        }
    }
}
