import Foundation

final public class CardsDeck {
    
    public var cards:[String:Int]
    
    public var count: Int { return cards.count }
    
    public init() {
        cards = [:]
        let suitDetails:[String: Int] = [
            "♠": 0b0001,
            "♥": 0b0010,
            "♦": 0b0100,
            "♣": 0b1000
        ]
        let faces:[String:[String:Int]] = [
            "2":["index":0, "prime": 2],
            "3":["index":1, "prime": 3],
            "4":["index":2, "prime": 5],
            "5":["index":3, "prime": 7],
            "6":["index":4, "prime": 11],
            "7":["index":5, "prime": 13],
            "8":["index":6, "prime": 17],
            "9":["index":7, "prime": 19],
            "T":["index":8, "prime": 23],
            "J":["index":9, "prime": 29],
            "Q":["index":10, "prime": 31],
            "K":["index":11, "prime": 37],
            "A":["index":12, "prime": 41]
        ]
        for face in faces.keys {
            for suit in suitDetails.keys {
                let faceIndex = faces[face]!["index"]!
                let faceValue = faceIndex << 8
                let suitValue = suitDetails[suit]! << 12
                let facePrime = faces[face]!["prime"]!
                let rank = 1 << (faceIndex + 16)
                cards[face+suit] = rank | suitValue | faceValue | facePrime
            }
        }
    }

    public func as_binary(card: String) -> Int {
        return cards[card]!
    }
}

public enum RankName : String {
    case HighCard = "High Card"
    case OnePair = "One Pair"
    case TwoPairs = "Two Pairs"
    case ThreeOfAKind = "Three Of A Kind"
    case Straight = "A Straight"
    case Flush = "A Flush"
    case FullHouse = "A Full House"
    case FourOfAKind = "Four Of A Kind"
    case StraightFlush = "A Straight Flush"
}

private var rankStarts:[Int:RankName] = [
    7462: RankName.HighCard,
    6185: RankName.OnePair,
    3325: RankName.TwoPairs,
    2467: RankName.ThreeOfAKind,
    1609: RankName.Straight,
    1599: RankName.Flush,
    322: RankName.FullHouse,
    166: RankName.FourOfAKind,
    10: RankName.StraightFlush
]

final public class HandRank: Equatable {
    let rank:Int
    let name:RankName
    init(rank:Int) {
        self.rank = rank
        let start = Array(rankStarts.keys.filter {$0 >= rank}).sorted { $0 < $1 }.first!
        self.name = rankStarts[start]!
    }
}

public func == (lhs: HandRank, rhs: HandRank) -> Bool {
    return lhs.rank == rhs.rank
}

public func < (lhs: HandRank, rhs: HandRank) -> Bool {
    return lhs.rank < rhs.rank
}

final public class Evaluator {
    
    public let deck = CardsDeck()
    
    public func evaluate(cards: [String]) -> HandRank {
        let cardValues = cards.map { self.deck.as_binary(card: $0) }

        let handIndex = cardValues.reduce(0,combine:|) >> 16

        let isFlush:Bool = (cardValues.reduce(0xF000,combine:&)) != 0

        if isFlush {
            let flushRank = flushes[handIndex]
            return HandRank(rank:flushRank)
        }

        let unique5Candidate = uniqueToRanks[handIndex]

        if unique5Candidate != 0 {
            return HandRank(rank:unique5Candidate)
        }

        let primeProduct = cardValues.map { $0 & 0xFF }.reduce(1, combine:*)

        let combination = primeProductToCombination.index(of: primeProduct)!
        return HandRank(rank: combinationToRank[combination])
    }
}
