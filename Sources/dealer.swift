#if os(OSX) 
    import Foundation
#else 
    import Glibc
#endif

public struct Dealer: SPHCardsDebug {

    public var evaluator: Evaluator

    public var currentDeck: Deck

    public var table: Table

    public var verbose = false

    public init() {
        currentDeck = Deck()
        table = Table()
        evaluator = Evaluator()
        #if os(Linux)
            srandom(UInt32(time(nil)))
        #endif
    }
    
    public init(deck: Deck) {
        currentDeck = deck
        table = Table()
        evaluator = Evaluator()
        #if os(Linux)
            srandom(UInt32(time(nil)))
        #endif
    }
    
    public init(evaluator: Evaluator) {
        currentDeck = Deck()
        table = Table()
        self.evaluator = evaluator
        #if os(Linux)
            srandom(UInt32(time(nil)))
        #endif
    }
    
    public init(deck: Deck, evaluator: Evaluator) {
        currentDeck = deck
        table = Table()
        self.evaluator = evaluator
        #if os(Linux)
            srandom(UInt32(time(nil)))
        #endif
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
                    scores[currentHandWinner!.name!]! += 1
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

    public mutating func removeCards(player: inout Player) {
        player.cards = []
    }

    public mutating func deal(numberOfCards: Int) -> [Card] {
        return currentDeck.takeCards(number: numberOfCards)
    }

    public mutating func dealHoldemHand() -> [Card] {
        return deal(numberOfCards: 2)
    }

    public mutating func dealHoldemHandTo(player: inout Player) {
        player.cards = dealHoldemHand()
    }
    
    public mutating func dealHoldemCards(cards: [String]) -> [Card] {
        let upCardChars = cards.map({$0.uppercased().characters.map({String($0)})})
        var cardsToDeal = [Card]()
        for cardChars in upCardChars {
            let cardObj = Card(suit: cardChars[1], rank: cardChars[0])
            guard let indexToRemove = currentDeck.cards.indexOf(card: cardObj) else {
                print("ERROR: \(cardObj) is not in the deck")
                break
            }
            currentDeck.cards.remove(at: indexToRemove)
            cardsToDeal.append(cardObj)
        }
        return cardsToDeal
    }
    
    public mutating func dealHoldemCardsTo(player: inout Player, cards: [String]) {
        player.cards = dealHoldemCards(cards: cards)
    }
    
    public mutating func dealHoldemCardsTo(player: inout Player, cards: [Card]) {
        var cardsToDeal = [Card]()
        for card in cards {
            guard let indexToRemove = currentDeck.cards.indexOf(card: card) else {
                print("ERROR: \(card) is not in the deck")
                break
            }
            currentDeck.cards.remove(at: indexToRemove)
            cardsToDeal.append(card)
        }
        player.cards = cardsToDeal
    }

    public mutating func dealFlop() -> [Card] {
        table.dealtCards = []
        table.burnt = []
        let dealt = dealWithBurning(numberOfCardsToDeal: 3)
        table.addCards(cards: dealt)
        return dealt
    }

    public mutating func dealTurn() -> [Card] {
        let dealt = dealWithBurning(numberOfCardsToDeal: 1)
        table.addCards(cards: dealt)
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
        table.addToBurntCards(card: burned)
        return deal(numberOfCards: numberOfCardsToDeal)
    }

    public mutating func evaluateHoldemHandAtRiverFor(player: inout Player) {
        player.holdemHand = evaluateHoldemHandAtRiver(player: player)
    }

    public func evaluateHoldemHandAtRiver(player: Player) -> (HandRank, [String]) {
        let sevenCards = table.dealtCards + player.cards
        let cardsReps = sevenCards.map({ $0.description })
        // all 5 cards combinations from the 7 cards
        let perms = cardsReps.permutation(length: 5)
        // TODO: do the permutations with rank/else instead of literal cards descriptions

        let sortedPerms = perms.map { $0.sorted() }
        var uniques: Array<Array<String>> = []
        sortedPerms.forEach { (a) -> () in
            let contains = uniques.contains{ $0 == a }
            if !contains {
                uniques.append(a)
            }
        }

        var handsResult = [(HandRank, [String])]()
        for hand in uniques {
            let h = evaluator.evaluate(cards: hand)
            handsResult.append((h, hand))
        }
        handsResult.sort(isOrderedBefore: { $0.0 < $1.0 })
        let bestHand = handsResult.first
        return bestHand!
    }

    public mutating func updateHeadsUpWinner(player1: Player, player2: Player) {
        currentHandWinner = findHeadsUpWinner(player1: player1, player2: player2)
    }

    public func findHeadsUpWinner(player1: Player, player2: Player) -> Player {
        if player1.holdemHand!.0 < player2.holdemHand!.0 {
            return player1 }
        else if player1.holdemHand!.0 == player2.holdemHand!.0 {
            return Player(name: "SPLIT") }
        else {
            return player2
        }
    }
}
