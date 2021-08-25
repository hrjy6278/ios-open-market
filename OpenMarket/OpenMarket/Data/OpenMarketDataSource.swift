//
//  OpenMarketDataSource.swift
//  OpenMarket
//
//  Created by KimJaeYoun on 2021/08/20.
//

import UIKit

class OpenMarketDataSource: NSObject, UICollectionViewDataSource {
    override init() {
        super.init()
        let loadData = OpenMarketLoadData()
        loadData.requestOpenMarketMainPageData(page: "1") { testData in
            self.openMarketItemList = [testData]
        }
        
        while self.openMarketItemList.count == 0 {
            continue
        }
    }
    
    var openMarketItemList = [OpenMarketItems]()
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        openMarketItemList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        openMarketItemList[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "openMarketCell", for: indexPath) as? OpenMarketItemCell else {
            return UICollectionViewCell()
        }
        
        // configure호출부분부터 downloadImage부분을 비동기처리 해 보았는데 collectionView.indexPath(for:cell)의 값이 nil이 나왔습니다.(ㅜㅜ)
        //DispatchQueue.global().async {
            cell.configure(item: self.openMarketItemList[indexPath.section].items[indexPath.item], indexPath, collectionView) { cv, ip in
                
                cell.downloadImage(reqeustURL: (self.openMarketItemList[indexPath.section].items[indexPath.row].thumbnails.first)!, ip, cv) { img in
                }
            }
        //}
        
        return cell
    }
}
