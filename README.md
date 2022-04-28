
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

