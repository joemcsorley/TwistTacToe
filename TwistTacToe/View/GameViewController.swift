//
//  GameViewController.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GameViewController: UIViewController {
    private let boardView = TappableBoardView(withFontSize: 64)
    private let rotationMapView = TappableBoardView(withFontSize: 32)
    private let currentPlayerIndicatorLabel = UILabel()
    private let startEndButton = UIButton()
    private let undoButton = UIButton(type: .custom)
    private let redoButton = UIButton(type: .custom)

    private let radioButtonSize: CGFloat = 32
    
    private var game: GameController?
    private(set) var playerX: Player
    private(set) var playerO: Player
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle / Setup Methods
    
    init(playerX: Player, playerO: Player) {
        self.playerX = playerX
        self.playerO = playerO
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
        startNewGame()
    }
    
    private func setup() {
        view.backgroundColor = UIColor("#FFD9AA")
        
        setupBoard()
        setupRotationMap()
        setupCurrentPlayerIndicator()
        setupResumeEndButton()
        setupUndoRedoButtons()
    }
    
    private func setupBoard() {
        view.addSubviewWithAutoLayout(boardView)
        boardView.tapHandler = handleTapped
    }

    private func setupRotationMap() {
        view.addSubviewWithAutoLayout(rotationMapView)
    }

    private func setupCurrentPlayerIndicator() {
        view.addSubviewWithAutoLayout(currentPlayerIndicatorLabel)
        currentPlayerIndicatorLabel.font = UIFont.systemFont(ofSize: 12)
        currentPlayerIndicatorLabel.textColor = UIColor.brown
        currentPlayerIndicatorLabel.backgroundColor = UIColor.clear
    }
    
    private func setupPlayerSelectorButton(_ button: UIButton, handler: Selector) {
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.addTarget(self, action: handler, for: .touchUpInside)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = radioButtonSize / 2
    }
    
    private func setupResumeEndButton() {
        startEndButton.setTitleColor(UIColor.black, for: .normal)
        startEndButton.addTarget(self, action: #selector(handleResumeEndGame), for: .touchUpInside)
        startEndButton.layer.cornerRadius = 4
        updateStartEndButton()
        view.addSubviewWithAutoLayout(startEndButton)
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
            rotationMapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            rotationMapView.widthAnchor.constraint(equalTo: boardView.widthAnchor, multiplier: 0.4),
            
            startEndButton.bottomAnchor.constraint(equalTo: rotationMapView.bottomAnchor),
            startEndButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            startEndButton.trailingAnchor.constraint(equalTo: rotationMapView.leadingAnchor, constant: -15),
            startEndButton.heightAnchor.constraint(equalToConstant: radioButtonSize),

            undoButton.bottomAnchor.constraint(equalTo: view.normalizedLayoutGuide.bottomAnchor, constant: -15),
            undoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            undoButton.heightAnchor.constraint(equalToConstant: 14),

            redoButton.bottomAnchor.constraint(equalTo: view.normalizedLayoutGuide.bottomAnchor, constant: -15),
            redoButton.leadingAnchor.constraint(equalTo: undoButton.trailingAnchor, constant: 15),
            redoButton.heightAnchor.constraint(equalToConstant: 14),
            
            currentPlayerIndicatorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            currentPlayerIndicatorLabel.bottomAnchor.constraint(equalTo: undoButton.topAnchor, constant: -15),
        ])
    }
    
    // MARK: - Button Handlers
    
    @objc
    private func handleResumeEndGame() {
        guard let game = game else { return }
        if game.isGamePaused {
            // Resume a paused game
            if game.gameBoard.gameResult == .unfinished {
                boardView.isEnabled = true
            }
            game.resume()
            updateStartEndButton()
            updateUndoRedoButtons()
        }
        else {
            // End game
            dismiss(animated: true, completion: nil)
        }
    }

    @objc
    private func handleUndo() {
        game?.undo()
    }

    @objc
    private func handleRedo() {
        game?.redo()
    }

    private func handleTapped(_ boardLocation: BoardLocation) {
        game?.handleGameBoardTapped(atLocation: boardLocation)
    }

    // MARK: - Helper Methods
    
    private func startNewGame() {
        boardView.isEnabled = true
        game = newGame(withPlayerX: playerX, playerO: playerO)
        game?.play()
        updateRotationMap()
        updateStartEndButton()
    }
    
    private func newGame(withPlayerX playerX: Player, playerO: Player) -> GameController {
        let game = GameController(playerX: playerX, playerO: playerO)
        
        bindCurrentPlayerIndicatorToGameState(ofGame: game)
        
        // Handle end-of-game, and game error conditions
        game.gameState.subscribe(
            onNext: handleGameOver(gameState:),
            onError: handleGameError(_:),
            onCompleted: nil,
            onDisposed: nil)
        .disposed(by: disposeBag)
        
        game.updatedBoardPublisher.subscribe(onNext: handleChanged(gameBoard:)).disposed(by: disposeBag)
        return game
    }
    
    private func bindCurrentPlayerIndicatorToGameState(ofGame game: GameController) {
        game.gameState.map { (gameState) -> String in
            switch gameState {
            case .xPlaysNext: fallthrough
            case .awaitingXPlay:
                return String(format: currentPlayerText, "X")
            case .oPlaysNext: fallthrough
            case .awaitingOPlay:
                return String(format: currentPlayerText, "O")
            case .boardNeedsRotation:
                return gamePiecesRotateText
            case.gameOver:
                return self.getGameResultText(forWinner: game.gameBoard.gameResult.winningSymbol)
            }
        }.bind(to: currentPlayerIndicatorLabel.rx.text).disposed(by: disposeBag)
    }
    
    private func reset() {
        game = nil
        updateStartEndButton()
        updateUndoRedoButtons()
        boardView.reset()
        rotationMapView.update(boardContent: [])
    }
    
    private func updateRotationMap() {
        guard let rotationPattern = game?.rotationPattern else { return }
        var rotationBoardContent: [String] = []
        for i in boardRange {
            rotationBoardContent.append("\(rotationPattern.numberMap[i] + 1)")
        }
        rotationMapView.update(boardContent: rotationBoardContent)
    }
    
    private func updateStartEndButton() {
        guard let game = game else { return }
        if game.isGamePaused && game.gameStateValue != .gameOver {
            startEndButton.backgroundColor = UIColor.green
            startEndButton.setTitle(resumeGameText, for: .normal)
        }
        else {
            startEndButton.backgroundColor = UIColor.red
            startEndButton.setTitle(endGameText, for: .normal)
        }
    }
    
    private func updateUndoRedoButtons() {
        undoButton.isEnabled = game?.hasUndo ?? false
        redoButton.isEnabled = game?.hasRedo ?? false
    }

    private func getGameResultText(forWinner winner: GamePiece?) -> String {
        guard let winner = winner else { return tieText }
        return winner == .X ? xWinsText : oWinsText
    }

    // MARK: - Game Event Handlers

    private func handleChanged(gameBoard updatedBoard: GameBoard) {
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
    
    private func handleGameOver(gameState: GameState) {
        guard gameState == .gameOver else { return }
        boardView.isEnabled = false
        updateStartEndButton()
        updateUndoRedoButtons()
    }
    
    private func handleGameError(_ error: Error) {
        let errorAlert = UIAlertController(title: errorAlertTitle, message: error.localizedDescription, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: okButtonTitle, style: .default) { action in
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        })
        present(errorAlert, animated: true, completion: nil)
    }
}

// MARK: - Localizable Strings

private let humanIsPlayerXText = NSLocalizedString("You are X", comment: "Human is Player X label text")
private let humanIsPlayerOText = NSLocalizedString("You are O", comment: "Human is Player O label text")
private let currentPlayerText = NSLocalizedString("%@ Plays", comment: "Current Player Indicator text template")
private let gamePiecesRotateText = NSLocalizedString("Pieces move", comment: "Game pieces all rotate text")
private let resumeGameText = NSLocalizedString("Resume Game", comment: "Resume game button text")
private let endGameText = NSLocalizedString("End Game", comment: "End game button text")
private let xWinsText = NSLocalizedString("Player X Wins!", comment: "Player X Wins")
private let oWinsText = NSLocalizedString("Player O Wins!", comment: "Player O Wins")
private let tieText = NSLocalizedString("You Tied.", comment: "You tied")
private let gameErrorText = NSLocalizedString("Game Error", comment: "Game Error")
private let okButtonTitle = NSLocalizedString("Ok", comment: "Ok button title")
private let undoButtonTitle = NSLocalizedString("Undo", comment: "Undo button text")
private let redoButtonTitle = NSLocalizedString("Redo", comment: "Redo button text")
private let errorAlertTitle = NSLocalizedString("A fatal error occurred", comment: "error alert title")

// MARK: - Notifications

struct UINotification {
    static let gameBoardTapped = NSNotification.Name("gameBoardTapped")
}

// MARK: - Notification Keys

struct UINotificationKey {
    static let boardLocation = "boardLocation"
}
