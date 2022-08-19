
#

## 번역 기능을 가진 App 만들기

###1-1 major 구현 목표

1. 입력한 텍스트를 번역한다. (check)
2. 음성을 텍스트화 하고 `Dictation` 그 텍스트를 번역한다.
3. 번역하고 번역된 결과를 핸드폰이 읽어준다. 

###1-2 minor 구현 목표
1. data 삭제 구현
2. 네트워크 연결 확인하고 alert


### index
- 0711 coredata fetch 구현중
- 0713 coredata 사용한 bookmark 구현 끝
- 0714 save후 fetch data 가 뷰에 반영되지 않는 오류 해결
- 0811 speechRecognizer 추가 완료, 음성 녹음 중이라는걸 확인하기 위한 view 생성
- 0817 bookmark에 읽기 버튼 추가
- 0818 북마크 버튼 클릭의 이벤트 필요, 삭제 기능 필요 -> swipe 삭제 하고 싶어서 layout 변경 -> 원복
- 0819 collection view list는 모양 내는 데에 한계가 있다, view model 설계 수정, layout list로 수정
- 북마크 저장 성공/실패 시 alert로 알림 (TOBE)
- STT 이벤트 바인딩 (TOBE)

#### iOS

##### 1. NSAttributedString vs NSMutalbleAttributedString

- NSAttributedString
  - class NSAttributedString: NSObject
  - 텍스트 자체에 스타일 (색상, 자간, 행간 등)을 설정

```swift
let paragraphStyle = NSMutableParagraphStyle()
paragraphStyle.lineSpacing = 6
let attributes: [NSAttributedString.Key : Any] = [
    .font: UIFont.systemFont(ofSize: 26.0, weight: .bold),
    .paragraphStyle: paragraphStyle,
    .foregroundColor: UIColor.systemBlue
]

let text = NSAttributedString(string: "stringstringstring", attributes: attributes)

textView.attributedText = text
```

- NSMutableAttributedString
  - class NSMutableAttributedString: NSObject
  - NSAttributedString의 특정 범위 NSRange에 다양한 스타일을 설정

```swift

...
let text = NSMutableAttributedString(string: "stringstringstring2", attributes: attributes)
let additionalAttributes: [NSAttributedString.Key : Any] = [
    .font: UIFont.systemFont(ofSize: 24.0, weight: .semibold),
    .foregroundColor: UIColor.systemRed
]
text.addAttributes(additionalAttributes, range: NSRange(location: 3, length:10))
textView.attributedText = text

```

##### 2. CoreData
> Persist of cache data on a single device, or sync data to multiple devices with CloudKit

`Overview`
- use Core Data to save your application's permanent data
- for offline use, to cache temporary data, and to add undo functionality 
- to sync data across multiple devices in a single iCloud account

`Core Data's Data Model editor`
- define your data's types and relationships
- generate respective class definitions 
- manage object instances at runtime to provide the following features
    - persistence
    - undo and redo of individual or batched changes 
    - background data tasks
    - view synchronization
    - versioning and migration

###### Process

1. Creating a Core Data Model
> Definde your app's object structure with a data model file

2. Setting Up a Core Data Stack
> Set up the classses that manage and persist your app's objects

`Persistent container` : NSPersistentContainer
- Model: NSManagedObjectModel
    - represents your app model file 
    - describing app's types, properties, relationship
- Context: NSManagedObjectContext
    - tracks changes to instance of your app's types
- Store coordinator: NSPersistentStoreCoordinator
    - sets up the model, context, and store 
    
1) Initialize a persistent container

- typically, initialize Core Data during your app's startup
- create the persistent container as a lazy variable in app's delegate
- create a persistent container instance, passing the data model filename
- once created, container holds references to the model, context, and store coordinator instances 

2) Pass a persistent container reference to a view controller 

- In your app's root view controller
- import Core Data
- create a variable to hold a reference to a persistent container
- to pass the persistent container to additional view controllers, repeat the creation of a container variable in each view controller, and set its value

```swift
    private lazy var persistentContainer: NSPersistentContainer = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate!.persistentContainer
    }()

```

3) Modeling Data

- Invalid redeclaration error
<https://stackoverflow.com/questions/40410169/invalid-redeclaration-on-coredata-classes>

- Core Data files
    - Editor > Create NSManagedObjectSubclass 
    - Bookmark+CoreDataClass.swift: the Xcode generated subclass of NSManagedObject
    - Bookmark+CoreDataProperties.swift: extension that contains all of its attributes and provides an entity-specific class method for creating a fetch request


##### 3. CollectionView

`pre-required`
- UICollectionViewController
- UICollectionReusableView
- UICollectionViewCell

`UICollectionViewLayout`
- UICollectionViewCompositionalLayout
- NSCollectionLayoutSection

https://www.biteinteractive.com/collection-view-lists-in-ios-14-part-2/
- 드래그하여 삭제 기능 만들기

- UICollectionViewDiffableDataSource 🚛
```swift
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, Item> = {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, index, item in
            
            var content = cell.defaultContentConfiguration()
            content.text = item.bookmark.targetContent
            content.secondaryText = item.bookmark.sourceContent
            content.secondaryTextProperties.color = .secondaryLabel
            content.secondaryTextProperties.font = .preferredFont(forTextStyle: .subheadline)
            content.image = UIImage(systemName: "globe")
            content.imageProperties.preferredSymbolConfiguration = .init(font: content.textProperties.font, scale: .large)
            cell.contentConfiguration = content
            cell.tintColor = .mainTintColor
            cell.accessories = [.customView(configuration: .init(customView: UIImageView(image: UIImage(systemName: "speaker.circle")), placement: .trailing()))]
        }
        return UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }()
    
        private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
```
- collection view의 datasource와 cell을 구현하기 위한 boiler plate 코드보다 편리하다


###### error 1
```
Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: 'UICollectionView must be initialized with a non-nil layout parameter'
```
- UICollectionViewController를 init할 때, layout 객체를 필요로 함
- root viewController 에서 기본 layout을 지정하고
- bookmark vc 의 viewDidLoad에서 대체 

###### error 2
```
[LayoutConstraints] Unable to simultaneously satisfy constraints.
    Probably at least one of the constraints in the following list is one you don't want. 
    Try this: 
        (1) look at each constraint and try to figure out which you don't expect; 
        (2) find the code that added the unwanted constraint or constraints and fix it. 
(
    "<NSLayoutConstraint:0x600000c77980 'UISV-canvas-connection' UIStackView:0x14bf20800.leading == UILabel:0x14bf07ee0.leading   (active)>",
    "<NSLayoutConstraint:0x600000c779d0 'UISV-canvas-connection' H:[UILabel:0x14bf0ed60]-(0)-|   (active, names: '|':UIStackView:0x14bf20800 )>",
    "<NSLayoutConstraint:0x600000c77ac0 'UISV-fill-equally' UILabel:0x14bf06750.width == UILabel:0x14bf07ee0.width   (active)>",
    "<NSLayoutConstraint:0x600000c77c50 'UISV-fill-equally' UILabel:0x14bf09cc0.width == UILabel:0x14bf07ee0.width   (active)>",
    "<NSLayoutConstraint:0x600000c77cf0 'UISV-fill-equally' UILabel:0x14bf0ed60.width == UILabel:0x14bf07ee0.width   (active)>",
    "<NSLayoutConstraint:0x600000c77a20 'UISV-spacing' H:[UILabel:0x14bf07ee0]-(2)-[UILabel:0x14bf06750]   (active)>",
    "<NSLayoutConstraint:0x600000c77c00 'UISV-spacing' H:[UILabel:0x14bf06750]-(2)-[UILabel:0x14bf09cc0]   (active)>",
    "<NSLayoutConstraint:0x600000c77ca0 'UISV-spacing' H:[UILabel:0x14bf09cc0]-(2)-[UILabel:0x14bf0ed60]   (active)>",
    "<NSLayoutConstraint:0x600000c77840 'UIView-Encapsulated-Layout-Width' UIStackView:0x14bf20800.width == 0   (active)>"
)
    
```
- stack view에서 distribution과 spacing이 충돌

###### error3

```
collection view의 cell 이 눈에 보이지 않는 현상
```
- stackView에 constraint 주기
- NSCollectionLayoutItem.contentInsets 조정
- NSCollectionLayoutGroup.vertical vs horizontal
- NSCollectionLayoutSection.orthogonalScrollingBehavior
    - .continuous vs .group paging
    

###### error 4
```
item의 content가 잘리는 현상
```
- scroll view 안에 stack view를 집어넣는다.
- stack view width = scroll view width 여야 vertical scroll 

###### error 5

```
allowed unarchiving safe plist type ''NSString'
```
```swift
    override class var allowedTopLevelClasses: [AnyClass] {
        return [Bookmark.self, NSString.self]
    }
```
- coreData에서 Transformable type을 사용할 경우에 볼 수 있는 에러
- custom 클래스에서 사용되는 NSType을 모두 기록하면 해결된다.

###### error 6
```
coreData 저장 후에 subject에 값을 drive에 반영시키는 과정에서 
BehaviorSubject, PublishSubject가 update되지 않아 collection view에서도 변화가 없는 오류
```
- subject에 값을 전달할 때에 on(.next())를 사용하여 해결 
- 구독은 init에서 이미 이루어졌는데 구독자에게 data를 전달하는 과정에서 실수했다.
- Observable.just는 Observable을 임의로 새롭게 생성해야 할 때에 사용한다. (view->viewModel)
- (viewModel<->viewModel) 을 담당하는 subject에게는 just로 전달하는 것은 적절하지 않다.


#### Property Wrapper

```swift

enum JSONDefaultWrapper {
    typealias EmptyString = Wrapper<JSONDefaultWrapper.DefaultString>
    
    enum DefaultString: JSONDefaultWrapperAvailable {
        static var defaultValue: String { "" }
    }
    
    @propertyWrapper
    struct Wrapper<T: JSONDefaultWrapperAvailable> {
        typealias ValueType = T.ValueType
        var wrappedValue: ValueType
        init() {
            wrappedValue = T.defaultValue
        }
    }
}

extension JSONDefaultWrapper.Wrapper: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.wrappedValue = try container.decode(ValueType.self)
    }
}

extension KeyedDecodingContainer {
    func decode<T: JSONDefaultWrapperAvailable>(_ type: JSONDefaultWrapper.Wrapper<T>.Type, forKey key: Key) throws -> JSONDefaultWrapper.Wrapper<T> {
        try decodeIfPresent(type, forKey: key) ?? .init()
    }
}

```
- property wrapper 를 통해 get 을 통해 return 될 값을 custom한다.
- Decodable과 엮을 경우, key에 따른 value 가 response에 존재하지 않을 때에 기본값을 제공하여 크래쉬를 피할 수 있다.
- 타입에 관계없이 사용할 수 있도록 generic을 적용했다.


### A-ha 

#### UIStackView
> button을 나란히 붙여야 한다면, uiview 보다는 uistackview
```swift
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
    }()
    
    [sourceButton, targetButton].forEach {
    buttonStackView.addArrangedSubview($0)
    }

```

#### addGestureRecognizer

```swift
    let tap = UITapGestureRecognizer(target: self, action: #selector(didTapSourceBaseView))
    view.isUserInteractionEnabled = true
    view.addGestureRecognizer(tap)
```

#### BehaviorRelay

```swift
    let sourceLanguage = BehaviorRelay<LanguageType>(value:.Korean)
    let targetLanguage = BehaviorRelay<LanguageType>(value: .English)
    
    sourceLanguage
    .subscribe({
        print("source: \($0)")
    })

    targetLanguage
        .subscribe({
            print("target: \($0)")
        })

```

- 기본 value를 buffer에 주고 subscribe를 하면 
- 처음의 기본값부터 구독되어 next(Korean), next(English) 이벤트를 받게된다. 
- language에 기본값을 주고 싶어서 사용했다.
- 그 외의 경우에는 PublishRelay를 사용했다.

> https://tech.instacart.com/how-to-think-about-subjects-in-rxjava-part-1-ca509b981020
> https://stackoverflow.com/questions/50020345/behaviorsubject-vs-publishsubject

- subject라는 것 자체가 observable과 subscriber 사이의 proxy bridge라고 이해
- 따라서 subject는 pass through 하면서 동시에 subscribe 한다
- A event가 (1,2,3)을 emit 한 후 구독했고 B event (4,5,6) 이 대기 중일 때
    - PublishSubject(Relay)는 4,5,6 을 받는다.
    - BehaviorSubject(Relay)는 3,4,5,6 을 받는다.
    - ReplaySubject(Relay)는 1,2,3,4,5,6 을 받는다.

#### Signal vs Binder

- 현재는 혼재해서 사용하고 있는데..
- Signal은 새로운 구독자에게 replay 하지 않는다
- Binder는 새로운 구독자에게 초기값 또는 최신 값을 전달한다.

```swift
    // viewModel -> view
    let sourceLabelText: Driver<String>
    let languageList: Driver<[LanguageType]> => Signal로 수정
    let changeLanguageButton: Signal<LanguageOption>
```

- sourceLabelText는 text를 label에 뿌려주고, 이 값으로 network 통신을 해야하기 때문에, 새로운 구독자를 염두에 두고 driver를 사용하기로 했다.
- 이 외에는 Signal을 사용하였다.

#### 😍Alamofire😍 (효자)

```swift
AF.request("https://openapi.naver.com/v1/papago/n2mt",
           method: .post,
           parameters: paramerters,
           encoder: JSONParameterEncoder.default,
           headers: headers
)
.validate(statusCode: 200..<300)
.validate(contentType: ["application/json"])
.responseDecodable(of: ResponseMessage.self) { response in
    switch response.result {
    case let .success(responseMessage):
        let message = responseMessage.message.result
        print("\(message.text)")
    case let .failure(error):
        //TOBE: error alert
        print("\(error)")
    }
    
}

```
- validate 메서드 사용하여 200 코드만 받을 수 있다.
- responseDecodable 객체 통하여 내가 특정한 decodable 객체로 decode해서 response를 받을 수 있다 (간편!)
- encoder: JSONParameterEncoder.default를 통하여 encodable 객체를 바로 parameters로 넘길 수 있다.


