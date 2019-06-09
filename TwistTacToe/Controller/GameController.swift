//
//  Game.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import Foundation

typealias TurnCompletionHandler = (GameBoard) throws -> Void

class GameController {
    private let playerX: Player
    private let playerO: Player
    private(set) var currentPlayer: Player?
    let rotationPattern: RotationPattern
    private(set) lazy var gameBoard = initialGameBoard()
    private var gameState: GameState = .xPlaysNext
    private(set) var isGamePaused = false
    
    // Dependency injection for testing
    var initialGameBoard: () -> GameBoard = {
        return GameBoard()
    }

    // MARK: - Init / Setup
    
    init(playerX: Player, playerO: Player, rotationPattern: RotationPattern = RotationPattern()) {
        self.rotationPattern = rotationPattern
        self.playerX = playerX
        self.playerO = playerO
        setupObservers()
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerHasPlayed), name: PlayerNotification.playerHasPlayed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerError), name: PlayerNotification.playerError, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public interface methods

    func play() {
        advanceGameState()
    }
    
    // MARK: - State Machine

    private func advanceGameState() {
        guard !isGamePaused else { return }
        switch gameState {
        case .xPlaysNext:
            handleXPlaysNextState()
        case .awaitingXPlay:
            handleAwaitingXPlay()
        case .oPlaysNext:
            handleOPlaysNextState()
        case .awaitingOPlay:
            handleAwaitingOPlay()
        case .boardNeedsRotation:
            handleBoardNeedsRotation()
        default:
            break
        }
    }
    
    private func handleXPlaysNextState() {
        currentPlayer = playerX
        playerX.takeTurn(onBoard: gameBoard, rotationPattern: rotationPattern)
        gameState = .awaitingXPlay
    }

    private func handleOPlaysNextState() {
        currentPlayer = playerO
        playerO.takeTurn(onBoard: gameBoard, rotationPattern: rotationPattern)
        gameState = .awaitingOPlay
    }

    private func handleAwaitingXPlay() {
        NotificationCenter.default.post(name: GameNotification.boardHasBeenUpdated, object: self,
                                        userInfo: [GameNotificationKey.updatedBoard: gameBoard])
        gameState = .oPlaysNext
        advanceGameState()
    }

    private func handleAwaitingOPlay() {
        NotificationCenter.default.post(name: GameNotification.boardHasBeenUpdated, object: self,
                                        userInfo: [GameNotificationKey.updatedBoard: gameBoard])
        gameState = .boardNeedsRotation
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.future(seconds: 0.4)) {
            self.advanceGameState()
        }
    }

    private func handleBoardNeedsRotation() {
        gameBoard = gameBoard.newByRotating(usingPattern: rotationPattern)
        NotificationCenter.default.post(name: GameNotification.boardHasBeenUpdated, object: self,
                                        userInfo: [GameNotificationKey.updatedBoard: gameBoard])
        if gameBoard.gameResult == .unfinished {
            gameState = .xPlaysNext
            advanceGameState()
        }
        else {
            NotificationCenter.default.post(name: GameNotification.gameOver, object: self,
                                            userInfo: [GameNotificationKey.gameResult: gameBoard.gameResult])
            gameState = .gameOver
        }
    }

    // MARK: - Notification Handlers
    
    @objc
    func handlePlayerHasPlayed(_ notification: NSNotification) {
        guard let updatedBoard = notification.userInfo?[PlayerNotificationKey.updatedBoard] as? GameBoard,
            let player = notification.object as? Player,
            (gameState == .awaitingXPlay && player == playerX) || (gameState == .awaitingOPlay && player == playerO)
            else { return }
        gameBoard = updatedBoard
        NotificationCenter.default.post(name: GameNotification.boardHasBeenUpdated, object: self,
                                        userInfo: [GameNotificationKey.updatedBoard: gameBoard])
        advanceGameState()
    }

    @objc
    func handlePlayerError(_ notification: NSNotification) {
        guard let error = notification.userInfo?[PlayerNotificationKey.error] as? Error else { return }
        NotificationCenter.default.post(name: GameNotification.gameError, object: self,
                                        userInfo: [GameNotificationKey.error: error])
        gameState = .gameOver
    }
}

// MARK: - Game State Machine States

private enum GameState {
    case xPlaysNext
    case awaitingXPlay
    case oPlaysNext
    case awaitingOPlay
    case boardNeedsRotation
    case gameOver
}

// MARK: - Notifications

struct GameNotification {
    static let boardHasBeenUpdated = NSNotification.Name("boardHasBeenUpdated")
    static let gameOver = NSNotification.Name("gameOver")
    static let gameError = NSNotification.Name("gameError")
}

// MARK: - Notification Keys

struct GameNotificationKey {
    static let updatedBoard = "updatedBoard"
    static let gameResult = "gameResult"
    static let error = "error"
}
