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

        print(collectionView)
        // 리턴 되기전
        cell.configure(item: self.openMarketItemList[indexPath.section].items[indexPath.item], indexPath, collectionView) { cv in
//            print("-----------")
//            print(cv)
//            print(cv.indexPath(for: cell))
//            print("\(cell)셀")
//            print(indexPath, cv.indexPath(for: cell))
//            print("-----------")
            
            cell.downloadImage(reqeustURL: (self.openMarketItemList[indexPath.section].items[indexPath.row].thumbnails.first)!, indexPath, cv)
        }
        
        return cell
    }
}
//\cv in
//let cv = collectionView
//if indexPath.row == cv.indexPath(for: cell)?.row {
//    cell.downloadImage(reqeustURL: (self.openMarketItemList[indexPath.section].items[indexPath.row].thumbnails.first)!)
//            print("-----------")
//            print(cv)
//            print(cv.indexPath(for: cell))
//            print("\(cell) 셀")
//            print(indexPath, cv.indexPath(for: cell))
//            print("-----------")

//            print(indexPath ,cv.indexPath(for: self))
// 재사용 cell -> 100개를 표현한다고 했을 때 모든 인덱스를 가지고 있지 않다.
// 고정값이 될 수 없다.
// cell의 실제 인덱스패스에 위치시키는 것은 무엇인가 :
// 인덱스 패스가 초기화 되는지 확인해보기
// 셀이 화면 밖에서 재사용되기 때문에 초기화 되지 않아서 일 수 있다!!!!
