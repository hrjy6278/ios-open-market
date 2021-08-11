//
//  OpenMarketTests.swift
//  OpenMarketTests
//
//  Created by KimJaeYoun on 2021/08/10.
//

import XCTest
@testable import OpenMarket

class OpenMarketTests: XCTestCase {
    func test_OpenMarketItems의_페이지가_1이다() {
        //given
        let assetData = NSDataAsset(name: "Items")!
        
        //when
        let decodedData = try! ParsingManager.parse(data: assetData.data, type: OpenMarketItems.self)
        
        //then
        XCTAssertEqual(decodedData.page, 1)
    }
    
    func test_OpenMarketItems의_items배열의첫번째인덱스의id가_1이다() {
        //given
        let assetData = NSDataAsset(name: "Items")!
        
        //when
        let decodedData = try! ParsingManager.parse(data: assetData.data, type: OpenMarketItems.self)
        
        //then
        XCTAssertEqual(decodedData.items.first?.id, 1)
    }
    
    func test_Item에셋파일을_OpenMarketItems타입으로파싱했을때_id가_1이다() {
        //given
        let assetData = NSDataAsset(name: "Item")!
        
        //when
        let decodedData = try! ParsingManager.parse(data: assetData.data, type: OpenMarketItems.Item.self)
        
        //then
        XCTAssertEqual(decodedData.id, 1)
    }
    
    func test_Item에셋파일을_파싱하면_descriptios이_정상적으로_나온다() {
        let assetData = NSDataAsset(name: "Item")!
        
        let decodeData = try! ParsingManager.parse(data: assetData.data, type: OpenMarketItems.Item.self)
        
        XCTAssertEqual(decodeData.descriptions, "Apple M1 칩은 13형 MacBook Pro에 믿을 수 없을 만큼의 속도와 파워를 선사합니다.\n최대 2.8배 향상된 CPU 성능, 최대 5배 빨라진 그래픽 속도, 최대 11배 빨라진 머신 러닝 성능을 구현하는 최첨단 Apple 제작 Neural Engine, 여기에 무려 20시간 지속되는 Mac 사상 가장 오래가는 배터리까지.\n외장은 Apple의 가장 사랑받는 프로용 노트북 그대로, 하지만 그 능력은 한 차원 더 높아졌습니다.")
    }
    
    func test_Item에셋파일을_OpenMarketItems타입으로파싱했을때_실패한다() {
        //given
        let assetData = NSDataAsset(name: "Items")!
        
        //when
        do {
            _ = try ParsingManager.parse(data: assetData.data, type: OpenMarketItems.self)
        } catch let error as ParsingError {
            //then
            XCTAssertEqual(error, .decodingError)
        } catch {
        }
    }
}
