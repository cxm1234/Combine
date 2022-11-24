import Foundation
import Combine


//
//example(of: "Publisher") {
//    let myNotification = Notification.Name("MyNotification")
//
//    let publisher = NotificationCenter.default
//        .publisher(for: myNotification, object: nil)
//
//    let center = NotificationCenter.default
//
//    let observer = center.addObserver(forName: myNotification, object: nil, queue: nil) { notification in
//        print("Notification received!")
//    }
//
//    center.post(name: myNotification, object: nil)
//
//    center.removeObserver(observer)
//}
//
//example(of: "Subscriber") {
//    let myNotification = Notification.Name("MyNotification")
//
//    let publisher = NotificationCenter.default
//        .publisher(for: myNotification, object: nil)
//
//    let center = NotificationCenter.default
//
//    let subscription = publisher
//        .sink { _ in
//            print("Notification received from a publisher!")
//        }
//
//    center.post(name: myNotification, object: nil)
//
//    subscription.cancel()
//}
//
//example(of: "Just") {
//    let just = Just("Hello world!")
//
//    _ = just
//        .sink(receiveCompletion: {
//            print("Received completion", $0)
//        },
//              receiveValue: {
//            print("Received value", $0)
//        })
//
//    _ = just
//        .sink(receiveCompletion: {
//            print("Received completion (another)", $0)
//        }, receiveValue: {
//            print("Received value (another)", $0)
//        })
//
//}
//
//example(of: "assign(to:on:)") {
//    class SomeObject {
//        var value: String = "" {
//            didSet {
//                print(value)
//            }
//        }
//    }
//
//    let object = SomeObject()
//
//    let publisher = ["Hello", "world!"].publisher
//
//    _ = publisher.assign(to: \.value, on: object)
//}
//
//example(of: "Custom Subscriber") {
////    let publisher = (1...10).publisher
//    let publisher = ["A", "B", "C", "D", "E", "F"].publisher
//
//    final class IntSubscriber: Subscriber {
//
//        typealias Input = String
//
//        typealias Failure = Never
//
//        /// 初始请求数量
//        /// - Parameter subscription: 请求订阅
//        func receive(subscription: Subscription) {
//            subscription.request(.max(3))
//        }
//
//        /// 请求到一个事件并返回后，再增加的请求数量
//        /// - Parameter input: 请求数量
//        /// - Returns: 增加的请求数
//        func receive(_ input: String) -> Subscribers.Demand {
//            print("Received value", input)
//            if input == "E" {
//                return .max(1)
//            } else {
//                return .none
//            }
//        }
//
//        func receive(completion: Subscribers.Completion<Never>) {
//            print("Received completion", completion)
//        }
//    }
//
//    let subscriber = IntSubscriber()
//
//    publisher.subscribe(subscriber)
//
//}

//example(of: "Future") {
//
//    func generateAsyncRandomNumberFromFuture() -> Future <Int, Never> {
//        return Future() { promise in
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                let number = Int.random(in: 1...10)
//                promise(Result.success(number))
//            }
//        }
//    }
//
//    func futureIncrement(integer: Int, afterDelay delay: TimeInterval) -> Future<Int, Never> {
//
//        Future<Int, Never> { promise in
//            print("Original")
//            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
//                promise(.success(integer + 1))
//            }
//        }
//    }
//
//    let future = futureIncrement(integer: 1, afterDelay: 3)
//
////    let future = generateAsyncRandomNumberFromFuture()
//
//    future.sink(
//        receiveCompletion: { print($0) },
//        receiveValue: { print($0) }
//    )
//    .store(in: &subscriptions)
//
//    future.sink(
//        receiveCompletion: { print("Second", $0) },
//        receiveValue: { print("Second", $0) }
//    )
//    .store(in: &subscriptions)
//
//}

example(of: "PassthroughSubject") {
    enum MyError: Error {
    case test
    }
    
    final class StringSubscriber: Subscriber {
        typealias Input = String
        typealias Failure = MyError
        
        func receive(subscription: Subscription) {
            subscription.request(.max(2))
        }
        
        func receive(_ input: String) -> Subscribers.Demand {
            print("Received value", input)
            
            return input == "World" ? .max(1) : .none
        }
        
        func receive(completion: Subscribers.Completion<MyError>) {
            print("Received completion", completion)
        }
    }
    
    let subscriber = StringSubscriber()
    
    let subject = PassthroughSubject<String, MyError>()
    
    subject.subscribe(subscriber)
    
    let subscription = subject.sink { completion in
        print("Received completion (sink)", completion)
    } receiveValue: { value in
        print("Received value (sink)", value)
    }
    
    subject.send("Hello")
    
    subject.send("World")
    
    subscription.cancel()
    
    subject.send("Still there?")
    
    subject.send(completion: .failure(MyError.test))
    
    subject.send(completion: .finished)
    
    subject.send("How about another one?")
    
}

example(of: "CurrentValueSubject") {
    var subscriptions = Set<AnyCancellable>()
    
    let subject = CurrentValueSubject<Int, Never>(0)
    
    subject
        .print()
        .sink(receiveValue: { print($0) } )
        .store(in: &subscriptions)
    
    subject.send(1)
    subject.send(2)
    
    print(subject.value)
    
    subject.value = 3
    print(subject.value)
    
    subject
        .print()
        .sink(receiveValue: { print("Second subscription:", $0)})
        .store(in: &subscriptions)
    
    subject.send(completion: .finished)
}

example(of: "Dynamically adjusting Demand") {
    final class IntSubscriber: Subscriber {
        typealias Input = Int
        typealias Failure = Never
        
        func receive(subscription: Subscription) {
            subscription.request(.max(2))
        }
        
        func receive(_ input: Int) -> Subscribers.Demand {
            print("Received value", input)
            
            switch input {
            case 1:
                return .max(2)
            case 3:
                return .max(1)
            default:
                return .none
            }
        }
        
        func receive(completion: Subscribers.Completion<Never>) {
            print("Received completion", completion)
        }
    }
    
    let subscriber = IntSubscriber()
    
    let subject = PassthroughSubject<Int, Never>()
    
    subject.subscribe(subscriber)
    
    subject.send(1)
    subject.send(2)
    subject.send(3)
    subject.send(4)
    subject.send(5)
    subject.send(6)
}

example(of: "Type erasure") {
    let subject = PassthroughSubject<Int, Never>()
    
    let publisher = subject.eraseToAnyPublisher()
    
    publisher
        .sink(receiveValue: { print($0) } )
        .store(in: &subscriptions)
    
    subject.send(0)
    
}

example(of: "Create a Blackjack card dealer") {
    let dealtHand = PassthroughSubject<Hand, HandError>()
    
    func deal(_ cardCount: UInt) {
        var deck = cards
        var cardsRemaing = 52
        var hand = Hand()
        
        for _ in 0 ..< cardCount {
            let randomIndex = Int.random(in: 0 ..< cardsRemaing)
            hand.append(deck[randomIndex])
            deck.remove(at: randomIndex)
            cardsRemaing -= 1
        }
        
        if hand.points > 21 {
            dealtHand.send(completion: .failure(.busted))
        } else {
            dealtHand.send(hand)
        }
    }
    
    _ = dealtHand
        .sink(receiveCompletion: {
            if case let .failure(error) = $0 {
                print(error)
            }
        }, receiveValue: { hand in
            print(hand.cardString, "for", hand.points, "points")
        })
    
    deal(3)
}




