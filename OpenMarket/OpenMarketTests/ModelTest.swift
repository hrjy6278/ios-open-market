//
//  test.swift
//  OpenMarketTests
//
//  Created by 최정민 on 2021/05/11.
//

import XCTest

@testable import OpenMarket
class ModelTest: XCTestCase {
    
    func test_ItemsOfPageReponse() throws {
        // given
        // 해당 테스트를 검증하기 위해 필요한 상황을 설정
        let jsonData = NSDataAsset(name: FileName.ItemsOfPageResponseJSON)!
        // when
        // 로직 실행
        let decodedData = try JSONDecoder().decode(ItemsOfPageReponse.self, from: jsonData.data)
        let items = [ItemsOfPageReponse.Item(id: 1,
                          title: "MacBook Pro",
                          price: 1690,
                          currency: "USD",
                          stock: 0,
                          discountedPrice: 100,
                          thumbnails: [
                            "https://camp-open-market.s3.ap-northeast-2.amazonaws.com/thumbnails/1-1.png",
                            "https://camp-open-market.s3.ap-northeast-2.amazonaws.com/thumbnails/1-2.png"
                          ],
                          registrationDate: 1611523563.7237701)]
        let itemsOfPageReponse = ItemsOfPageReponse(page: 1, items: items)
        // then
        // 결과 검증
        XCTAssertEqual(decodedData, itemsOfPageReponse)
    }

    func test_InformationOfItemResponse() throws {
        // given
        // 해당 테스트를 검증하기 위해 필요한 상황을 설정
        let jsonData = NSDataAsset(name: FileName.InformationOfItemResponseJSON)!
        // when
        // 로직 실행
        let decodedData = try JSONDecoder().decode(InformationOfItemResponse.self, from: jsonData.data)
        let informationOfItemResponse = InformationOfItemResponse(
            id: 1,
            title: "MacBook Pro",
            descriptions: "Apple M1 칩은 13형 MacBook Pro에 믿을 수 없을 만큼의 속도와 파워를 선사합니다.",
            price: 1690000,
            currency: "KRW",
            stock: 1000000000000,
            discountedPrice: 1,
            thumbnails: [
                "https://camp-open-market.s3.ap-northeast-2.amazonaws.com/thumbnails/1-1.png",
                "https://camp-open-market.s3.ap-northeast-2.amazonaws.com/thumbnails/1-2.png"
            ],
            images: [
                "https://camp-open-market.s3.ap-northeast-2.amazonaws.com/images/1-1.png",
                "https://camp-open-market.s3.ap-northeast-2.amazonaws.com/images/1-2.png"
            ],
            registrationDate: 1611523563.719116)
        // then
        // 결과 검증
        XCTAssertEqual(decodedData, informationOfItemResponse)
    }

    
    func test_ItemEditRequest() throws {
        // given
        // 해당 테스트를 검증하기 위해 필요한 상황을 설정
        let jsonData = NSDataAsset(name: FileName.ItemEditRequestJSON)!
        // when
        // 로직 실행
        let decodedData = try JSONDecoder().decode(Request.self, from: jsonData.data)
        let itemEditRequest = try Request(path: Path.Item.id,
                            httpMethod: HTTPMethod.PATCH,
                            title: "MacBook Pro",
                            descriptions: "Apple M1 칩은 13형 MacBook Pro에 믿을 수 없을 만큼의 속도와 파워를 선사합니다.최대 2.8배 향상된 CPU 성능, 최대 5배 빨라진 그래픽 속도, 최대 11배 빨라진 머신 러닝 성능을 구현하는 최첨단 Apple 제작 Neural Engine, 여기에 무려 20시간 지속되는 Mac 사상 가장 오래가는 배터리까지.외장은 Apple의 가장 사랑받는 프로용 노트북 그대로, 하지만 그 능력은 한 차원 더 높아졌습니다.",
                            price: 1690000,
                            currency: "KRW",
                            stock: 1000000000000,
                            discountedPrice: nil,
                            images:[
                                "https://camp-open-market.s3.ap-northeast-2.amazonaws.com/images/1-1.png",
                                "https://camp-open-market.s3.ap-northeast-2.amazonaws.com/images/1-2.png"
                            ],
                            password: "password")
        // then
        // 결과 검증
        XCTAssertEqual(decodedData, itemEditRequest)
    }
    
    func test_ItemRegisterRequest() throws {
        // given
        // 해당 테스트를 검증하기 위해 필요한 상황을 설정
        let jsonData = NSDataAsset(name: FileName.ItemRegisterRequestJSON)!
        // when
        // 로직 실행
        let decodedData = try JSONDecoder().decode(Request.self, from: jsonData.data)
        let itemRegisterRequest = try Request(path: Path.item, httpMethod: HTTPMethod.POST, title: "MacBook Pro", descriptions: "Apple M1 칩은 13형 MacBook Pro에 믿을 수 없을 만큼의 속도와 파워를 선사합니다.최대 2.8배 향상된 CPU 성능, 최대 5배 빨라진 그래픽 속도, 최대 11배 빨라진 머신 러닝 성능을 구현하는 최첨단 Apple 제작 Neural Engine, 여기에 무려 20시간 지속되는 Mac 사상 가장 오래가는 배터리까지.외장은 Apple의 가장 사랑받는 프로용 노트북 그대로, 하지만 그 능력은 한 차원 더 높아졌습니다.", price: 1690000, currency: "KRW", stock: 1000000000000, discountedPrice: 1, images: [
            "https://camp-open-market.s3.ap-northeast-2.amazonaws.com/thumbnails/1-1.png",
            "https://camp-open-market.s3.ap-northeast-2.amazonaws.com/thumbnails/1-2.png"
        ], password: "password")
        // then
        // 결과 검증
        XCTAssertEqual(decodedData, itemRegisterRequest)
    }

    func test_ItemDeleteRequest() throws {
        // given
        // 해당 테스트를 검증하기 위해 필요한 상황을 설정
        let jsonData = NSDataAsset(name: FileName.ItemDeleteRequestJSON)!
        // when
        // 로직 실행
        let decodedData = try JSONDecoder().decode(Request.self, from: jsonData.data)
        let itemDeleteRequest = try Request(path: Path.Item.id, httpMethod: HTTPMethod.DELETE, title: nil, descriptions: nil, price: nil, currency: nil, stock: nil, discountedPrice: nil, images: nil, password: "password")
        // then
        // 결과 검증
        XCTAssertEqual(decodedData, itemDeleteRequest)
    }
}