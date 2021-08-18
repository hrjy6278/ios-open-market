//
//  OpenMarket - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

class MainViewController: UIViewController {
    private var toggle: Bool = false
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func horizontalView(_ sender: Any) {
        // 수평,수직 로직
        //        if toggle == false {
        //        self.collectionView.collectionViewLayout = Layout.setupCollectionViewLayOut(view, collectionView, true)
        //            toggle = true
        //        } else {
        //            self.collectionView.collectionViewLayout = Layout.setupCollectionViewLayOut(view, collectionView, false)
        //            toggle = false
        //        }
        
        if #available(iOS 14.0, *) {
            if toggle == false {
            let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            let layout = UICollectionViewCompositionalLayout.list(using: configuration)
            collectionView.collectionViewLayout = layout
            toggle = true
            } else {
                toggle = false
                collectionView.collectionViewLayout = Layout.setupCollectionViewLayOut(view, collectionView, true)

            }
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    //    var openMarketItemList: OpenMarketItems?
    var openMarketItemList = [OpenMarketItems]()
    

    private func insertPageData(_ pageNum: ClosedRange<Int>) {
        
        for i in pageNum {
            test(i) {
                data in
                DispatchQueue.main.async {
                    //                self.openMarketItemList = data
                    self.openMarketItemList.append(data)
                    self.collectionView.reloadData()
                    // discard the dataSource and delegate data and requery as necessary
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        insertPageData(1...2)
        Layout.setupCollectionViewLayOut(view, collectionView, false)

    }
}

extension MainViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return openMarketItemList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        openMarketItemList[section].items.count
        //        openMarketItemList?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as? ItemCell else { return UICollectionViewCell()}
        
        let openMarketItemArray = openMarketItemList[indexPath.section].items
        let networkManager = NetworkManager(session: URLSession.shared)
        
        let thumbnailUrl = openMarketItemArray[indexPath.item].thumbnails.first
        
        guard let url = URL(string: thumbnailUrl!) else { return UICollectionViewCell() }
        
        networkManager.request(httpMethod: .get, url: url, body: nil, nil) { result in
            switch result {
            case .success(let data):
                guard let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    cell.update(self.openMarketItemList[indexPath.section].items[indexPath.item])
                    cell.updateImage(image)
                }
            case .failure(let error):
                print(error)
            }
        }
        cell.contentView.layer.borderWidth = 1
        cell.contentView.layer.cornerRadius = 8
        cell.contentView.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        return cell
    }
    
}

extension MainViewController {
    
    func test(_ page: Int, _ completionHandler: @escaping (OpenMarketItems) -> ()) {
        let urlSession = URLSession.shared
        let networkManager = NetworkManager(session: urlSession)
        let url = URL(string: "https://camp-open-market-2.herokuapp.com/items/\(page)")!
        
        networkManager.request(httpMethod: .get, url: url, body: nil, .json) { data in
            switch data {
            case .failure(let error):
                print(error)
            case .success(let result):
                guard let jsonData = try? ParsingManager.jsonDecode(data: result, type: OpenMarketItems.self) else { return }
                completionHandler(jsonData)
            }
        }
    }
}
