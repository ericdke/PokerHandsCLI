import Foundation

public struct Player: CanTakeCard {

    public init() {}

    public init(name: String) {
        self.name = name
    }

    public var name: String?

    public typealias DealtHand = (Card, Card, NSDate)

    public var historyOfDealtHoldemCards = [DealtHand]()
    
    public var frequentHands = [String:Int]()

    public var holdemHand: HandResult?
    
    public var holdemHandDescription: String? {
        return holdemHand?.1.joined(separator: " ")
    }
    
    public var holdemHandNameDescription: String? {
        return holdemHand?.0.name.rawValue.lowercased()
    }

    public var cardsHistory: String {
        let mapped = historyOfDealtHoldemCards.map { $0.0.description + " " + $0.1.description }
        return mapped.joined(separator: ", ")
    }

    public var cards = [Card]() {
        didSet {
            if self.cards.count > 1 {
                let hand: DealtHand = (self.cards[0], self.cards[1], NSDate())
                historyOfDealtHoldemCards.append(hand)
                let fqname = "\(hand.0.description),\(hand.1.description)"
                if frequentHands[fqname] == nil {
                    frequentHands[fqname] = 1
                } else {
                    frequentHands[fqname]! += 1
                }
            }
        }
    }

    public var cardsNames: String { return cards.joinNames(with: ", ") }

    public var count: Int { return cards.count }

    public var holeCards: String { return cards.spacedDescriptions }
    
    public var lastDealtHandReadableDate: String? {
        guard let date = historyOfDealtHoldemCards.last?.2 else { return nil }
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss:SSS"
        return formatter.string(from: date)
    }
    
    public var lastDealtHandDate: NSDate? {
        return historyOfDealtHoldemCards.last?.2
    }
}
