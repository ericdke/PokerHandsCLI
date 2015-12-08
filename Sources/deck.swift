public struct Deck: CanTakeCard, SPHCardsDebug {

    public let suits = ["♠","♣","♥","♦"]
    public let ranks = ["A","K","Q","J","T","9","8","7","6","5","4","3","2"]

    public var cards = [Card]()

    private let capacity = 52

    public init() {
        for thisSuit in suits {
            for thisRank in ranks {
                cards.append(Card(suit: thisSuit, rank: thisRank))
            }
        }
    }

    public mutating func shuffle() {
        cards.shuffleInPlace()
    }
    
    public mutating func takeCards(number:Int) -> [Card] {
        guard self.count >= number else {
            return errorNotEnoughCards()
        }
        var c = [Card]()
        number.times {
            c.append(self.cards.takeOne())
        }
        return c
    }

    public var count: Int { get { return cards.count } }

    public var dealt: Int { get { return capacity - cards.count } }
}
