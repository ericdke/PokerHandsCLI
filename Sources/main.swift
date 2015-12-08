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


for _ in 1...10 { // Can't wait for GCD... :(
	var dealer = Dealer(deck: deck, evaluator: eval)
	var (player1, player2) = (Player(name: name1), Player(name: name2))

	if gameMode == .Random {
	    dealer.dealHoldemHandTo(&player1)
	    dealer.dealHoldemHandTo(&player2)
	}

	
	
	dealer.dealFlop()
	dealer.dealTurn()
	dealer.dealRiver()
	dealer.evaluateHoldemHandAtRiverFor(&player1)
	dealer.evaluateHoldemHandAtRiverFor(&player2)
	dealer.updateHeadsUpWinner(player1: player1, player2: player2)

	results.append((dealer, player1, player2))
	endOfHand((dealer, player1, player2))
}

print("Player 1 score: \(player1Score)") 
print("Player 2 score: \(player2Score)") 
