import Foundation

let start = Date()
let deltaFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.negativePrefix = ""
    f.minimumFractionDigits = 1
    f.maximumFractionDigits = 1
    return f
}()

public var deltaTime: String {
    return deltaFormatter.string(for: Date().timeIntervalSince(start))!
}
