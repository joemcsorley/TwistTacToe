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
    private var playHistory: [TurnHistory] = []
    private var playHistoryIndex = 0
    private(set) var isGamePaused = false
    
    // Dependency injection for testing
    var initialGameBoard: () -> GameBoard = {
        return GameBoard()
    }
    
    // After recording play history, the playHistoryIndex always points to the latest playHistory array index that was populated.
    // The current board gets recorded right before it is about to be changed.
    var hasUndo: Bool { return playHistoryIndex > 0 }
    var hasRedo: Bool { return playHistoryIndex < playHistory.count-1 }

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
        NotificationCenter.default.addObserver(self, selector: #selector(handleUndo), name: UINotification.undoTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRedo), name: UINotification.redoTapped, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public interface methods

    func play() {
        advanceGameState()
    }

    func resume() {
        isGamePaused = false
        // Pop off play history entries up to and including the one currently pointed to by playHistoryIndex.
        // The current one will be re-recorded before the board is changed again.
        while playHistory.count > playHistoryIndex {
            playHistory.removeLast()
        }
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
        recordTurnHistory()
        currentPlayer = playerX
        NotificationCenter.default.post(name: GameNotification.currentPlayer, object: self,
                                        userInfo: [GameNotificationKey.gamePiece: playerX.gamePiece])
        playerX.takeTurn(onBoard: gameBoard, rotationPattern: rotationPattern)
        gameState = .awaitingXPlay
    }

    private func handleOPlaysNextState() {
        recordTurnHistory()
        currentPlayer = playerO
        NotificationCenter.default.post(name: GameNotification.currentPlayer, object: self,
                                        userInfo: [GameNotificationKey.gamePiece: playerO.gamePiece])
        playerO.takeTurn(onBoard: gameBoard, rotationPattern: rotationPattern)
        gameState = .awaitingOPlay
    }

    private func handleAwaitingXPlay() {
        gameState = .oPlaysNext
        advanceGameState()
    }

    private func handleAwaitingOPlay() {
        gameState = .boardNeedsRotation
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.future(seconds: 0.4)) {
            self.advanceGameState()
        }
    }

    private func handleBoardNeedsRotation() {
        recordTurnHistory()
        gameBoard = gameBoard.newByRotating(usingPattern: rotationPattern)
        NotificationCenter.default.post(name: GameNotification.boardHasBeenUpdated, object: self,
                                        userInfo: [GameNotificationKey.updatedBoard: gameBoard])
        if gameBoard.gameResult == .unfinished {
            gameState = .xPlaysNext
        }
        else {
            NotificationCenter.default.post(name: GameNotification.gameOver, object: self,
                                            userInfo: [GameNotificationKey.gameResult: gameBoard.gameResult])
            gameState = .gameOver
        }
        advanceGameState()
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

    @objc
    func handleUndo(_ notification: NSNotification) {
        guard hasUndo else { return }
        isGamePaused = true
        playHistoryIndex -= 1
        updateGameToCurrentPlayHistoryIndex()
    }

    @objc
    func handleRedo(_ notification: NSNotification) {
        guard hasRedo else { return }
        playHistoryIndex += 1
        updateGameToCurrentPlayHistoryIndex()
    }

    // MARK: - Helpers
    
    private func recordTurnHistory() {
        playHistory.append((gameState: gameState, gameBoard: gameBoard))
        playHistoryIndex = playHistory.count - 1
    }
    
    private func updateGameToCurrentPlayHistoryIndex() {
        gameState = playHistory[playHistoryIndex].gameState
        gameBoard = playHistory[playHistoryIndex].gameBoard
        NotificationCenter.default.post(name: GameNotification.boardHasBeenUpdated, object: self,
                                        userInfo: [GameNotificationKey.updatedBoard: gameBoard])
        NotificationCenter.default.post(name: GameNotification.currentPlayer, object: self,
                                        userInfo: currentPlayerUserInfo(forGameState: gameState))
    }
    
    private func currentPlayerUserInfo(forGameState gameState: GameState) -> [AnyHashable: Any] {
        if gameState == .xPlaysNext { return [GameNotificationKey.gamePiece: GamePiece.X] }
        else if gameState == .oPlaysNext { return [GameNotificationKey.gamePiece: GamePiece.O] }
        else { return [:] }
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
    static let currentPlayer = NSNotification.Name("currentPlayer")
    static let boardHasBeenUpdated = NSNotification.Name("boardHasBeenUpdated")
    static let gameOver = NSNotification.Name("gameOver")
    static let gameError = NSNotification.Name("gameError")
}

// MARK: - Notification Keys

struct GameNotificationKey {
    static let gamePiece = "gamePiece"
    static let updatedBoard = "updatedBoard"
    static let gameResult = "gameResult"
    static let error = "error"
}

// MARK: - Turn History

private typealias TurnHistory = (gameState: GameState, gameBoard: GameBoard)
