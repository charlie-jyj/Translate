
#

## 번역 기능을 가진 App 만들기

### 구현 목표

1. 입력한 텍스트를 번역한다. (진행중)
2. 음성을 실시간으로 텍스트화 하고 그 텍스트를 번역한다.
3. 음성을 텍스트로 번역하고 번역된 결과를 핸드폰이 읽어준다. 


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


##### 3. CollectionView

`pre-required`
- UICollectionViewController
- UICollectionReusableView
- UICollectionViewCell

`UICollectionViewLayout`
- UICollectionViewCompositionalLayout
- NSCollectionLayoutSection

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

- sourceLabelText는 text를 label에 뿌려주고, 이 값으로 network 통신을 해야하기 때문에, 새로운 구독자를 염두에 두고 driver를 사용하는 것이 적당할 것으로 보인다.
- 이 외에는 Signal을 사용하였다.
