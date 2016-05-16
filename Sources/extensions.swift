#if os(Linux) 
    import Glibc
#else 
    import Foundation
#endif

// TODO: find a way to generate a GOOD random number without killing the CPU
// This function is very *pseudo* random. Bleh.
func getPseudoRandomNumber(max:Int) -> Int {
    return Int(random() % max)
}

public func ==(lhs: Card, rhs: Card) -> Bool {
    if lhs.rank == rhs.rank && lhs.suit == rhs.suit {
        return true
    }
    return false
}

public extension MutableCollection where Index == Int {
    
    public mutating func shuffleInPlace() {
        if count < 2 { return }
        for i in 0..<count - 1 {
            let j:Int
            #if os(Linux) 
                j = getPseudoRandomNumber(count - i) + i
            #else
                j = Int(arc4random_uniform(UInt32(count - i))) + i
            #endif
            if i != j {
                swap(&self[i], &self[j])
            }
        }
    }
    
}

public protocol CanTakeCard {
    
    var cards: [Card] { get set }
    mutating func takeOneCard() -> Card?
    
}

public extension CanTakeCard {
    
    public mutating func takeOneCard() -> Card? {
        guard cards.count > 0 else { return nil }
        return cards.takeOne()
    }
    
}

public protocol SPHCardsDebug {
    
    func errorNotEnoughCards() -> [Card]
    func error(message: String)
    
}

public extension SPHCardsDebug {
    
    public func errorNotEnoughCards() -> [Card] {
        error("not enough cards")
        return []
    }
    
    public func error(message: String) {
        print("ERROR: \(message)")
    }
    
}

public extension Sequence where Generator.Element == Card {
    
    public var descriptions: [String] {
        return self.map { $0.description }
    }
    
    public var spacedDescriptions: String {
        return self.descriptions.joinWithSeparator(" ")
    }
    
    public func indexOf(card: Card) -> Int? {
        for (index, deckCard) in self.enumerate() {
            if deckCard == card {
                return index
            }
        }
        return nil
    }
    
    public func joinNames(with string: String) -> String {
        return self.map({ $0.name }).joinWithSeparator(string)
    }
    
}

public extension Range {
    
    public var array: [Element] {
        return self.map { $0 }
    }
    
}

public extension Int {
    
    public func times(f: () -> ()) {
        if self > 0 {
            for _ in 0..<self {
                f()
            }
        }
    }
    
    public func times(@autoclosure f: () -> ()) {
        if self > 0 {
            for _ in 0..<self {
                f()
            }
        }
    }
    
}

public extension Array {
    
    public mutating func takeOne() -> Element {
        let index:Int
        #if os(Linux) 
            // TODO: find a better way
            index = getPseudoRandomNumber(self.count)
        #else
            index = Int(arc4random_uniform(UInt32(self.count)))
        #endif
        let item = self[index]
        self.removeAtIndex(index)
        return item
    }
    
    // adapted from ExSwift
    public func permutation(length: Int) -> [[Element]] {
        if length < 0 || length > self.count {
            return []
        } else if length == 0 {
            return [[]]
        } else {
            var permutations: [[Element]] = []
            let combinations = combination(length)
            for combination in combinations {
                var endArray: [[Element]] = []
                var mutableCombination = combination
                permutations += self.permutationHelper(length, array: &mutableCombination, endArray: &endArray)
            }
            return permutations
        }
    }
    // adapted from ExSwift
    private func permutationHelper(n: Int, array: inout [Element], endArray: inout [[Element]]) -> [[Element]] {
        if n == 1 {
            endArray += [array]
        }
        for var i = 0; i < n; i++ {
            permutationHelper(n - 1, array: &array, endArray: &endArray)
            let j = n % 2 == 0 ? i : 0;
            let temp: Element = array[j]
            array[j] = array[n - 1]
            array[n - 1] = temp
        }
        return endArray
    }
    // adapted from ExSwift
    public func combination(length: Int) -> [[Element]] {
        if length < 0 || length > self.count {
            return []
        }
        var indexes: [Int] = (0..<length).array
        var combinations: [[Element]] = []
        let offset = self.count - indexes.count
        while true {
            var combination: [Element] = []
            for index in indexes {
                combination.append(self[index])
            }
            combinations.append(combination)
            var i = indexes.count - 1
            while i >= 0 && indexes[i] == i + offset {
                i--
            }
            if i < 0 {
                break
            }
            i++
            let start = indexes[i-1] + 1
            for j in (i-1)..<indexes.count {
                indexes[j] = start + j - i + 1
            }
        }
        return combinations
    }

}
