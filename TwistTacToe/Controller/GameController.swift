//
//  Game.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

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
    
    let gameStatePublisher = PublishSubject<GameState>()
    let updatedBoardPublisher = PublishSubject<GameBoard>()
    private let disposeBag = DisposeBag()

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
        setupPlayer(playerX)
        setupPlayer(playerO)
    }

    private func setupPlayer(_ player: Player) {
        player.turnPublisher.subscribe(
            onNext: { turnResult in
                self.handle(player: player, hasPlayedAtBoardLocation: turnResult.boardLocation, updatedBoard: turnResult.updatedBoard)
            },
            onError: { error in
                self.handle(player: player, error: error)
            }).disposed(by: disposeBag)
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
    
    func handleGameBoardTapped(atLocation boardLocation: BoardLocation) {
        if gameState == .awaitingXPlay { playerX.handleGameBoardTapped(atLocation: boardLocation) }
        else if gameState == .awaitingOPlay { playerO.handleGameBoardTapped(atLocation: boardLocation) }
    }
    
    func undo() {
        guard hasUndo else { return }
        isGamePaused = true
        playHistoryIndex -= 1
        updateGameToCurrentPlayHistoryIndex()
    }
    
    func redo() {
        guard hasRedo else { return }
        playHistoryIndex += 1
        updateGameToCurrentPlayHistoryIndex()
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
        playerX.takeTurn(onBoard: gameBoard, rotationPattern: rotationPattern)
        gameState = .awaitingXPlay
        gameStatePublisher.onNext(gameState)
    }

    private func handleOPlaysNextState() {
        recordTurnHistory()
        currentPlayer = playerO
        playerO.takeTurn(onBoard: gameBoard, rotationPattern: rotationPattern)
        gameState = .awaitingOPlay
        gameStatePublisher.onNext(gameState)
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
        updatedBoardPublisher.onNext(gameBoard)
        if gameBoard.gameResult == .unfinished {
            gameState = .xPlaysNext
        }
        else {
            gameState = .gameOver
            recordTurnHistory()
        }
        gameStatePublisher.onNext(gameState)
        advanceGameState()
    }

    // MARK: - Player Event Handlers
    
    func handle(player: Player, hasPlayedAtBoardLocation boardLocation: BoardLocation, updatedBoard: GameBoard) {
        guard (gameState == .awaitingXPlay && player == playerX) || (gameState == .awaitingOPlay && player == playerO) else { return }
        gameBoard = updatedBoard
        updatedBoardPublisher.onNext(gameBoard)
        advanceGameState()
    }

    func handle(player: Player, error: Error) {
        gameStatePublisher.onError(error)
        gameState = .gameOver
    }

    // MARK: - Helpers
    
    private func recordTurnHistory() {
        playHistory.append((gameState: gameState, gameBoard: gameBoard))
        playHistoryIndex = playHistory.count - 1
    }
    
    private func updateGameToCurrentPlayHistoryIndex() {
        gameState = playHistory[playHistoryIndex].gameState
        gameBoard = playHistory[playHistoryIndex].gameBoard
        updatedBoardPublisher.onNext(gameBoard)
        gameStatePublisher.onNext(gameState)
    }
}

// MARK: - Game State Machine States

enum GameState {
    case xPlaysNext
    case awaitingXPlay
    case oPlaysNext
    case awaitingOPlay
    case boardNeedsRotation
    case gameOver
}

// MARK: - Turn History

private typealias TurnHistory = (gameState: GameState, gameBoard: GameBoard)
