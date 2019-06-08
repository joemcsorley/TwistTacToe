//
//  Game.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import Foundation
import PromiseKit

typealias TurnCompletionHandler = (GameBoard) throws -> Void

class GameController {
    private let playerX: Player
    private let playerO: Player
    private(set) var currentPlayer: Player?
    let rotationPattern: RotationPattern
    private(set) lazy var gameBoard = initialGameBoard()
    private var gameResolver: Resolver<GamePiece?>?
    
    // Dependency injection for testing
    var initialGameBoard: () -> GameBoard = {
        return GameBoard()
    }

    // Injectable function: called after each play to allow UI updates
    var updatedBoardHandler: (GameBoard) -> Void = { _ in }

    // MARK: - Init / Setup
    
    init(playerX: Player, playerO: Player, rotationPattern: RotationPattern = RotationPattern()) {
        self.rotationPattern = rotationPattern
        self.playerX = playerX
        self.playerO = playerO
    }
    
    // MARK: - Public interface methods

    // Returns a Promise that fulfills with the winning GamePiece (nil in case of a tie).
    func play() -> Promise<GamePiece?> {
        return Promise<GamePiece?> { resolver in
            gameResolver = resolver
            handleGameState()
        }
    }
    
    // MARK: - Helpers

    // Evaluates the game state and either ends it, or starts another turn cycle.
    private func handleGameState() {
        if gameBoard.gameResult == .unfinished {
            executeTurnCycle()
                .done(handleGameState)
                .catch { error in
                    self.gameResolver?.reject(error)
                }
        }
        else {
            self.gameResolver?.fulfill(gameBoard.gameResult.winningSymbol)
        }
    }
    
    // Returns a Promise that fulfills once a turn cycle has completed.
    // A turn cycle consists of the following:
    // 1. Player X plays
    // 2. Player O plays
    // 3. The board is rotated
    private func executeTurnCycle() -> Promise<Void> {
        return firstly { () -> Promise<GameBoard> in
            // Player X plays
            currentPlayer = playerX
            return playerX.takeTurn(onBoard: gameBoard, rotationPattern: rotationPattern)
        }
        .then { updatedBoard -> Promise<GameBoard> in
            // Player O plays
            self.gameBoard = updatedBoard
            self.updatedBoardHandler(updatedBoard)
            self.currentPlayer = self.playerO
            return self.playerO.takeTurn(onBoard: updatedBoard, rotationPattern: self.rotationPattern)
        }
        .then { updatedBoard -> Guarantee<Void> in
            // Slight delay
            self.gameBoard = updatedBoard
            self.updatedBoardHandler(updatedBoard)
            return after(seconds: 0.4)
        }
        .then { _ -> Promise<Void> in
            // Rotate the GameBoard
            self.gameBoard = self.gameBoard.newByRotating(usingPattern: self.rotationPattern)
            self.updatedBoardHandler(self.gameBoard)
            return Promise<Void> { $0.fulfill(()) }
        }
    }
}
