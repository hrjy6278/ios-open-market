//
//  OpenMarket - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

class ViewController: UIViewController {
    var openMarketItems = [OpenMarketItems.Item]()
    var images = [UIImage]()
    let netWorkManager = NetworkManager(session: .shared)
    let imageCache = ImageCache()
    var marketPage = 1
    let activityView = UIActivityIndicatorView()
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        setupCollectionViewLayOut()
        getOpenMarketList(page: marketPage)
        navigationItem.title = "야아 마켓"
        setupIndicatorView()
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
        cell.layer.borderWidth = 2.0
        cell.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        cell.layer.cornerRadius = 5.0
        let item = openMarketItems[indexPath.item]
        let url = item.thumbnails.first
        var thumbnail: UIImage?

        getImage(for: url, id: item.id) { image in
            thumbnail = image
            DispatchQueue.main.async {
                cell.configure(thumbnail: thumbnail,
                               nameLabel: item.title,
                               discountedPrice: item.discountedPrice,
                               price: item.price,
                               stockNumber: item.stock,
                               currency: item.currency)
                self.activityView.stopAnimating()
            }
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let hearderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "openMarketHeader", for: indexPath) as! OpenMarketHeaderCollectionView
        let view = UISegmentedControl()
        hearderView.addSubview(view)
        
        return hearderView
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
    
    func getImage(for url: String?,
                  id: Int,
                  completion: @escaping (UIImage) -> ()) {
        guard let urlText = url else { return }
        
        if let image = imageCache.image(forkey: id) {
            completion(image)
            return
        }
        
        guard let url = URL(string: urlText) else { return }
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

extension ViewController {
    func setupIndicatorView() {
        activityView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityView.center = view.center
        activityView.style = .large
        activityView.color = .black
        activityView.startAnimating()
        view.addSubview(activityView)
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
