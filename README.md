## 은행창구 매니저 🏦

### 목차
- [1. 소개](#1-소개)
- [2. 팀원](#2-팀원)
- [3. 타임라인](#3-타임라인)
- [4. 프로젝트 구조](#4-프로젝트-구조)
- [5. 실행 화면](#5-실행-화면)
- [6. 트러블 슈팅](#6-트러블-슈팅)
- [7. 팀 회고](#7-팀-회고)
- [8. 참고 자료](#8-참고-자료)

---
### 1. 소개
- 은행창구 매니저 앱을 소개합니다! 
- 은행창구 매니저 콘솔 앱은`1. 은행개점` `2. 종료` 메뉴로 이뤄져 있습니다. 1번을 입력하여 은행개점을 하시면 한 명의 은행원이 근무를 하게 되고, 10명 ~ 30명 사이의 고객을 받아 차례차례 업무를 도와드립니다. 👍
- 모든 고객의 업무가 끝나면 은행문은 닫히게 되고, 메뉴가 다시 출력됩니다.
- 오늘은 얼마나 많은 고객을 받을 수 있을까요? 은행창구 매니저 앱을 통해 은행창구 매니저의 극한직업을 체험해봅시다. 😅

### 2. 팀원
| <img src="https://avatars.githubusercontent.com/u/154333967?v=4" width="200"> | <img src="https://avatars.githubusercontent.com/u/27756800?v=4" width="200"> |
| :-: | :-: |
| Danny ([Github](https://github.com/dannykim1215)) | Prism ([Github](https://github.com/PrismSpirit)) |

### 3. 타임라인
| 날짜 | 제목 |
| --- | --- |
| 24.03.18(월) ~ 03.20(수) | Queue에 사용할 Generic List 구현(`SinglyLinkedList`) |
| 24.03.21(목) | 대기열에 들어갈 고객의 정보를 담는 `Customer` 타입 생성<br>BankManager 타입 생성 및 업무 개시 기능 구현(`DispatchQueue`와 `DispatchSemaphore` 활용)<br>Bank 총 업무시간을 구하는 로직 구현(`DispatchTime` 활용) |
| 24.03.22(금) | BankManager 콘솔 앱 구현 |
| 24.03.27(수) ~ 03.28(목) | 업무(대출, 예금)에 따른 은행원 세분화 |
| 24.03.29(금) | 고객이 원하는 업무에 따라 은행원에 고객을 분배(`DispatchSemaphore` 활용)<br> 은행 업무가 시작되었을 때와 종료되었을 때의 행동을 해당 모듈(`BankManger`)을 사용하는 앱에 위임해주기 위해 Delegate 패턴을 활용 |

### 4. 프로젝트 구조
![img](<https://raw.githubusercontent.com/dannykim1215/ios-bank-manager/ic_11_danny/BankManager_ClassDiagram.png>)

### 5. 실행 화면
- **Console App**

| 은행 업무 개시 |
| :---: |
| <img src="https://raw.githubusercontent.com/dannykim1215/ios-bank-manager/ic_11_danny/Screenshots/Recording_ConsoleApp_Commence.gif" width=500> |

| 유효하지 않은 메뉴 선택 처리 |
| :---: |
| <img src="https://raw.githubusercontent.com/dannykim1215/ios-bank-manager/ic_11_danny/Screenshots/Recording_ConsoleApp_Invalid_Input.gif" width=500> |

| 앱 종료 |
| :---: |
| <img src="https://raw.githubusercontent.com/dannykim1215/ios-bank-manager/ic_11_danny/Screenshots/Recording_ConsoleApp_Exit.gif" width=500> |

### 6. 트러블 슈팅
#### 1. ❗️총 업무시간 계산하는 방법에 대한 문제
##### 📌 문제 상황
- 은행원이 한 명일 때는 문제가 되지 않으나 여러 명의 은행원이 업무를 처리할 경우 총 업무 시간을 수동으로 추적해 카운팅하는 것은 매우 번거로우며 비효율적입니다.

```swift=
// BankManager.swift

...

let bankingElapsedTime = 0.0

while !bankQueue.isEmpty {
    ...
    
    bankingElapsedTime += 0.7
    
    ...
}

...
```

##### 🛠️ 해결 방법
- `DispatchTime.now()` 메서드를 활용하여 업무시간 구하는 로직을 구현하였습니다. 단위가 나노 초이기 때문에 `1_000_000_000`으로 나눠줬습니다. 그리고 소수점 둘째 자리까지 표현하기 위해 extension를 이용하여 Double에 `rounded(toPlaces: Int)` 메서드를 확장했습니다. 결론적으로, 원하는 시간 단위 및 자리 수로 출력할 수 있었습니다.

```swift=
// BankManager.swift

...

let bankingStartTime = DispatchTime.now()

while !bankQueue.isEmpty {
    ...
}

let bankingEndTime = DispatchTime.now()
let bankingElapsedTime = (Double(bankingEndTime - bankingStartTime) / 1_000_000_000)
print("업무가 마감되었습니다. 오늘 업무를 처리한 고객은 총 \(visitedCustomerNumber)명이며, 총 업무시간은 \(bankingElapsedTime.rounded(toPlaces: 2))초입니다.")

...

```
```swift=
// Double+rounded.swift

extension Double {
    func rounded(toPlaces: Int) -> Double {
        let divisor = pow(10.0, Double(toPlaces))
        return (self * divisor).rounded() / divisor
    }
}
```

#### 2. ❗️은행 업무 처리를 메인 스레드에서 할 경우 발생하는 문제점
##### 📌 문제 상황
- 이 모듈은 UI 앱에서도 사용되어야 하나, 단순 반복문만을 사용해 메인 스레드에서 업무를 처리할 경우 처리하는 동안 `Thread.sleep(forTimeInterval:)`로 현재 스레드(메인 스레드)를 멈추기 때문에 UI 처리가 불가능하게되고 쾌적하지 못한 사용자 경험을 유발할 수 있다고 판단했습니다.

```swift=
// BankManager.swift

...

while !bankQueue.isEmpty {
    guard let customer = bankQueue.dequeue else { break }
    
    ...
    
    Thread.sleep(forTimeInterval: 0.7)
    
    ...
}

...

```

##### 🛠️ 해결 방법
- `DispatchQueue.global()`을 활용해 업무 처리가 메인 스레드가 아닌 다른 스레드에서 처리될 수 있게 했습니다. 또한 은행원의 수의 변화에 유연하게 대응할 수 있도록 DispatchSemaphore를 사용해 동시에 실행될 수 있는 Task의 수를 정해줄 수 있도록 했습니다.
```swift=
// BankManager.swift

...

let concurrentLimitingSemaphore = DispatchSemaphore(value: numberOfBankClerk)

while !bankQueue.isEmpty {
    concurrentLimitingSemaphore.wait()

    guard let customer = bankQueue.dequeue() else { return }

    DispatchQueue.global().async {
        ...
        Thread.sleep(forTimeInterval: 0.7)
        ...
        concurrentLimitingSemaphore.signal()
    }
}

...

```

#### 3. ❗️마지막 고객의 업무를 시작하고 바로 업무를 마감하는 문제
##### 📌 문제 상황
- `DispatchQueue.global().async`의 block을 global큐에 넣고 바로 다음 코드를 실행하기 때문에 마지막 고객의 업무를 시작은 하나, 완료하지 않고 은행 업무 자체를 마감해버리는 문제가 있었습니다.
```swift=
/// BankManager.swift

...

let concurrentLimitingSemaphore = DispatchSemaphore(value: numberOfBankClerk)

while !bankQueue.isEmpty {
    concurrentLimitingSemaphore.wait()

    guard let customer = bankQueue.dequeue() else { return }

    DispatchQueue.global().async {
        ...
        Thread.sleep(forTimeInterval: 0.7)
        ...
        concurrentLimitingSemaphore.signal()
    }
}

...

```

##### 🛠️ 해결 방법
- `DispatchQueue.global().async`의 block을 `bankingGroup`으로 묶어 모든 고객의 업무가 처리될 때까지 대기해주도록 수정했습니다.
```swift=
// BankManager.swift

...

let concurrentLimitingSemaphore = DispatchSemaphore(value: numberOfBankClerk)
let bankingGroup = DispatchGroup()

while !bankQueue.isEmpty {
    concurrentLimitingSemaphore.wait()

    guard let customer = bankQueue.dequeue() else { return }

    DispatchQueue.global().async(group: bankingGroup) {
        ...
        Thread.sleep(forTimeInterval: 0.7)
        ...
        concurrentLimitingSemaphore.signal()
    }
}

bankingGroup.wait()

...

```

#### 4. ❗️`BankManger` 모듈을 사용하는 앱에서 활용할 때 유연한 행동을 할 수 없는 문제
##### 📌 문제 상황
- `BankManager` 모듈은 은행 업무 시작, 종료 행동을 print()문으로 실행하여 로그를 확인할 수 있었습니다. 하지만, 해당 모듈을 사용하는 모든 앱은 강제적으로 은행 업무에 대한 로그를 실행해야하는 문제가 있었기 때문에 트러블 슈팅이 필요하다고 판단했습니다.

```swift=
// BankManager.swift

public final class BankManager {
    ...
    
    public func commenceBanking() {
        ...
        
        DispatchQueue.global().async(group: bankingGroup) {
            ...
            
            print("\(customer.waitingNumber)번 고객 업무 시작")
            Thread.sleep(forTimeInterval: 0.7)
            print("\(customer.waitingNumber)번 고객 업무 완료")
            
            ...
        }
        
        ...
        
        print("업무가 마감되었습니다. 오늘 업무를 처리한 고객은 총 \(visitedCustomerNumber)명이며, 총 업무시간은 \(bankingElapsedTime.rounded(toPlaces: 2))초입니다.")
    }
}

```

##### 🛠️ 해결 방법
- `BankManagerDelegate` 프로토콜 생성, `Delegate` 패턴을 활용하였습니다. 그리하여 `BankManager` 모듈의 은행 업무 시작, 종료 행동을 유연하게 만들 수 있었습니다.

```swift=
// BankManager.swift

public protocol BankManagerDelegate: AnyObject {
    func bankingStarted(customer: Customer)
    func bankingEnded(customer: Customer)
    func bankClosed(customersCount: Int, elapsedTime: Double)
}

public final class BankManager {
    public weak var delegate: BankManagerDelegate?
    
    ...
    
    public func commenceBanking() {
        ...
        
        DispatchQueue.global().async(group: bankingGroup) {
            ...
            
            self.delegate?.bankingStarted(customer: customer)
            Thread.sleep(forTimeInterval: customer.banking.requiredTime)
            self.delegate?.bankingEnded(customer: customer)
            
            ...
        }
        
        ...
        
        self.delegate?.bankClosed(customersCount: customersCount, elapsedTime: bankingElapsedTime)
    }
}
```

```swift=
//ConsoleApp.swift

final class ConsoleApp: BankManagerDelegate {
    var bankManager: BankManager
    
    init() {
        bankManager = BankManager(loanClerksCount: 1, depositClerksCount: 2)
        bankManager.delegate = self
    }
    
    ...
    
    func bankingStarted(customer: Customer) {
        print("\(customer.waitingNumber)번 고객 \(customer.banking.name)업무 시작")
    }
    
    func bankingEnded(customer: Customer) {
        print("\(customer.waitingNumber)번 고객 \(customer.banking.name)업무 종료")
    }
    
    func bankClosed(customersCount: Int, elapsedTime: Double) {
        print("업무가 마감되었습니다. 오늘 업무를 처리한 고객은 총 \(customersCount)명이며, 총 업무시간은 \(elapsedTime.rounded(toPlaces: 2))초입니다.")
    }
}

```

### 7. 팀 회고
#### 우리팀이 잘한 점 😍
- Danny
  - 코딩 컨벤션을 잘 지켰습니다. 상호 의견을 존중했습니다.
  - Delegate 패턴에 대해 적극적으로 공부하고 모르는 것을 물어보고자 노력했습니다.
  - 서로 일정이 어렵다면 미리 조원에게 알려서 일정 조정을 하였습니다.
- Prism 
  - 하나의 모듈을 여러 앱(Console, UI)에서 사용할 수 있도록 역할에 맞게 모듈화했습니다
  - 은행원의 업무 처리를 동시성 프로그래밍을 활용해 성공적으로 구현했습니다
  - 프로젝트 진행 중 적극적으로 소통해 트러블 없이 프로젝트를 마무리했습니다

### 8. 참고 자료
📍[Generics](<https://docs.swift.org/swift-book/documentation/the-swift-programming-language/generics>)  
📍[Testing your apps in Xcode](<https://developer.apple.com/documentation/xcode/testing-your-apps-in-xcode>)  
📍[Dispatch Queues](<https://developer.apple.com/library/archive/documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationQueues/OperationQueues.html>)  
📍[Rounding a double value to x number of decimal places in swift](<https://stackoverflow.com/questions/27338573/rounding-a-double-value-to-x-number-of-decimal-places-in-swift>)  
