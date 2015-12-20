import Foundation

public struct Dealer: SPHCardsDebug {

    public var evaluator: Evaluator

    public var currentDeck: Deck

    public var table: Table

    public var verbose = false

    public init() {
        currentDeck = Deck()
        table = Table()
        evaluator = Evaluator()
        srandom(UInt32(time(nil)))
    }
    
    public init(deck: Deck) {
        currentDeck = deck
        table = Table()
        evaluator = Evaluator()
        srandom(UInt32(time(nil)))
    }
    
    public init(evaluator: Evaluator) {
        currentDeck = Deck()
        table = Table()
        self.evaluator = evaluator
        srandom(UInt32(time(nil)))
    }
    
    public init(deck: Deck, evaluator: Evaluator) {
        currentDeck = deck
        table = Table()
        self.evaluator = evaluator
        srandom(UInt32(time(nil)))
    }

    public var currentGame: String { return table.currentGame }

    public var flop: String { return table.flop }

    public var turn: String { return table.turn }

    public var river: String { return table.river }

    public var currentHandWinner: Player? {
        didSet {
            if currentHandWinner != nil {
                if scores[currentHandWinner!.name!] == nil {
                    scores[currentHandWinner!.name!] = 1
                } else {
                    scores[currentHandWinner!.name!]!++
                }
            } else {
                scores = [:]
            }
        }
    }

    public var scores = [String:Int]()

    public mutating func changeDeck() {
        currentDeck = Deck()
    }

    public mutating func shuffleDeck() {
        currentDeck.shuffle()
    }

    public mutating func removeCards(inout player: Player) {
        player.cards = []
    }

    public mutating func deal(numberOfCards: Int) -> [Card] {
        return currentDeck.takeCards(numberOfCards)
    }

    public mutating func dealHoldemHand() -> [Card] {
        return deal(2)
    }

    public mutating func dealHoldemHandTo(inout player: Player) {
        player.cards = dealHoldemHand()
    }
    
    public mutating func dealHoldemCards(cards: [String]) -> [Card] {
        let upCardChars = cards.map({$0.uppercaseString.characters.map({String($0)})})
        var cardsToDeal = [Card]()
        for cardChars in upCardChars {
            let cardObj = Card(suit: cardChars[1], rank: cardChars[0])
            guard let indexToRemove = currentDeck.cards.indexOf(cardObj) else {
                print("ERROR: \(cardObj) is not in the deck")
                break
            }
            currentDeck.cards.removeAtIndex(indexToRemove)
            cardsToDeal.append(cardObj)
        }
        return cardsToDeal
    }
    
    public mutating func dealHoldemCardsTo(inout player: Player, cards: [String]) {
        player.cards = dealHoldemCards(cards)
    }
    
    public mutating func dealHoldemCardsTo(inout player: Player, cards: [Card]) {
        var cardsToDeal = [Card]()
        for card in cards {
            guard let indexToRemove = currentDeck.cards.indexOf(card) else {
                print("ERROR: \(card) is not in the deck")
                break
            }
            currentDeck.cards.removeAtIndex(indexToRemove)
            cardsToDeal.append(card)
        }
        player.cards = cardsToDeal
    }

    public mutating func dealFlop() -> [Card] {
        table.dealtCards = []
        table.burnt = []
        let dealt = dealWithBurning(3)
        table.addCards(dealt)
        return dealt
    }

    public mutating func dealTurn() -> [Card] {
        let dealt = dealWithBurning(1)
        table.addCards(dealt)
        return dealt
    }

    public mutating func dealRiver() -> [Card] {
        return dealTurn()
    }

    private mutating func burn() -> Card? {
        return currentDeck.takeOneCard()
    }

    private mutating func dealWithBurning(numberOfCardsToDeal: Int) -> [Card] {
        guard let burned = burn() else { return errorNotEnoughCards() }
        table.addToBurntCards(burned)
        return deal(numberOfCardsToDeal)
    }

    public mutating func evaluateHoldemHandAtRiverFor(inout player: Player) {
        player.holdemHand = evaluateHoldemHandAtRiver(player)
    }

    public func evaluateHoldemHandAtRiver(player: Player) -> (HandRank, [String]) {
        let sevenCards = table.dealtCards + player.cards
        let cardsReps = sevenCards.map({ $0.description })
        // all 5 cards combinations from the 7 cards
        let perms = cardsReps.permutation(5)
        // TODO: do the permutations with rank/else instead of literal cards descriptions

        let sortedPerms = perms.map { $0.sort() }
        var uniques: Array<Array<String>> = []
        sortedPerms.forEach { (a) -> () in
            let contains = uniques.contains{ $0 == a }
            if !contains {
                uniques.append(a)
            }
        }

        var handsResult = [(HandRank, [String])]()
        for hand in uniques {
            let h = evaluator.evaluate(hand)
            handsResult.append((h, hand))
        }
        handsResult.sortInPlace({ $0.0 < $1.0 })
        let bestHand = handsResult.first
        return bestHand!
    }

    public mutating func updateHeadsUpWinner(player1 player1: Player, player2: Player) {
        currentHandWinner = findHeadsUpWinner(player1: player1, player2: player2)
    }

    public func findHeadsUpWinner(player1 player1: Player, player2: Player) -> Player {
        if player1.holdemHand!.0 < player2.holdemHand!.0 {
            return player1 }
        else if player1.holdemHand!.0 == player2.holdemHand!.0 {
            return Player(name: "SPLIT") }
        else {
            return player2
        }
    }
}
