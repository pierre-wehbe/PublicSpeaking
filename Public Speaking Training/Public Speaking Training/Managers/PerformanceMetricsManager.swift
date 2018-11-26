import Foundation

class Range {
    let lowerBound: Int!
    let upperBound: Int!
    
    init(lower: Int, upper: Int) {
        lowerBound = lower
        upperBound = upper
    }
    
    func isInRange(number: Int) -> Bool {
        return number >= lowerBound && number <= upperBound
    }
}

class PerformanceMetricsManager {
    // Standards
    static let WORDS_FREQ_AVERAGE = Range(lower: 125, upper: 150)
    
    
}
