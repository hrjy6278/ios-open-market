//
//  OpenMarket - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    let test1 = OpenMarketDataSource.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = test1
        let layout = Layout.generate(self.view)
        collectionView.collectionViewLayout = layout
        collectionView.reloadData()
        collectionView.delegate = self
    }
    private var isLoading = false
    private var page = 2
}

extension ViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if (offsetY > contentHeight - scrollView.frame.height * 2) && !isLoading {
            loadMoreData("\(page)")
            page += 1
        }
        
    }
    
    func loadMoreData(_ page: String) {
        if !self.isLoading {
            self.isLoading = true
            OpenMarketLoadData().requestOpenMarketMainPageData(page: page) { items in
                self.test1.openMarketItemList.append(items)
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.isLoading = false
            }
        }
    }
}
