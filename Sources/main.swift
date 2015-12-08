enum GameMode {
    case Random, Custom
}

enum PersonType {
    case Player1, Player2, Dealer
}

typealias DealerAndPlayers = (dealer: Dealer, player1: Player, player2: Player)

let gameMode:GameMode = .Random

var results = [DealerAndPlayers]()

let name1 = "John"
let name2 = "Jane"

let eval = Evaluator()
let deck = Deck()

var player1Score = 0
var player2Score = 0

func endOfHand(people: DealerAndPlayers) {
    for (name, value) in people.dealer.scores {
        if name == name1 {
            player1Score += value
        } else if name == name2 {
            player2Score += value
        }
    }
}

print("")

var (player1, player2) = (Player(name: name1), Player(name: name2)) // just because print, will remove
guard let player1Name = player1.name, player2Name = player2.name else {
	fatalError()
}

for _ in 1...10 { // Can't wait for GCD... :(
	var dealer = Dealer(deck: deck, evaluator: eval)
	(player1, player2) = (Player(name: name1), Player(name: name2))

	if gameMode == .Random {
	    dealer.dealHoldemHandTo(&player1)
	    dealer.dealHoldemHandTo(&player2)
	}

	print("\(player1Name) cards: \(player1.holeCards)")
	print("\(player2Name) cards: \(player2.holeCards)")
	
	dealer.dealFlop()
	dealer.dealTurn()
	dealer.dealRiver()

	print("Table cards: \(dealer.table.currentGame)")

	dealer.evaluateHoldemHandAtRiverFor(&player1)
	dealer.evaluateHoldemHandAtRiverFor(&player2)
	dealer.updateHeadsUpWinner(player1: player1, player2: player2)

	guard let winner = dealer.currentHandWinner, 
		winnerName = winner.name, 
		winnerHand = winner.holdemHandDescription, 
		winnerHandName = winner.holdemHandNameDescription 
		else {
		fatalError()
	}

	print("\nWinner is \(winnerName) with \(winnerHand) (\(winnerHandName))\n")

	results.append((dealer, player1, player2))
	endOfHand((dealer, player1, player2))
}

print("\(player1Name) score: \(player1Score)") 
print("\(player2Name) score: \(player2Score)\n") 
