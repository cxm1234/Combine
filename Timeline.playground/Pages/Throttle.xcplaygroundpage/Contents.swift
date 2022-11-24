//: [Previous](@previous)

import SwiftUI
import Combine
import PlaygroundSupport

let throttleDelay = 1.0

let subject = PassthroughSubject<String, Never>()

let throttled = subject
    .throttle(for: .seconds(throttleDelay), scheduler: DispatchQueue.main, latest: false)
    .share()

let subjectTimeline = TimelineView(title: "Emitted values")
let throlltledTimeline = TimelineView(title: "Throttle values")

let view = VStack(spacing: 100) {
    subjectTimeline
    throlltledTimeline
}

PlaygroundPage.current.liveView = UIHostingController(rootView: view)

subject.displayEvents(in: subjectTimeline)
throttled.displayEvents(in: throlltledTimeline)

let subscription1 = subject
    .sink { string in
        print("+\(deltaTime)s: Subject emitted: \(string)")
    }

let subscription2 = throttled
    .sink { string in
        print("+\(deltaTime)s: Throttle emitted: \(string)")
    }                                               

subject.feed(with: typingHelloWorld)
//: [Next](@next)
