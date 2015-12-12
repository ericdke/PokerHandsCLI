enum Errors: ErrorType {
	case NoCommand
	case InvalidCommand
	case NoArguments
	case InvalidArguments
}

class CLI {

	var game: GameController?
	var sourceFile: String?
	var command: String?
	var input: [String] = []

	init() {
		var args = Process.arguments
		self.sourceFile = args[0]
		if args.count > 1 {
			self.command = args[1]
		}
		if args.count > 2 {
			self.input = args[2..<args.count].map { String($0) }
		}
	}

	func startGame(loops: Int = 100) throws {
		// TODO: display Help instead
		guard sourceFile != nil else {
			fatalError()
		}
		if let c = command {
			if c == "-n" {
				guard !input.isEmpty else {
					throw Errors.NoArguments
				}
				guard input.count > 1 else {
					throw Errors.InvalidArguments
				}
				game = GameController(player1Name: input[0], player2Name: input[1])
			} else {
				throw Errors.InvalidCommand
			}
		} else {
			game = GameController()
		}
		game!.startGame(loops)
	}

	
}