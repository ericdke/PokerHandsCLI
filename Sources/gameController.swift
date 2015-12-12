#if os(OSX)
	import Dispatch
#endif

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

	func startGame(loops: Int) {
		#if os(Linux)
			gameLinux(loops)
		#else
			gameOSX(loops)
		#endif
	}

	func gameLinux(loops: Int) {
		// var (player1, player2): (Player, Player)
		var player1 = Player(name: player1Name)
		var player2 = Player(name: player2Name)
		var dealer = Dealer(deck: Deck(), evaluator: eval)
		for _ in 1...loops { // Can't wait for GCD in Swift.org :(
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

			// TODO: when multithread is implemented, do not use this mutable way anymore
			// Create new dealer and players each loop instead
			// Or implement locks, but... no.
			dealer.changeDeck()
			dealer.removeCards(&player1)
			dealer.removeCards(&player2)
		}

		print("\(player1Name) score: \(player1Score)") 
		print("\(player2Name) score: \(player2Score)\n") 
	}

	func gameOSX(loops: Int) {
		gameLinux(loops)  // Looks like GCD is not implemented yet in Swift.org even on OS X, shadowing for now

		// let q1 = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
		// let q2 = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
		// let deck = Deck()
		// dispatch_async(q1) {
		// 	dispatch_apply(100, q2, { (index) -> Void in
		// 		var dealer = Dealer(deck: deck, evaluator: self.eval)
  //               var (player1, player2) = (Player(name: self.player1Name), Player(name: self.player2Name))

  //               if self.gameMode == .Random {
		// 		    dealer.dealHoldemHandTo(&player1)
		// 		    dealer.dealHoldemHandTo(&player2)
		// 		}
				
		// 		dealer.dealFlop()
		// 		dealer.dealTurn()
		// 		dealer.dealRiver()

		// 		dealer.evaluateHoldemHandAtRiverFor(&player1)
		// 		dealer.evaluateHoldemHandAtRiverFor(&player2)
		// 		dealer.updateHeadsUpWinner(player1: player1, player2: player2)

		// 		self.results.append((dealer, player1, player2))
		// 		self.endOfHand((dealer, player1, player2))

		// 		dispatch_async(dispatch_get_main_queue()) {
		// 			print("\(self.player1Name) cards: \(player1.holeCards)")
		// 			print("\(self.player2Name) cards: \(player2.holeCards)")
		// 			print("Table cards: \(dealer.table.currentGame)")
		// 			guard let winner = dealer.currentHandWinner else {
		// 				print("No winner.")
		// 				fatalError()
		// 			}
		// 			if winner.name != "SPLIT" {
		// 				let winnerName = winner.name ?? "No name."
		// 				let winnerHand = winner.holdemHandDescription ?? "No winner hand description."
		// 				let winnerHandName = winner.holdemHandNameDescription ?? "No winner hand name description."
		// 				print("\nWinner is \(winnerName) with \(winnerHand) (\(winnerHandName))\n")
		// 			} else {
		// 				print("\nHand is split, no winner.\n")
		// 			}
		// 		}
		// 	})
		// }
		// dispatch_async(dispatch_get_main_queue()) {
		// 	print("\(self.player1Name) score: \(self.player1Score)") 
		// 	print("\(self.player2Name) score: \(self.player2Score)\n") 
		// }
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



