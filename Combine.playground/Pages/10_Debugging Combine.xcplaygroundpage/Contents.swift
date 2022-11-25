//: [Previous](@previous)

import Foundation
import Combine

//example(of: "printing events") {
//    let subscription = (1...3).publisher
//        .print("publisher")
//        .sink { _ in }
//}

example(of: "TimeLogger") {
        (1...3).publisher
        .print("publisher", to: TimeLogger())
        .sink { _ in }
        .store(in: &subscriptions)
}

//: [Next](@next)
