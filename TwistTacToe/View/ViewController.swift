//
//  ViewController.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private let boardView = TappableBoardView(withFontSize: 64)
    private let rotationMapView = TappableBoardView(withFontSize: 32)
    private let humanIsPlayerXButton = UIButton()
    private let humanIsPlayerXLabel = UILabel()
    private let humanIsPlayerOButton = UIButton()
    private let humanIsPlayerOLabel = UILabel()
    private let startEndButton = UIButton()
    private let howToPlayButton = UIButton(type: .custom)
    private let undoButton = UIButton(type: .custom)
    private let redoButton = UIButton(type: .custom)

    private let radioButtonSize: CGFloat = 32
    
    private var isHumanPlayerX = true
    private var game: GameController?
    private var gameResultText: String?
    
    // MARK: - Lifecycle / Setup Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor("#FFD9AA")
        
        setupBoard()
        setupRotationMap()
        setupHumanIsPlayerButtons()
        setupStartEndButton()
        setupHowToPlayButton()
        setupUndoRedoButtons()
        layout()
        setupObservers()
    }
    
    private func setupBoard() {
        view.addSubviewWithAutoLayout(boardView)
        boardView.tapHandler = handleTapped
    }

    private func setupRotationMap() {
        view.addSubviewWithAutoLayout(rotationMapView)
    }

    private func setupHumanIsPlayerButtons() {
        view.addSubviewWithAutoLayout(humanIsPlayerXButton)
        view.addSubviewWithAutoLayout(humanIsPlayerXLabel)
        view.addSubviewWithAutoLayout(humanIsPlayerOButton)
        view.addSubviewWithAutoLayout(humanIsPlayerOLabel)

        humanIsPlayerXLabel.text = humanIsPlayerXText
        humanIsPlayerOLabel.text = humanIsPlayerOText
        
        setupPlayerSelectorButton(humanIsPlayerXButton, handler: #selector(handleHumanIsPlayerX))
        setupPlayerSelectorButton(humanIsPlayerOButton, handler: #selector(handleHumanIsPlayerO))
        updatePlayerOrderButtons()
    }

    private func setupPlayerSelectorButton(_ button: UIButton, handler: Selector) {
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.addTarget(self, action: handler, for: .touchUpInside)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = radioButtonSize / 2
    }
    
    private func setupStartEndButton() {
        startEndButton.setTitleColor(UIColor.black, for: .normal)
        startEndButton.addTarget(self, action: #selector(handleStartEndGame), for: .touchUpInside)
        startEndButton.layer.cornerRadius = 4
        updateStartEndButton()
        view.addSubviewWithAutoLayout(startEndButton)
    }

    private func setupHowToPlayButton() {
        howToPlayButton.setTitle(howToPlayButtonTitle, for: .normal)
        howToPlayButton.setTitleColor(UIColor.brown, for: .normal)
        howToPlayButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        howToPlayButton.addTarget(self, action: #selector(handleHowToPlay), for: .touchUpInside)
        view.addSubviewWithAutoLayout(howToPlayButton)
    }

    private func setupUndoRedoButtons() {
        undoButton.setTitle(undoButtonTitle, for: .normal)
        undoButton.setTitleColor(UIColor.brown, for: .normal)
        undoButton.setTitleColor(UIColor("#FEAF7B"), for: .disabled)
        undoButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        undoButton.addTarget(self, action: #selector(handleUndo), for: .touchUpInside)
        undoButton.isEnabled = false
        view.addSubviewWithAutoLayout(undoButton)

        redoButton.setTitle(redoButtonTitle, for: .normal)
        redoButton.setTitleColor(UIColor.brown, for: .normal)
        redoButton.setTitleColor(UIColor("#FEAF7B"), for: .disabled)
        redoButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        redoButton.addTarget(self, action: #selector(handleRedo), for: .touchUpInside)
        redoButton.isEnabled = false
        view.addSubviewWithAutoLayout(redoButton)
    }
    
    private func layout() {
        NSLayoutConstraint.activate([
            boardView.topAnchor.constraint(equalTo: view.normalizedLayoutGuide.topAnchor, constant: 15),
            boardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            boardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            rotationMapView.topAnchor.constraint(equalTo: boardView.bottomAnchor, constant: 30),
            rotationMapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            rotationMapView.widthAnchor.constraint(equalTo: boardView.widthAnchor, multiplier: 0.4),
            
            // Human is player 1 row
            humanIsPlayerXButton.topAnchor.constraint(equalTo: boardView.bottomAnchor, constant: 30),
            humanIsPlayerXButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            humanIsPlayerXButton.widthAnchor.constraint(equalToConstant: radioButtonSize),
            humanIsPlayerXButton.heightAnchor.constraint(equalTo: humanIsPlayerXButton.widthAnchor),
            humanIsPlayerXLabel.leadingAnchor.constraint(equalTo: humanIsPlayerXButton.trailingAnchor, constant: 8),
            humanIsPlayerXLabel.trailingAnchor.constraint(equalTo: rotationMapView.leadingAnchor, constant: -15),
            humanIsPlayerXLabel.centerYAnchor.constraint(equalTo: humanIsPlayerXButton.centerYAnchor),
            
            // Human is player 2 row
            humanIsPlayerOButton.topAnchor.constraint(equalTo: humanIsPlayerXButton.bottomAnchor, constant: 15),
            humanIsPlayerOButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            humanIsPlayerOButton.widthAnchor.constraint(equalToConstant: radioButtonSize),
            humanIsPlayerOButton.heightAnchor.constraint(equalTo: humanIsPlayerXButton.widthAnchor),
            humanIsPlayerOLabel.leadingAnchor.constraint(equalTo: humanIsPlayerOButton.trailingAnchor, constant: 8),
            humanIsPlayerOLabel.trailingAnchor.constraint(equalTo: rotationMapView.leadingAnchor, constant: -15),
            humanIsPlayerOLabel.centerYAnchor.constraint(equalTo: humanIsPlayerOButton.centerYAnchor),

            startEndButton.topAnchor.constraint(equalTo: humanIsPlayerOLabel.bottomAnchor, constant: 30),
            startEndButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            startEndButton.trailingAnchor.constraint(equalTo: rotationMapView.leadingAnchor, constant: -15),
            startEndButton.heightAnchor.constraint(equalToConstant: radioButtonSize),

            howToPlayButton.bottomAnchor.constraint(equalTo: view.normalizedLayoutGuide.bottomAnchor, constant: -15),
            howToPlayButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            howToPlayButton.heightAnchor.constraint(equalToConstant: 14),
            
            undoButton.bottomAnchor.constraint(equalTo: view.normalizedLayoutGuide.bottomAnchor, constant: -15),
            undoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            undoButton.heightAnchor.constraint(equalToConstant: 14),

            redoButton.bottomAnchor.constraint(equalTo: view.normalizedLayoutGuide.bottomAnchor, constant: -15),
            redoButton.leadingAnchor.constraint(equalTo: undoButton.trailingAnchor, constant: 15),
            redoButton.heightAnchor.constraint(equalToConstant: 14),
        ])
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleBoardHasBeenUpdated), name: GameNotification.boardHasBeenUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleGameOver), name: GameNotification.gameOver, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleGameError), name: GameNotification.gameError, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Button Handlers
    
    @objc
    private func handleHumanIsPlayerX() {
        isHumanPlayerX = true
        updatePlayerOrderButtons()
    }

    @objc
    private func handleHumanIsPlayerO() {
        isHumanPlayerX = false
        updatePlayerOrderButtons()
    }

    @objc
    private func handleStartEndGame() {
        if let game = game {
            if game.isGamePaused {
                // Resume a paused game
                if game.gameBoard.gameResult == .unfinished {
                    gameResultText = nil
                    boardView.isEnabled = true
                }
                game.resume()
                updateStartEndButton()
                updateUndoRedoButtons()
            }
            else {
                reset()
            }
            return
        }
        
        boardView.isEnabled = true
        setPlayerButtons(enabled: false)
        let playerX: Player = isHumanPlayerX ? HumanPlayer(symbol: .X) : AutomatedRandomPlayer(symbol: .X)
        let playerO: Player = isHumanPlayerX ? AutomatedRandomPlayer(symbol: .O) : HumanPlayer(symbol: .O)
//        let playerX: Player = HumanPlayer(symbol: .X)
//        let playerO: Player = HumanPlayer(symbol: .O)
        gameResultText = nil
        game = GameController(playerX: playerX, playerO: playerO)
        game?.play()
        updateRotationMap()
        updateStartEndButton()
    }

    @objc
    private func handleHowToPlay() {
        print("Explain how to play the game here")
    }

    @objc
    private func handleUndo() {
        NotificationCenter.default.post(name: UINotification.undoTapped, object: self, userInfo: nil)
    }

    @objc
    private func handleRedo() {
        NotificationCenter.default.post(name: UINotification.redoTapped, object: self, userInfo: nil)
    }

    private func handleTapped(_ boardLocation: BoardLocation) {
        NotificationCenter.default.post(name: UINotification.gameBoardTapped, object: self,
                                        userInfo: [UINotificationKey.boardLocation: boardLocation])
    }

    // MARK: - Helper Methods
    
    private func reset() {
        game = nil
        updateStartEndButton()
        updateUndoRedoButtons()
        setPlayerButtons(enabled: true)
        boardView.reset()
        rotationMapView.update(boardContent: [])
    }
    
    private func setPlayerButtons(enabled isEnabled: Bool) {
        humanIsPlayerXButton.isEnabled = isEnabled
        humanIsPlayerOButton.isEnabled = isEnabled
        humanIsPlayerXButton.setTitleColor((isEnabled ? UIColor.black : UIColor.lightGray), for: .normal)
        humanIsPlayerOButton.setTitleColor((isEnabled ? UIColor.black : UIColor.lightGray), for: .normal)
    }

    private func updateRotationMap() {
        guard let rotationPattern = game?.rotationPattern else { return }
        var rotationBoardContent: [String] = []
        for i in boardRange {
            rotationBoardContent.append("\(rotationPattern.numberMap[i] + 1)")
        }
        rotationMapView.update(boardContent: rotationBoardContent)
    }
    
    private func updatePlayerOrderButtons() {
        if isHumanPlayerX {
            humanIsPlayerXButton.setTitle("✓", for: .normal)
            humanIsPlayerOButton.setTitle("", for: .normal)
        }
        else {
            humanIsPlayerXButton.setTitle("", for: .normal)
            humanIsPlayerOButton.setTitle("✓", for: .normal)
        }
    }

    private func updateStartEndButton() {
        if let _ = game {
            if game?.isGamePaused ?? false {
                startEndButton.backgroundColor = UIColor.green
                startEndButton.setTitle(resumeGameText, for: .normal)
            }
            else if let gameResultText = gameResultText {
                startEndButton.backgroundColor = UIColor.yellow
                startEndButton.setTitle(gameResultText, for: .normal)
            }
            else {
                startEndButton.backgroundColor = UIColor.red
                startEndButton.setTitle(endGameText, for: .normal)
            }
        }
        else {
            startEndButton.backgroundColor = UIColor.green
            startEndButton.setTitle(startGameText, for: .normal)
        }
    }
    
    private func updateUndoRedoButtons() {
        undoButton.isEnabled = game?.hasUndo ?? false
        redoButton.isEnabled = game?.hasRedo ?? false
    }

    private func getGameResultText(forWinner winner: GamePiece?) -> String {
        guard let winner = winner else { return youTiedText }
        
        var gameResultText: String
        if isHumanPlayerX {
            gameResultText = (winner == .X ? youWonText : youLostText)
        }
        else {
            gameResultText = (winner == .O ? youWonText : youLostText)
        }
        return gameResultText
    }

    // MARK: - Notification Handlers

    @objc
    private func handleBoardHasBeenUpdated(_ notification: NSNotification) {
        guard let updatedBoard = notification.userInfo?[GameNotificationKey.updatedBoard] as? GameBoard else { return }
        do {
            let boardContent = try boardRange.map { boardLocation -> String in
                guard let symbol = try updatedBoard.gamePiece(atLocation: boardLocation) else { return "" }
                return symbol.rawValue
            }
            boardView.update(boardContent: boardContent)
            updateStartEndButton()
            updateUndoRedoButtons()
        } catch {}
    }

    // Signal the game end and display the result to the user, then reset the game
    @objc
    private func handleGameOver(_ notification: NSNotification) {
        guard let gameResult = notification.userInfo?[GameNotificationKey.gameResult] as? GameResult else { return }
        gameResultText = getGameResultText(forWinner: gameResult.winningSymbol)
        boardView.isEnabled = false
        updateStartEndButton()
        updateUndoRedoButtons()
    }

    @objc
    private func handleGameError(_ notification: NSNotification) {
        guard let error = notification.userInfo?[GameNotificationKey.error] as? Error else { return }
        print("Error: Something went wrong during game play: \(error).")
        gameResultText = gameErrorText
        boardView.isEnabled = false
        updateStartEndButton()
        updateUndoRedoButtons()
    }
}

// MARK: - Localizable Strings

private let humanIsPlayerXText = NSLocalizedString("You are X", comment: "Human is Player X label text")
private let humanIsPlayerOText = NSLocalizedString("You are O", comment: "Human is Player O label text")
private let startGameText = NSLocalizedString("Start Game", comment: "Start game button text")
private let resumeGameText = NSLocalizedString("Resume Game", comment: "Resume game button text")
private let endGameText = NSLocalizedString("End Game", comment: "End game button text")
private let gameOverText = NSLocalizedString("Game Over", comment: "Game Over")
private let youWonText = NSLocalizedString("You Won!", comment: "You Won")
private let youLostText = NSLocalizedString("You Lost.", comment: "You Lost")
private let youTiedText = NSLocalizedString("You Tied.", comment: "You tied")
private let gameErrorText = NSLocalizedString("Game Error", comment: "Game Error")
private let okButtonTitle = NSLocalizedString("Ok", comment: "Ok button text")
private let howToPlayButtonTitle = NSLocalizedString("How to Play", comment: "How to Play button text")
private let undoButtonTitle = NSLocalizedString("Undo", comment: "Undo button text")
private let redoButtonTitle = NSLocalizedString("Redo", comment: "Redo button text")

// MARK: - Notifications

struct UINotification {
    static let gameBoardTapped = NSNotification.Name("gameBoardTapped")
    static let undoTapped = NSNotification.Name("undoTapped")
    static let redoTapped = NSNotification.Name("redoTapped")
}

// MARK: - Notification Keys

struct UINotificationKey {
    static let boardLocation = "boardLocation"
}
