public struct Table {

    public var dealtCards = [Card]()

    public var burnt = [Card]()

    public var currentGame: String { return dealtCards.spacedDescriptions }

    public var flop: String {
        guard dealtCards.count > 2 else { return "" }
        return dealtCards[0...2].spacedDescriptions
    }

    public var turn: String {
        guard dealtCards.count > 3 else { return "" }
        return dealtCards[3].description
    }

    public var river: String {
        guard dealtCards.count > 4 else { return "" }
        return dealtCards[4].description
    }

    public mutating func addCards(cards: [Card]) {
        dealtCards += cards
    }

    public mutating func addToBurntCards(card: Card) {
        burnt.append(card)
    }

}

