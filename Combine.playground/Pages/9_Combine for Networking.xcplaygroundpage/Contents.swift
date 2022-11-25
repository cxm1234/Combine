//: [Previous](@previous)

import Combine
import Foundation

example(of: "network data to multiple subscribers") {
    
    let url = URL(string: "https://www.raywenderlich.com")!
    
    let publisher = URLSession.shared
        .dataTaskPublisher(for: url)
        .map(\.data)
        .multicast {
            PassthroughSubject<Data, URLError>()
        }
    
    publisher
        .sink { completion in
            if case .failure(let error) = completion {
                print("Sink1 Retrieving data failed with error \(error)")
            }
        } receiveValue: { object in
            print("Sink1 Retrieved object \(object)")
        }
        .store(in: &subscriptions)
    
     publisher
        .sink { completion in
            if case .failure(let error) = completion {
                print("Sink2 Retrieving data failed with error \(error)")
            }
        } receiveValue: { object in
            print("Sink2 Retrieved object \(object)")
        }
        .store(in: &subscriptions)
    
    subscription = publisher.connect() as! AnyCancellable
    
}

//: [Next](@next)
