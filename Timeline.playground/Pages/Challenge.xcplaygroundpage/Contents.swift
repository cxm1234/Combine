//: [Previous](@previous)

import Foundation
import Combine

let subject = PassthroughSubject<Int, Never>()

let strings = subject
    .collect(.byTime(DispatchQueue.main, .seconds(0.5)))
    .map { array in
        
        let result = String(array.map {
            let c = Character(Unicode.Scalar($0)!)
            print(c)
            return c
        })
        return result
    }

let spaces = subject.measureInterval(using: DispatchQueue.main)
    .map { interval in
        interval > 0.9 ? "👏🏻" : ""
    }

let subscription = strings
    .merge(with: spaces)
    .filter { !$0.isEmpty }
    .sink {
        print($0)
    }

startFeeding(subject: subject)

//: [Next](@next)
