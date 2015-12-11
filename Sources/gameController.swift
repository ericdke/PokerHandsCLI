class GameController {

	enum GameMode {
	    case Random, Custom
	}

	enum PersonType {
	    case Player1, Player2, Dealer
	}

	typealias DealerAndPlayers = (dealer: Dealer, player1: Player, player2: Player)

	var gameMode: GameMode

	var results = [DealerAndPlayers]()

	var player1Name = "John" 

	var player2Name = "Jane" 

	var player1Score = 0
	
	var player2Score = 0

	private let eval = Evaluator()

	init(mode: GameMode = .Random) {
		self.gameMode = mode
	}

	init(player1Name: String, player2Name: String, mode: GameMode = .Random) {
		self.player1Name = player1Name
		self.player2Name = player2Name
		self.gameMode = mode
	}

	func startGame() {
		var (player1, player2): (Player, Player)
		for _ in 1...100 { // Can't wait for GCD in Linux... :(
			var dealer = Dealer(deck: Deck(), evaluator: eval)
			(player1, player2) = (Player(name: player1Name), Player(name: player2Name))

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

			guard let winner = dealer.currentHandWinner else {
				print("No winner.")
				fatalError()
			}

			if winner.name != "SPLIT" {
				let winnerName = winner.name ?? "No name."
				let winnerHand = winner.holdemHandDescription ?? "No winner hand description."
				let winnerHandName = winner.holdemHandNameDescription ?? "No winner hand name description."
				print("\nWinner is \(winnerName) with \(winnerHand) (\(winnerHandName))\n")
			} else {
				print("\nHand is split, no winner.\n")
			}

			results.append((dealer, player1, player2))
			endOfHand((dealer, player1, player2))
		}

		print("\(player1Name) score: \(player1Score)") 
		print("\(player2Name) score: \(player2Score)\n") 
	}


	private func endOfHand(people: DealerAndPlayers) {
	    for (name, value) in people.dealer.scores {
	        if name == player1Name {
	            player1Score += value
	        } else if name == player2Name {
	            player2Score += value
	        }
	    }
	}

	
}



