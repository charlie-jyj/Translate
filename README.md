
#

## 번역 기능을 가진 App 만들기

### 구현 


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

- sourceLabelText는 text를 label에 뿌려주고, 이 값으로 network를 해야하기 때문에, 새로운 구독자를 염두에 두고 driver를 사용하는 것이 적당할 것 같고
- 이 외에는 Signal을 사용하는 것이 맞을 듯 하다.
