import Foundation

enum Errors: ErrorType {
	case NoCommand
	case InvalidCommand
	case NoArguments
	case InvalidArguments
	case UnknownError
}

enum Warnings: String {
	case Help = "\nLaunches a series of all-in Holdem Heads Up games.\n\nUSAGE:\n\n-n NUMBER\tNumber of games\n"
}

class CLI {

	var game = GameController() // GameController(player1Name: input[0], player2Name: input[1])
	var sourceFile: String?
	var command: String?
	var input: [String] = []

	init() {
		var args = Process.arguments
		self.sourceFile = args[0]
		if args.count > 1 {
			self.command = args[1]
		} else {
			help()
		}
		if args.count > 2 {
			self.input = args[2..<args.count].map { String($0) }
		}
	}

	func startGame() throws {
		guard sourceFile != nil else {
			throw Errors.UnknownError
		}
		// WIP
		if let c = command {
			switch c {
			case "-n":
				if input.isEmpty {
					help()
				}
				guard let num = Int(input[0]) else {
					throw Errors.InvalidArguments
				}
				game.loops = num
			case "-h", "--help":
				help()
			default:
				throw Errors.InvalidCommand
			}
		}
		print("\n\nLaunching \(game.loops) all-in hands.\n\n")
		game.startGame()
		let winner:String
		if game.player1Score > game.player2Score {
			winner = game.player1Name
		} else {
			winner = game.player2Name
		}
		print("\nGame winner is: \(winner)!\n\n")
	}

	private func help() {
		print(Warnings.Help.rawValue)
		exit(0)
	}
	
}