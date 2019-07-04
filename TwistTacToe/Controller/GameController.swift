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
    private lazy var gameBoard = initialGameBoard()
    private var gameState: GameState = .xPlaysNext
    private(set) var gameStateSnapshot = BehaviorSubject<GameStateSnapshot>(value: (0, .initial, GameBoard()))
    // Convenience accessor
    var gameStateSnapshotValue: GameStateSnapshot {
        do { return try gameStateSnapshot.value() }
        catch { return (0, .initial, GameBoard()) }
    }
    private lazy var playHistory: [GameStateSnapshot] = initialPlayHistory()
    private(set) var playHistoryIndex = 0
    private(set) var isGamePaused = false
    
    private let disposeBag = DisposeBag()

    // Dependency injection for tutorial
    var initialPlayHistory: () -> [GameStateSnapshot] = {
        return []
    }
    
    // Dependency injection for testing
    var initialGameBoard: () -> GameBoard = {
        return GameBoard()
    }
    
    // After recording play history, the playHistoryIndex always points to the latest playHistory array index that was populated.
    // The current board gets recorded right before it is about to be changed.
    var hasUndo: Bool { return playHistoryIndex > 0 }
    var hasRedo: Bool { return playHistoryIndex < playHistory.count-1 }

    // MARK: - Init / Setup
    
    init(playerX: Player, playerO: Player, rotationPattern: RotationPattern = RotationPattern(), playHistory: [GameStateSnapshot]? = nil, startingAtIndex playHistoryIndex: Int = 0) {
        self.rotationPattern = rotationPattern
        self.playerX = playerX
        self.playerO = playerO
        setupPlayer(playerX)
        setupPlayer(playerO)
        if let playHistory = playHistory {
            self.playHistory = playHistory
            self.playHistoryIndex = playHistoryIndex.clamp(0, playHistory.count-1)
        }
    }

    private func setupPlayer(_ player: Player) {
        player.turnPublisher.subscribe(
            onNext: { turnResult in
                self.handle(player: player, hasPlayedAtBoardLocation: turnResult.boardLocation, updatedBoard: turnResult.updatedBoard)
            },
            onError: { error in
                self.gameStateSnapshot.onError(error)
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
        play()
    }
    
    func handleGameBoardTapped(atLocation boardLocation: BoardLocation) {
        if gameState == .xPlaysNext { playerX.handleGameBoardTapped(atLocation: boardLocation) }
        else if gameState == .oPlaysNext { playerO.handleGameBoardTapped(atLocation: boardLocation) }
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
        if playHistoryIndex == playHistory.count-1 {
            resume()
        }
    }
    
    // MARK: - State Machine

    private func advanceGameState() {
        guard !isGamePaused else { return }
        recordPlayHistory()
        switch gameState {
        case .xPlaysNext:
            handleXPlaysNextState()
        case .oPlaysNext:
            handleOPlaysNextState()
        case .boardNeedsRotation:
            handleBoardNeedsRotation()
        default:
            break
        }
    }
    
    private func handleXPlaysNextState() {
        currentPlayer = playerX
        playerX.takeTurn(onBoard: gameBoard, rotationPattern: rotationPattern)
    }

    private func handleOPlaysNextState() {
        currentPlayer = playerO
        playerO.takeTurn(onBoard: gameBoard, rotationPattern: rotationPattern)
    }

    private func handleBoardNeedsRotation() {
        gameBoard = gameBoard.newByRotating(usingPattern: rotationPattern)
        if gameBoard.gameResult == .unfinished {
            gameState = .xPlaysNext
        }
        else {
            gameState = .gameOver
        }
        advanceGameState()
    }

    // MARK: - Player Event Handlers
    
    func handle(player: Player, hasPlayedAtBoardLocation boardLocation: BoardLocation, updatedBoard: GameBoard) {
        guard (gameState == .xPlaysNext && player == playerX) || (gameState == .oPlaysNext && player == playerO) else { return }
        gameBoard = updatedBoard
        self.gameState = self.gameState == .xPlaysNext ? .oPlaysNext : .boardNeedsRotation
        self.advanceGameState()
    }

    // MARK: - Helpers
    
    private func recordPlayHistory() {
        playHistoryIndex = playHistory.count
        let currentGameStateSnapshot = (playHistoryIndex: playHistoryIndex, gameState: gameState, gameBoard: gameBoard)
        playHistory.append(currentGameStateSnapshot)
        gameStateSnapshot.onNext(currentGameStateSnapshot)
    }
    
    private func updateGameToCurrentPlayHistoryIndex() {
        gameBoard = playHistory[playHistoryIndex].gameBoard
        gameState = playHistory[playHistoryIndex].gameState
        gameStateSnapshot.onNext((playHistoryIndex: playHistoryIndex, gameState: gameState, gameBoard: gameBoard))
    }
}

// MARK: - Game State Machine States

enum GameState {
    case initial  // This is only used in the initial published game state, but never as part of game play
    case xPlaysNext
    case oPlaysNext
    case boardNeedsRotation
    case gameOver
}

// MARK: - Turn History

typealias GameStateSnapshot = (playHistoryIndex: Int, gameState: GameState, gameBoard: GameBoard)
