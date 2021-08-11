//
//  OpenMarket - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }


}


extension ViewController {
     func parseOpenMarketList() {
        URLSessionManager.dataTask(url: .openMarket) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    guard let data = try? ParsingManager.parse(data: data, type: OpenMarketItems.self) else {
                        //에러메시지 ㅊ풀력
                    }
                   //뿌려주던가 뷰에...
                case .failure(let error):
                    print(error)
                    //얼러트에 표시한다 에러내용
                }
            }
        }
    }
}
