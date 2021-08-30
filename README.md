# 🛒 오픈마켓 프로젝트
- **팀 구성원 : Tacocat(Ldoy), Jiss()**
- **프로젝트 기간 : 2021.08.09 ~ 08.20** 

- **그라운드 룰즈** 
    <details>
    <summary>GroundRules</summary>
    <div markdown="1">    
        
    - 커밋단위 : 메소드, 타입별로 커밋
    - 커밋메세지 : 카르마스타일
    - 브랜치 : main > 3-jiss > STEPn 형태로 진행 
    - 팀 내부 규칙
        - 프로젝트의 진행 보다는 `왜` 에 초점을 맞추기 
        - 한숨금지
    </div>
    </details>

- **UML**
    <details>
    <summary>UML</summary>
    <div markdown="1">       
        <img src="https://i.imgur.com/h7WHBFc.png" width="1000" height="700">

    </div>
    </details>

## 🛒목차
[I. 앱 동작](#i-앱-동작)<br>
[II. 요구 기능](#ii-요구-기능)<br>
[III. 이를 위한 설계](#iii-이를-위한-설계)<br>
[IV. 💫Trouble Shooting💫](#iv-trouble-shooting)<br>
    + [1. LazyLoading Probelm](#1-lazyloading-probelm)<br>
    + [2. HTTP Request POST시에 HTTP Message 503Error 가 Response 되는 에러!](#2-http-request-post시에-http-message-503error-가-response-되는-에러)<br>
    + [3. DataSource 와 Delegate가 분리된 상황에서 Model DATA를 여러군데에서 참조 할 수 있는 방법](#3-datasource-와-delegate가-분리된-상황에서-model-data를-여러군데에서-참조-할-수-있는-방법)<br>
    + [4. Delegate타입을 따로 만들고 ViewController에서 할당 하였는데 반영되지 않는 문제](#4-delegate타입을-따로-만들고-viewcontroller에서-할당-하였는데-반영되지-않는-문제)<br>
    + [5. CodingKey 프로토콜을 채택했음에도 채택하지 않았다는 경고 메세지가 나온 문제](#5-codingkey-프로토콜을-채택했음에도-채택하지-않았다는-경고-메세지가-나온-문제)<br>
    + [6. cell의 textLabel에 데이터 및 속성이 제대로 반영되지 않는 문제](#6-cell의-textlabel에-데이터-및-속성이-제대로-반영되지-않는-문제)<br>
[V. 아쉽거나 해결하지 못한 부분](#v-아쉽거나-해결하지-못한-부분)<br>
[VI. 관련 학습 내용](#vi-관련-학습-내용)<br>

<br><br> 




## I. 앱 동작
![Simulator Screen Recording - iPhone 12 - 2021-08-27 at 15 04 23](https://user-images.githubusercontent.com/71247008/131079919-cfbaccc2-beea-49cf-a79a-8f41b0d0f38c.gif)

<br><br>
## II. 요구 기능
#### 1.  **서버 API를 통해 상품목록에 대한 정보 요청**
#### 2.  **받아온 정보를 컬렉션뷰로 구현**
#### 3.  **Scrolling, Paging 구현 및 사용자 경험향상**
#### 4. **네트워크 무관 테스트**
<br><br>

## III. 이를 위한 설계

### 1. MVC 디자인 패턴

![](https://i.imgur.com/FkSumjC.png)
  
<details>
<summary> 위와 같이 설계한 이유 </summary>
<div markdown="1">       


1) **MVC 디자인 패턴** 사용, 더불어  `ViewController`에 컬렉션뷰의 `delegate`, `dataSource`, `layout` 등의 역할을 부여하지 않고 `ViewController`의 역할을 명확히 하기 위해 해당 역할을 하는 타입을 따로 구현하는 방향으로 설계하였다. 


- **MVC를 사용한 이유** 
    - 네트워크 통신 로직과 UI로직(CollectionView)을 분리하여 유지보수를 독립적으로 수행할 수 있도록 하기 위해서
    <br>
- **ViewController의 역할을 나눈 이유**
    - Controller의 역할은 Model과 View사이에서 프로그램의 작동순서나 방식을 제어하는 역할이라고 생각했다. 따라서 Controller내부에서 데이터를 받아오는 요청(DataSource), 레이아웃 객체를 만드는 메소드를 가지는 것은 Controller의 역할이 아니라고 판단하였다. 
    - 하나의 Controller가 여러개의 역할을 가지는 것은 SOLID원칙 중 단일책임원칙을 위반하는 것이기 때문이다.

</div>
</details>

<br>

### 2. 네트워크 통신 타입, NetworkManager
<details>
<summary> NetworkManager 설계와 이유 </summary>
<div markdown="1">       

- [ HTTP 학습내용 요약 ](####1.-HTTP)
 - 서버API분석 결과 GET, POST, PUSH, PUT, DELETE 의 메소드에 따라 Response Message의 내용이 달라짐을 알 수 있었다. 
 - 각각의 HTTPMethod 마다 네트워크 요청을 진행하는 메소드를 만들지 않고 하나의 타입(혹은 메소드)로 HTTP Request를 할 수 있도록 초점을 맞추고 아래와 같이 구현하였다. 
     ```swift 
    //MARK:-NetworkManager
    struct NetworkManager {
        :

        //MARK: Method
            static func request(httpMethod: HTTPMethod, url: URL, body: Data?, _ contentType: ContentType, _ completionHandler: @escaping (Result<Data, NetworkError>) -> ()) {
            let request = createRequest(httpMethod: httpMethod, url: url, body: body, contentType)

            session.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    completionHandler(.failure(.requestError))
                    return
                }

                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    completionHandler(.failure(.responseError))
                    return
                }

                if let data = data {
                    completionHandler(.success(data))
                }
            }.resume()
        }
    }
    
</div>
</details>
<br>

### 3. 컬렉션 뷰의 설계 
[컬렉션뷰 학습내용 요약](####-4.-uicollectionview)
<details>
<summary> CollectionView 설계코드와 그 이유 </summary>
<div markdown="1">       


- UICollectionViewDataSource 프로토콜을 채택한 타입을 새롭게 만들어 구성하였음.
    - **NSObject를 채택한 이유**
    `UICollectionViewDataSource`가 `NSObjectProtocol`을 상속받고 있음. 이에따라 `UICollectionViewDataSource`를 준수하려면 `NSObjectProtocol`의 요구사항을 준수해야 됨.
`NSObject` 클래스는 `NSObjectProtocol` 을 채택하고 준수한 타입임. 이에따라 `NSObject`를 상속받아 `UICollectionViewDataSource`의 요구사항을 준수 할 수 있게됨.
        ```swift
        class OpenMarketDataSource: NSObject, 
                                    UICollectionViewDataSource {

        }
        ```
- cellForItemAt 메서드에서 셀을 구성하는 부분에, 이미지를 다운로드하거나, 캐시저장소에있는 이미지를 가져오도록 구성함. 해당 작업은 네트워크 구현이 필수적이라, 완료시점을 클로저로 넘겨주어 네트워크를 처리함. UI를 변경하는 cell.configure 메서드가 있기 때문에 main Thread에서 실행 될 수 있도록 함.

- 이미지를 다운로드를 했을 경우 Notication으로 완료되었다는 시점을 알려주게 된다. 이는 계속 Notication을 Post할 여지가 있으므로 한번만 POST 할수 있도록 분기문을 작성함.
    ```swift
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let taskIdentifier = imageLoader.downloadImage(reqeustURL: urlString, imageCachingKey: idNumber) { downloadImage in
        DispatchQueue.main.async {
            if self.isImageDownload == false {
                NotificationCenter.default.post(name: .imageDidDownload, object: nil)
                self.isImageDownload = true
            }    

            cell.configure(item: currentItem, thumnail: downloadImage)
            cell.isHidden = false
            }
        }
    }
    
    ```

- CollectionView Layout은 Delegate를 사용한게 아닌 UICollectionViewFlowLayout 클래스 인스턴스를 만들어 레이아웃 설정을 해준 뒤, CollectionView에 적용시켜주었다.
    ```swift
        struct Layout {
            static func generate(_ view: UIView) -> UICollectionViewFlowLayout {
            let layout = UICollectionViewFlowLayout()
            let width = view.bounds.width / 2.2
            let height = view.bounds.height / 3.6

            //셀의 사이즈를 설정하는 부분
            layout.itemSize = CGSize(width: width, height: height)

            //셀과 셀의 최소 간격을 설정하는 부분
            layout.minimumInteritemSpacing = 10

            //라인(줄)과의 최소 간격
            layout.minimumLineSpacing = 10

            //셀의 테두리의 여백을 설정하는 부분
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

            return layout
            }
        }
    ```

- 스택뷰를 최대한 활용하여 추후에 유지보수에도 강력하고, 쉽게 대처할 수 있도록 설계함.
    <img src="https://user-images.githubusercontent.com/71247008/131338664-48d21b64-c228-4111-add0-2ebd4726a21e.png" width="400" height="200">

</div>
</details>

<br>

### 4. Scrolling, Paging 구현

#### 4-1. Scrolling
<details>
<summary> Scrolling 기능 설계와 그 이유</summary>
<div markdown="1">  
    
- **`singleton`** 디자인 패턴을 이용해 구현한 **`ImageCacher`**
    ``` swift
    class ImageCacher: NSCache<NSNumber, UIImage> {
        static let shared = ImageCacher()

        private override init() {
            super.init()
            self.countLimit = 100 
            //캐쉬에 저장될 value의 저장 개수 해당 숫자를 넘지 못함.
            }

        func save(_ image: UIImage, forkey: Int) {
            setObject(image, forKey: NSNumber(value: forkey))
        }

        func pullImage(forkey: Int) -> UIImage? {
            guard let image = object(forKey: NSNumber(value: forkey)) else {
                return nil
            }
            return image
        }
    } 
    ```
  
    - 네트워크 요청을 통해 컬렉션뷰의 셀에 반영하는 이미지를 NSCache 객체를 이용해 내부에 저장하였다. 
        - **이유** : 캐쉬 방법을 이용하면 이미지를 가져오는 속도가 서버에 요청하는 것보다 빠르기 때문에 캐쉬를 이용해서 스크롤 할 때 사용자 경험의 만족도가 높아지게 하기 위해서. 
    - **`singleton`으로 구현한 이유** : 자주사용되는 이미지들을 `NSCache`를 사용하여 구현함. 추후에 다른 `ViewController` 가 사용 할 수 있음을 고려하여, singleton 으로 구현함.
    
- **NSCache 와  URLCache 중 NSCache를 선택한 이유**
     - 스위프트에서 이미지를 caching하는 방법에는 대표적으로 `URLCache`, `NSCache` 두 가지가 있다. 당시에는 in-memory방식으로 caching하려고 해서 URLCache를 선택하지 않았지만 지금 생각해보니 코드의 확장성을 위해서 URLCache를 사용해도 좋았을 거란 생각이든다. 
    - **이유** : `URLCache`는 캐슁할 메모리용량 설정할 수 있고 in-memory, on-disk방식을 중 하나를 선택할 수 있기 때문이다. 또한 `NSCache`는 메모리가 모자랄 때 저장된 데이터 중 사라지는 데이터에 대한 규칙이 없기 때문에 cache된 객체가 저장되어있을 거란 보장이 없다. 즉 스크롤링에 대한 성능 및 사용자 경험 향상을 보장 하지 않는다. 
        <details>
        <summary>참고한 인용글</summary>
            <div markdown="1">   
                > As NSCache is an in-memory cache, it will use system's memory and will allocate a proportional size to the size of images, or data in generic term. Until other applications need memory and system forces this app to minimize its memory footprint by removing some of its cached objects. Though, NSCache doesn't guarantee that the eviction process will be in orderly manner. Moreover, the cached objects won't be there in next run. The main advantages of NSCache are performance and auto-purging feature for objects with transient data that are expensive to create.For any network data management we should use URLCache rather than NSCache for caching any data. Because, URLCache is both in-memory and on-disk cache, and it doesn't allocate a chunk of memory for it's data. You can define it's in-memory and on-disk size, which is more flexible. URLCache will persist the cached data until the system runs low on disk space.
                [링크](https://medium.com/@master13sust/to-nscache-or-not-to-nscache-what-is-the-urlcache-35a0c3b02598)
            </div>
            </details>
    
</div>
</details>

#### 4-2. Paging 
<details>
<summary> Paging 기능 설계와 그 이유</summary>
<div markdown="1">  
    
- **`OpenMarketCollectionViewDelegate` 에서 scrollViewDidScroll 메소드를 사용하여 paging 구현**
    - **이유** : 사실 내부 코드에 대해 완벽하게 이해하고 있는것이 아니라서 코드를 작성할지 말지 많이 고민했는데 우선 기능을 구현해 보자는 마음으로 추가
    - 리드미를 작성하면서 공부한 scrollViewDIdScroll내부의 코드에 관하여 
        ```swift
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            // 화면에 보이는 영역의 가장 왼쪽 윗 상단의 CGPoint값 : contentOffSet 
            let offsetY = scrollView.contentOffset.y
            
            // 화면에 보이는 뷰 너머 총 Content 크기 : contentSize
            let contentHeight = scrollView.contentSize.height
            
            // 화면에 보이는 왼쪽상단 시작점의 y좌표가컨텐츠사이즈에서 화면에 보이는 높이의 1/2를 뺀
            // 것보다 크다면 다음 페이지의 정보를 가져오는 loadMoreData호출 
            if (offsetY > contentHeight - scrollView.frame.height * 2) && !isLoading {
            loadMoreData("\(self.rquestPage)", scrollView as? UICollectionView)
            rquestPage += 1
            }
        }
    - 위의 코드 중 if 문을 
        `offsetY + scrollView.frame.height * 2 > contentHeight`
        라고도 쓸 수 있다. **즉 현재 위치에서 screen Visable높이(frame.height)길이2배만큼 더 갔더니 컨텐츠의 총 높이보다 큰 경우엔 다음 페이지에 대해 네트워크 요청을 진행하라고 이해할 수 있다.**
    
    
        | contentOffset | ScrollView의 구성 |
        | -------- | -------- |
        | ![](https://i.imgur.com/3hYQOf6.png) <br>[참고링크](https://cdn-ak.f.st-hatena.com/images/fotolife/h/haptaro/20170503/20170503221005.png)| ![](https://i.imgur.com/RLxw4rq.png) [참고링크](https://www.google.com/search?q=scrollview+contentsize+swift&tbm=isch&ved=2ahUKEwjzkqu-n9byAhXNw4sBHQzFBY8Q2-cCegQIABAA&oq=scrollview+contentsize+swift&gs_lcp=CgNpbWcQAzIECAAQGDIECAAQGDoFCAAQgAQ6BggAEAgQHjoGCAAQChAYUOPWLVjh7y1g3_AtaAlwAHgDgAGCAYgBvRCSAQQzLjE5mAEAoAEBqgELZ3dzLXdpei1pbWfAAQE&sclient=img&ei=Vn8rYfOPM82Hr7wPjIqX-Ag&bih=975&biw=1200&client=safari#imgrc=50BAJR4GZyLfQM&imgdii=gVsTmPIBXPI9MM)|

    - paging을 구현하는 방법을 조사해보았다. 위와 같이 `ScrollContentOffset`을 사용하거나 `collectionView(_:willDisplay:forItemAt:)` 메소드를 사용 해서 특정 시점에  데이터 요청, [UICollectionViewDataSourcePrefetching](https://developer.apple.com/documentation/uikit/uicollectionviewdatasourceprefetching/prefetching_collection_view_data) 프로토콜을 사용하는 방법 등이 있다. 
    - 현 프로젝트에서 사용한 첫 번째 방법은 컨텐츠의 특정 높이에서 데이터를 네트워크요청으로 가져오도록 하고 위에서 소개한 collectionView(_:willDisplay:forItemAt:) 메소드를 통한 방법은 indexPath가 기준이 되기 때문에 구현해야하는 상황에 따라 선택하면 될 것 같다. 
    
</div>
</details>

<br>

### 5. 네트워크 무관 테스트 
<details>
<summary> 프로젝트에서 구현한 테스트타입에 관하여 </summary>
<div markdown="1">  
 
- 서버가 구축되기 이전에 서버가 전송하는 JSON 데이터를 오류없이 Decoding하는 것을 테스트하기 위해 OpenMarketTests 클래스에서 UnitTest를 진행했다. 
- 디코딩한 데이터의 특정 페이지 혹은 특정 아이템의 속성을 추출하고 그 값이 예상 값과 맞는 메서드와 맞지 않는 메서드를 구현하였다. 
    ```swift
    //성공케이스 
    func test_OpenMarketItems의_페이지가_1이다() {
            //given
            let assetData = NSDataAsset(name: "Items")!

            //when
            let decodedData = try! ParsingManager
                            .jsonDecode(data: assetData.data, 
                                            type: OpenMarketItems.self)

            //then
            XCTAssertEqual(decodedData.page, 1)
        }

    //실패케이스 
    func test_Item에셋파일을_OpenMarketItems타입으로파싱했을때_실패한다() {
            //given
            let assetData = NSDataAsset(name: "Items")!

            //when
            do {
                    _ = try ParsingManager
                        .jsonDecode(data: assetData.data, 
                                    type: OpenMarketItems.self)
            } catch let error as ParsingError {
                //then
                XCTAssertEqual(error, .decodingError)
            } catch {
            }
        }
        
</div>
</details>
    <br>

### 6. 그 외 프로젝트 내부 코드와 이유

<details>
<summary>주요 코드</summary>
<div markdown="1">       

1. **`StrockText`, `DigitStyle` 이라는 프로토콜를 선언하고 extension으로 메소드를 구현**
    - **이유** : 첫 화면외에 `+` 버튼을 눌렀을 때 보여지는 상세 뷰, 상품등록 뷰에서도 해당 속성들을 사용할 경우가 생길 수 있기 때문에 프로토콜을 만들고 익스텐션으로 세부구현을 진행

4. **`OpenMarketDataSource` 타입을 보면 `init` 메소드 내부에서 `openMarketItemList` 의 element가 하나라도 생겨야 해당 메소드의 호출이 종료되도록 구현**
    - **이유** : `OpenMarketLoadData.requestOpenMarketMainPageData` 가 비동기적으로 데이터를 받아오고 이 때문에 init 이후에 cell에 반영할 데이터가 없는 상태로 시작되는 것을 막기 위해서
    - 지금 다시 생각해보니 이번에 새로 발표된 `async/await`를 사용 할 수있지 않았을까하는 생각이 든다. 

7. **`collectionView(_:cellForItemAt:)` 내부에서 첫 이미지가 다운로드 되면 `viewController`의 `activityIndicator` 애니메이션을 중지하도록 `NotificationCenter`를 구현**
    - **이유** : 뷰 컨트롤러간에 정보를 전달하는 방법에는 클로저, 뷰컨을 속성으로 가지기, notification, delegate, KVO 패턴의 사용 등이 있다. 이 중 첫 이미지가 다운로드 되었다는 정보 전달 방법으로 Notification을 사용했다. NotificationCenter를 이용하면 뷰컨트롤러 계층에서 멀리 떨어져 있는 것들끼리도 정보전달이 가능하기 때문이다. 다시 생각해보니 KVO패턴을 사용해서 정보전달하는 방법도 가능했을 것 같다. 

6. **`OpenMarketItemCell` 속성으로 `prepareForReuse` 메소드 호출 시 네트워크 요청을 취소할 코드를 담을 클로저를 구현**
    - **이유** : `collevtionView(_:cellForItemAt:)`메소드에서 cell을 재사용하는 코드가 구현되어있고 cell 재사용 직전 `prepareForReuse`가 호출되기 때문에 두 메소드 호출 간의 정보전달이 필요했다. 그래서 `Clouser` 타입의 변수를 선언

7. **`ParsingManager`에서 디코딩 방법으로 `JSONDecoder`타입을 사용**
    - 그 외의 디코딩 방법으로는 String(data:encoding), JSONSerialization을 쓰는 것이 있다. 
    - JSONDecoder, JSONEncoder를 사용한 이유는 JSON 데이터를 디코드하는 타입을 JSONSereialization보다 빠르고 간편하게 구현할 수 있기 때문이다. 

</div>
</details>

<br>

##### 7. 타입과 역할 분배 

<details>
<summary>주요타입과 역할 정리 </summary>
<div markdown="1">       

| class/struct           | 역할|
| ---------------------- |:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `OpenMarketDataSource` | UICollectionViewDataSource를 상속하며 Section과 Section에 해당하는 Item의 수, cell에 보여줄 item에 대한 정보를 가지고 있다|
| `ParsingManager`       | OpenMarket서버에 요청해서 가져온 JSON데이터를 decode 한다.|
| `NetworkManager`       | OpenMarket서버로 HTTPMethod에 기반하여 네트워크 요청을 한다|
| `HTTPBodyMaker`        | `NetworkManager`에게 전달해 줄 httpBody를 만든다|
| `OpenMarketItemCell`   | collectionView의 전체적인 view요소를 나타낸다.|
|`LayoutGenerator`|collectionView의 collectionViewLayout 속성에 할당하는 collectionView UICollectionViewFlowLayout 객체를 만든다. |
| `ViewController`       | `datasource`객체에서 네트워크 요청이 정상적으로 이루어지지 않으면 `Notification`을 받는 역할을 한다. 또한 `dataSource`객체에서 네트워크 요청이 시작되어 `openMarketListItem`에 첫 번째 요소가 생기는 순간 `Notification`을 받아 `activityIndicator`객체의 애니메이션이 멈추도록 한다.|



</div>
</details>

<br>


<br> 

## IV. Trouble Shooting

### 1. LazyLoading Probelm
- **상황** : 셀이 이미지 다운로드 작업을 비동기로 시작할때, 재사용되어 다른 위치에서 이미지를 보여주는 에러

- **첫 시도** : indexPath를 이용해 cell이 재사용 될 때 `collectionView(_:cellForItemAt)` 메소드가 실행된 `indexPath` 에서만 이미지를 반영하도록 함
    ```swift
    // 코드예시
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        :
        :    
        if indexPath.item == collectionView.indexPath(for: cell)?.item {
            cell.configure(item: self.openMarketItemList[indexPath.section].items[indexPath.item])
            }
        }
    ```
       
    - 결과 : 실패
        - 이유 : UICollectionView는 UITableView와는 다른게 스크린에 cell이 보이지 않아도 미리 `collectionView(_:cellForItemAt)` 호출해서 cell을 준비시킨다. 따라서 이 메소드 내부에 네트워크 요청을 통해 이미지를 가져오고 그 이미지를 cell에 반영하도록 구현했지만 막상 반영할 cell이 없기 때문에 cell에 제대로 이미지가 반영되지 않는다. 
- **해결한 방법** : `NSCache`를 이용한 이미지캐싱과 `prepareForReuse`메소드에 `collectionView(_:cellForItemAt)` 에서 cell 재사용시 네트워크 요청 취소하도록 `OpenMarketcel`의 closure 타입의 변수 추가하고 `ImageLoader`타입을 만들어서 cell재사용 시 네트워크 요청 취소하는 메서드 구현
    - **이유** : 재사용시 cell이 화면에 있지 않으면 해당 데이터는 메모리에 저장되지 않기 때문에 사용할 수 없다. 따라서 cell이 view에서 보이지 않더라도(사용되지 않더라도) 불러온 이미지 데이터를 보관하도록 NSCache객체에 이미지와 item의 id를 key-value 형태로 저장했다. 또한 스크롤을 빠르게 할 때 `collectionView(_:cellForItemAt)` 내부에서 이미지 로딩을 위한 네트워크요청메소드(ImageLoader의 downloadImage)의 호출과 cell이 재사용되어 다시 호출한 결과와 겹치지 않도록 하기 위하여 이와 같은 방향으로 구현하였다.  
    - [자세한 실험결과와 UITableView와의 비교정리 노션링크](https://www.notion.so/Lazy-Loding-Problem-in-CollectionView-d9a3b5b5f4394eec9c969d0fc49f62aa)


- **다른 해결방법** 
    - `isPrepatching` 속성 false 로 해서 cell 화면에 보일 때만 `collectionView(_:cellForItemAt)` 를 호출 


### 2. HTTP Request POST시에 HTTP Message 503Error 가 Response 되는 에러!


| 에러로그                                                             |
| -------------------------------------------------------------------- |
| <img src="https://i.imgur.com/DiN3Mwl.png" width="500" height="300"> |
| HTTP Body에 Multipart 형식인 DATA넣고 POST를 할 때 계속 503 Error    |

  
    
- **503 에러? 그건 서버에러 아냐?**
    - 라고 생각해서 Server를 제공하는 Heroku 홈페이지에 들어가서 error관련 문서를 확인 했는데 다음과 같은 내용이 있었다
        >Whenever your app experiences an error, Heroku will return a standard error page with the HTTP status code 503. To help you debug the underlying error, however, the platform will also add custom error information to your logs. Each type of error gets its own error code, with all HTTP errors starting with the letter H and all runtime errors starting with R. Logging errors start with L. https://devcenter.heroku.com/articles/error-codes
    - 즉 error를 겪었을 때 Client가 받는 response message의 status code는 503 이라는 것. 
  

- **오류의 원인**
    1) 서버API문서에서 요구했던 POST메소드 response Message의 key타입에 image Array라고 쓰여 있던 것을 Image라고 생각함. 
        - **해결** : key이름을 `images`가 아닌 `images[]`로 변경해서 request진행
    2) httpHeader와 body에서 사용하는 Boundary의 구분을 하지 않음 
        - Multipart-from 형식으로 네트워크 요청을 진행할 땐 HTTPHeader에 boundary로 쓸 문자열 추가하고 httpBody에선 boundary앞에 `--` 를 추가해 주어야한다. 하지만 header에 미리 추가해주는 것이라고 생각해서 header와 body의 boundary를 동일하게 입력했다.

    3) body에 옵셔널을 벗기지 않고 입력함
        - httpBody에 들어가는 내용을 print를 이용해 확인해보았는데 아래와 같이 입력되는 것을 확인했다. 즉 Optional() 자체도 encode되어 입력되는 상태였다. 
        ```swift
        for photo in image {
            body.append("--\(boundary + lineBreak)")
            body.append("Content-Disposition: form-data; name=\"\(photo?.key)\"; filename=\"\(photo?.filename)\"\(lineBreak)")
            body.append("Content-Type: \(photo!.mimeType +  lineBreak + lineBreak)")
            body.append(photo?.data ?? Data())
            body.append(lineBreak)
        }
        ```
        ![](https://i.imgur.com/5XYq373.png)
        - 해결 : 옵셔널 값을 벗겨주었다. 
<br>

### 3. DataSource 와 Delegate가 분리된 상황에서 Model DATA를 여러군데에서 참조 할 수 있는 방법
    
- 현재는 `View`에 보여질 데이터가 `DataSource`의 프로퍼티로 저장되어 있다. Delegate타입에도 해당 모델의 Data이 필요한 상황이 생겼다. 이에 우리는 Data 프로퍼티를 Static으로 선언하여서 타입프로퍼티로 만들어 다른곳에서 사용할 수 있도록 해결하였다. <img src="https://user-images.githubusercontent.com/71247008/131210377-b885482f-4186-4239-8e53-21a4d831959c.png" width="500" height="80">
    - 다만 이 방법은 지금 README를 작성하는 시간에 다시 코드를 보니 좋은 방법이 아닌 것 같다는 생각이 든다. 
        - 이유 : DataSource 타입 프로퍼티이기 때문에 DataSource가 교체되거나하는 상황에서 다시 DATA 모델은 어딘가에 생성해야 되기때문
    - 개선방향 : Data를 가지고 있는 타입을 따로 만드는 방법이 생각난다. 해당 타입은 **싱글턴**으로 구현하여 여러 곳에서 인스턴스를 접근 할 수 있도록 하는 방법이 좋을 것 같다.

<br>

### 4. Delegate타입을 따로 만들고 ViewController에서 할당 하였는데 반영되지 않는 문제 
- **상황** : `CollectionViewDelegate` 타입을 따로 만들고 `ViewController` 타입의 `viewDidLoad`메서드에서 다음과 같이 구현했는데 에러메세지가 생김
    ```swift
    viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = OpenMarketDelegate()
        :
    }
    ```
    - 에러메세지 : **`Instance will be immediately deallocated because property 'OpenMarketDelegate' is 'weak`**

- **이유** : `UICollectionView`의 `dataSource`, `delegate`는 **weak property**이기 때문에 viewDidLoad내부에서 인스턴스를 만드는 것이 아니라 `ViewController`의 property로 delegate로 사용할 인슨턴스를 만든 후 해당 속성을 `viewDidLoad`메서드 내부에서 컬렉션뷰의 `delegate`로 할당해야한다. 
- **해결** : 아래와 같이 리팩토링 진행
    ```swift
    class ViewController {
        let delegate = OpenMarketDelegate()
        :  
        viewDidLoad {
        super.viewDidLoad()
        collectionView.delegate = delegate
        }
        :
    } 
    ```
    


### 5. CodingKey 프로토콜을 채택했음에도 채택하지 않았다는 경고 메세지가 나온 문제 
<img src="https://i.imgur.com/N4h9PEY.jpg" width="500" height="300">

- **문제의 원인**
    - 가설1 : nested type으로 Decodable프로토콜 채택하는 경우 CodingKey 사용이 허용되지 않는다
    - 가설2 : CodingKey 프로토콜 채택하는 과정에서 우리가 모르는 것이 있다. 
- **실험**
    - 가설1을 위해 nested Type이 아닌 OpenMarketItems타입의 items 속성의 타입을 Item으로 바꾸고 Item타입을 OpenMarketItems 외부에서 구현했지만 동일한 문제가 나왔다. 

- **결론** : 해당 타입에 `Decodable`을 채택하면 프로토콜 기본 구현으로 `enum CodingKeys`가 자동으로 구현. 하지만 현재 상황은 `enum CodingKeys` 를 직접 구현하고 있기 때문에, `Decodable`을 채택한 타입의 프로퍼티들이 `enum CodingKeys`에 `case`에 전부 있어야 했다. 


### 6. cell의 textLabel에 데이터 및 속성이 제대로 반영되지 않는 문제
- 상황 : titleLabel은 색이 검정색이어야하는데 statusLabel의 textColor인 노란색으로 나타나거나 상품에 맞지 않는 이름을 가지는 등의 문제가 생김
- 이유 : cell 재사용 시 prepareForReuse 로 
- 해결 : prepareForReuse() 메소드에서 cell을 구성하던 요소들을 초기화 해주었다. 

<br><br>



## V. 아쉽거나 해결하지 못한 부분

<details>
<summary>6가지 아쉬움</summary>
<div markdown="1">   

1. **인디케이터가 중지하는 시점을 어디서 어떻게 보내줄 것인가?**

- 현재 인디케이터는 `ViewController`에 `View`로 소유되고 있다.
- 인디케이터의 중지시점에 인디케이터의 애니메이션을 중지하고, `View의 계층`에서 제거를 해줘야 하는데 중지되는 시점이 `DataSource`에 있었다. `DataSource`는 현재 다른 타입으로 선언되어있고, (CollectionView.DataSource를 VC하는게 아닌 타입을 새로 만듦) 이럴 경우 어떤 방법을 써서 인디케이터를 중지해줘야 할까?
    
    (1) **인디케이터 참조 넘겨주기** :  이 방법은 DataSource 타입에서 indicator 프로퍼티를 만들어주고, VC에서 indicator를 주입시켜준다. 
    
    (2) **DataSource가 ViewController를 소유** : VC와 DataSource가 순환참조에 걸릴 수 있으니, weak 사용
    
    (3) **Notification** : 이 프로젝트에서 사용한 방법
    
    (4) **KVO (key-value Observing) 패턴**
    
    (5) **MVVM패턴** : 이 부분은 나중에 공부를 더 해봐야겠다. VM에서 옵저빙을 통하여 속성에 변화를 감지 할 수 있게끔 할 수 있다는데, 아직 잘 모르겠음.
<br>

2. **스크롤을 진행하면 데이터를 불러올때, 잠시 화면이 깜빡거리는 현상이 있음.**
    - ![Simulator Screen Recording - iPhone 12 - 2021-08-28 at 14 38 48](https://user-images.githubusercontent.com/71247008/131210620-9c4d81b3-eae8-4f53-a370-76c57d131054.gif)
    - 생각해보았을때 CollectionView의 ReloadData() 문제 인 것 같다.
    - ReloadData는 애니메이션을 사용하지 않기 때문에 깜빡거리는 현상이 있을 수 있을까? 아니면 다른방법이 있을까?
        - ReloadData의 작동방식은 메서드가 호출될 때 numberOfInSection이 호출되고 cellForItemAt 사용될 cell을 리턴해주게 된다. 그 이후 CollectionView의 layoutSubViews이 호출 된다고 한다. 
        - CollectionView의 performBatchUpdates(_:completion:) 메서드가 존재 한다고 한다.. 아직 사용법은 잘 모르겠음.

<br>

3. **CollectionView Cell의 역할 분리**
    - 현재 CollectionView Cell이 confirue 메서드에서 해당 indexPath에 맞는 Data를 받아 Cell View에 표시해주고 있음. 하지만 configure에서 Data를 받아서 분기처리를 진행 하고 있다.  곰곰히 우리가 생각 해 보았을 때 해당 역활은 View가 할일이 아닌 다른(VC)데에서 할 일 같다는 생각이 들었다. 하지만, 시간이 없는 관계로.. 이 부분을 해결 하지 못했다.
```swift
 if item.stock == 0 {
        statusLabel.text = "품절"
        statusLabel.textColor = .systemYellow
    } else {
        let stock = apply(to: item.stock)
        statusLabel.textColor = .systemGray
        statusLabel.text = "잔여수량: \(stock)"
    }
```

4. **URLComponent를 사용하는 부분**
    - 아래와 같이 URlComponent객체를 사용하여 URL을 만들 수 있지 않았을까하는 아쉬움이 남는다. 
    ```=swift
    private func makeUrlComponent(baseUrl: UrlList, _ path: String) -> Result<URL, NetworkError> {
        var components = URLComponents(string: UrlList.baseUrl.rawValue)
        let cliendID = URLQueryItem(name: "page", value: ":\(path)")
        components?.queryItems = [cliendID]
        guard let finalUrl = components?.url! else { return .failure(NetworkError.urlInvalid) }
        return .success(finalUrl)
    }
    ```

5. **Flowlayout 하드코딩 한 부분** 
- Layout 타입 내부에서 UICollectionViewFlowLayout 객체를 return하는 메서드를 만들 때 내부 코드에 하드코딩이 많았다. 이 부분에 하드코딩을 어떻게 하면 줄일 수 있을지에 관한 고민이 부족했던 것 같다. 
    ```swift
        static func generate(_ view: UIView) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let width = view.bounds.width / 2.2
        let height = view.bounds.height / 3.6
        
        layout.itemSize = CGSize(width: width, height: height)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        return layout
    }
    ```


</div>
</details>

<br><br>


---

## VI. 관련 학습 내용 
#### 학습 키워드
- HTTP
- 네트워크 통신
- url Session
- Cache
- Paging
- UICollectionView
- 비동기 통신


#### 1. HTTP 
(1) HTTP란?
- hyper text trasition protocol 을 줄임말. 네트워크 통신을 이용하여 데이터를 주고 받기 위하여 생긴 약속이다.
- 클라이언트가 url을 통하여 `request(요청)` 하면 서버에서는 해당 요청사항에 맞는 결과를 `response(응답)` 하는 형태로 동작한다. 

(2) Request 와 Response
 - Request Message
    - HTTP Request는 넓게보면 세가지 종류가 있다. 시작라인, 헤더, 바디
    - start Line은 서버가 수행해야할 동작을 나타낸다. HTTP request method를 명시.
    - Header는 요청의 내용을 좀 더 구체와 시키고, 조건에 따른 제약사항을 넣기도 한다. 
    - Body는 리소스를 가져오는 Request는 보통 본문이 없다. 전달해야될 내용이 없기 때문이다. 일부 요청은 업데이트를 위해 서버에 데이터를 전송한다. POST시 그럴 확률이 높다. Data를 Body에 담아 request 요청을 한다.
    - Body의 종류는 단일 리소스, 각기 다른 리소스가 있을 경우 멀티파트를 사용한다.
    - Request HTTP 메시지 예시 
    ```swift
    POST / HTTP / 1.1                   <- 시작부분
    HOST: localhost:8000                <- header
    Content-Type: multipart/form-data;  <- header
    Content-Length: 333                 <- header
    //한칸띄어쓰면 그 이후에는 본문이 시작된다.
    -123456          <- body
    (more Data)      <- body
    ``` 
- Response Message
    



#### 2. URLSession
- URLSession은 HTTP, HTTPS 를 통해 콘텐츠를 주고 받는 apple 에서 API를 제공해주는 클래스이다.
- URLSession은 세가지 유형을 제공하고 있다. URLSession 개체가 가지고 있는 `Confiruation` 프로퍼티로 결정 할 수 있다.
    - 기본적인 동작 방법은 Session Confiruation을 결정하고 URLSession을 생성한다.
통신을 할 URL과 Request 를 설정한다.
사용할 Task를 결정하고 Task를 실행한다.
네트워크 통신은 기본적으로 비동기 처리 임으로 탈출 클로저를 사용하여, 통신이 완료됐을 때 동작을 설정한다.


- Task
    - Task 개체는 Session이 `request`을 보낸 후, `response`를 받을 때 내용들을 받는 역활을 하게 된다. 3가지 종류의 Task가 있다. 
        - Data Task = Data 개체를 통해 주고받는 Task이다.
        - Download Task = Data를 파일의 형태로 전환 후 다운 받는 Task이다. 백그라운드에서 다운할 수 있는 기능을 지원한다.
        - Upload Task = Data를 파일의 형태로 전환 후 업로드 할 수 있는 Task이다.

- URLRequest
    - URLRequest를 통하여 서버로 `request`를 보낼 때 어떤 HTTP Request Method를 사용할 것인지, 어떤 내용을 전송할 것인지 설정 할 수 있다. 
    - HTTPRequest의 setValue, addValue을 사용하여 헤더메시지를 설정하거나, 추가 할 수 있다. 
    - 프로젝트 URLRequest 적용사항.
    ```swift
    private static func createRequest(httpMethod: HTTPMethod, url: URL, body: Data?, _ contentType: ContentType) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("\(contentType); boundary=\(Boundary.literal)", forHTTPHeaderField: "Content-Type")
        request.httpMethod = String(describing: httpMethod)
        request.httpBody = body
        return request

    // URLRequest의 헤더를 설정하고, 
    // 어떤 request 할지 httpMethod에 설정하고, 
    // httpbody에 데이터를 넣어
    // URLRequest를 리턴하게 된다. 
    }
    ``` 
<br>


#### 2. Lazy Loading 
- lazy Loading이란?
    - Lazy loading is a design pattern commonly used in computer programming to defer initialization of an object until the point at which it is needed. 즉 필요한 순간에만 초기화되도록 하는 디자인 패턴이다. 
    - 테이블뷰나 컬렉션뷰의 경우 주로 `tableVeiw(_:cellForRowAt:)`, `collectionView(_:cellForItemAt:)` 메소드에서 `cell`이 스크린에 보여지기 직전 혹은 보여지기 전에 `cell`을 구성할 contents들을 위한 객체를 구현한다. 


#### 3. Cache
(1) Cache란?
- 자주 사용하는 데이터나 값을 미리 복사해 놓는 임시장소
- 언제 사용 : 캐시접근하는 시간과 서버에 있는 데이터에 접근하는 시간 중 후자가 더 오래걸리는 경우, 값을 다시 계산하는 시간을 절약하고 싶은 경우에 사용
- 장점 : 더 빠른 속도로 데이터에 접근할 수 있다. 
- 구분의 기준 : local and Global, 저장 장소, 지역성에 따라 캐쉬의 구분이 달라진다. 

    
     
#### 4. UICollectionView
<img src="https://user-images.githubusercontent.com/71247008/131329119-da338da1-ceff-4a48-8646-9270e2c4d08f.png" width="400" height="300">
<br><br>

- 컬렉션뷰는 테이블뷰와 비슷한 구조를 가지고 있다. `View`에 나타내야하는 정보를 `DataSource`로 요구하며, 이벤트와 같은 기능을 `Delegate`로 구현하고 있다. 다만 다른점이 있다면, `CollectionViewFlowLayout` 으로 셀의 크기와 너비를 설정해주어야 한다.
- 기본적으로 DataSource 구현은 TableView와 많이 닮아 있다. numberOfSections 메서드로 섹션의 갯수를 지정해 줄 수 있으며, numberOfItemsInSection 메서드로 섹션안에 셀이 얼마나 있어야 할지 알려주게 된다. 마지막으로 cellForItemAt 메서드로 셀을 생성하고, 해당 셀에 데이터를 주입시켜 반환을 시키면 된다.

```swift
//    섹션의 갯수를 설정하는 부분
func numberOfSections(in collectionView: UICollectionView) -> Int {
        OpenMarketDataSource.openMarketItemList.count
    }
//    섹션에 셀의 갯수를 설정하는 부분
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        OpenMarketDataSource.openMarketItemList[section].items.count
    }
//    Cell을 생성하며, Cell을 configure하여 Cell을 return 해주는 역활을 담당.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "openMarketCell", for: indexPath) as? OpenMarketItemCell else {
            return UICollectionViewCell()
        }
```

- UICollectionViewFlowLayout
<img src="https://user-images.githubusercontent.com/71247008/131330825-95071f5d-ed95-459b-980a-64101bd31e10.png" width="400" height="200">
    - FlowLayout은 콜렉션 뷰의 delegate 나 Flowlayout 클래스의 프로퍼티를 사용하여 셋팅 할 수 있다.
    - delegate는 CollecvionView가 header 나 footer 를 설정하거나, 셀마다 Size를 다르게 하고 싶을 때 유용하다고 하다.









