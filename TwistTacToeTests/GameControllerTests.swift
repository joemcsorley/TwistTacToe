//
//  GameControllerTests.swift
//  TwistTacToeTests
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import XCTest
import RxSwift
@testable import TwistTacToe

class GameControllerTests: XCTestCase {
    var eventHandlerQueue: [(Any?) -> Void] = []
    let disposeBag = DisposeBag()
    
    override func setUp() {
        eventHandlerQueue = []
    }

    func testInvalidPlayTerminatesGame() {
        let ex = self.expectation()
        let invalidTapLocation = 22
        var game: GameController!
        
        eventHandlerQueue.append { gameStateSnapshot in
            self.verify(gameStateSnapshot: gameStateSnapshot, isEqualTo: .initial)
        }
        eventHandlerQueue.append { gameStateSnapshot in
            // Verify the first player is X, then initiate X's (invalid) play
            self.verify(gameStateSnapshot: gameStateSnapshot, isEqualTo: .xPlaysNext) {
                self.tapGameBoard(forGame: game, atLocation: invalidTapLocation)
            }
        }
        eventHandlerQueue.append { error in
            // Verify an invalidBoardLocation error occurs
            self.verify(gameBoardError: error, isEqualTo: .invalidBoardLocation) {
                ex.fulfill()
            }
        }
        
        game = newObservedGame()
        game.play()
        ex.assertCompletion()
    }

    func testGameDeclaresWinner() {
        let ex = self.expectation()
        let xTapLocation: BoardLocation = 2
        let xRotatedLocation: BoardLocation = 5
        let oTapLocation: BoardLocation = 4
        let oRotatedLocation: BoardLocation = 7
        var game: GameController!

        eventHandlerQueue.append { gameStateSnapshot in
            self.verify(gameStateSnapshot: gameStateSnapshot, isEqualTo: .initial)
        }
        eventHandlerQueue.append { gameStateSnapshot in
            // Verify the first player is X, then initiate X's play
            self.verify(gameStateSnapshot: gameStateSnapshot, isEqualTo: .xPlaysNext) {
                self.tapGameBoard(forGame: game, atLocation: xTapLocation)
            }
        }
        eventHandlerQueue.append { gameStateSnapshot in
            // Verify the board reflects X's play, and that the next player is O, then initiate O's play
            self.verify(gameStateSnapshot: gameStateSnapshot, isEqualTo: .oPlaysNext, withGamePieceLocations: [(xTapLocation, .X)]){
                self.tapGameBoard(forGame: game, atLocation: oTapLocation)
            }
        }
        eventHandlerQueue.append { gameStateSnapshot in
            // Verify the board reflects O's play, and that the board pieces are about to be rotated
            self.verify(gameStateSnapshot: gameStateSnapshot, isEqualTo: .boardNeedsRotation, withGamePieceLocations: [(oTapLocation, .O)])
        }
        eventHandlerQueue.append { gameStateSnapshot in
            // Verify the board pieces are all rotated, and that the game is over, and X is the winner
            self.verify(gameStateSnapshot: gameStateSnapshot, isEqualTo: .gameOver, withGamePieceLocations: [(xRotatedLocation, .X), (oRotatedLocation, .O)]) {
                XCTAssertEqual(game.gameStateSnapshotValue.gameBoard.gameResult, .X)
                ex.fulfill()
            }
        }

        game = newObservedGame(withInitialGameBoard: self.xWinsInLocation2Board)
        game.play()
        ex.assertCompletion(withinTimeout: 2)
    }

    func testGameDeclaresTie() {
        let ex = self.expectation()
        let xTapLocation: BoardLocation = 7
        let xRotatedLocation: BoardLocation = 2
        let oTapLocation: BoardLocation = 8
        let oRotatedLocation: BoardLocation = 0
        var game: GameController!

        eventHandlerQueue.append { gameStateSnapshot in
            self.verify(gameStateSnapshot: gameStateSnapshot, isEqualTo: .initial)
        }
        eventHandlerQueue.append { gameStateSnapshot in
            // Verify the first player is X, then initiate X's play
            self.verify(gameStateSnapshot: gameStateSnapshot, isEqualTo: .xPlaysNext) {
                self.tapGameBoard(forGame: game, atLocation: xTapLocation)
            }
        }
        eventHandlerQueue.append { gameStateSnapshot in
            // Verify the board reflects X's play, and that the next player is O, then initiate O's play
            self.verify(gameStateSnapshot: gameStateSnapshot, isEqualTo: .oPlaysNext, withGamePieceLocations: [(xTapLocation, .X)]){
                self.tapGameBoard(forGame: game, atLocation: oTapLocation)
            }
        }
        eventHandlerQueue.append { gameStateSnapshot in
            // Verify the board reflects O's play, and that the board pieces are about to be rotated
            self.verify(gameStateSnapshot: gameStateSnapshot, isEqualTo: .boardNeedsRotation, withGamePieceLocations: [(oTapLocation, .O)])
        }
        eventHandlerQueue.append { gameStateSnapshot in
            // Verify the board pieces are all rotated, and that the game is over, and X is the winner
            self.verify(gameStateSnapshot: gameStateSnapshot, isEqualTo: .gameOver, withGamePieceLocations: [(xRotatedLocation, .X), (oRotatedLocation, .O)]) {
                XCTAssertEqual(game.gameStateSnapshotValue.gameBoard.gameResult, .tie)
                ex.fulfill()
            }
        }

        game = newObservedGame(withInitialGameBoard: self.tiedBoard)
        game.play()
        ex.assertCompletion(withinTimeout: 2)
    }

    // MARK: - Helpers
    
    private var testRotationPattern: RotationPattern? = {
        do {
            return try RotationPattern(withMapping: [
                0, 3, 6,
                1, 4, 7,
                2, 5, 8])
        }
        catch {
            return nil
        }
    }()
    
    let xWinsInLocation2Board = GameBoard.newWithPattern([
        _X, _X, __,
        _O, __, __,
        _O, __, __
    ])

    let tiedBoard = GameBoard.newWithPattern([
        _X, __, _X,
        _O, _X, _O,
        _O, __, __
    ])

    private func newObservedGame(withInitialGameBoard initialGameBoard: GameBoard? = nil) -> GameController {
        let playerX = HumanPlayer(symbol: .X)
        let playerO = HumanPlayer(symbol: .O)
        let game = GameController(playerX: playerX, playerO: playerO, rotationPattern: testRotationPattern!)
        if let initialGameBoard = initialGameBoard {
            game.initialGameBoard = { return initialGameBoard }
        }
        observeEvents(forGame: game)
        return game
    }
    
    private func observeEvents(forGame game: GameController) {
        game.gameStateSnapshot.subscribe { event in
            print("GameControllerTests.observeEvents(forGame:)  Event (game state): \(event)")
            switch event {
            case .next(let value):
                self.handleGameEvent(value)
            case .error(let error):
                self.handleGameEvent(error)
            case .completed:
                self.handleGameEvent()
            }
        }
        .disposed(by: disposeBag)
    }
    
    private func handleGameEvent(_ value: Any? = nil) {
        // Pop the next event handler off the queue and execute it
        guard eventHandlerQueue.count > 0 else { return }
        let eventHandler = eventHandlerQueue.remove(at: 0)
        eventHandler(value)
    }

    private func verify(gameStateSnapshot: Any?,
                        isEqualTo expectedGameState: GameState,
                        withGamePieceLocations expectedGamePieceLocations: [GamePieceLocationPair] = [],
                        then completionBlock: () -> Void = {}) {
        guard let gameStateSnapshot = gameStateSnapshot as? GameStateSnapshot, gameStateSnapshot.gameState == expectedGameState else {
            XCTFail()
            return
        }
        // Verify that all expected game pieces are at their expected board locations
        do {
            try expectedGamePieceLocations.forEach {
                let gamePieceAtLocation = try gameStateSnapshot.gameBoard.gamePiece(atLocation: $0.boardLocation)
                XCTAssertEqual(gamePieceAtLocation, $0.gamePiece)
            }
        } catch {
            XCTFail()
        }
        completionBlock()
    }
    
    private func verify(gameBoardError: Any?, isEqualTo expectedError: GameBoardError, then completionBlock: () -> Void = {}) {
        guard let error = gameBoardError as? GameBoardError, error == expectedError else {
            XCTFail()
            return
        }
        completionBlock()
    }
    
    private func tapGameBoard(forGame game: GameController, atLocation boardLocation: BoardLocation) {
        DispatchQueue.main.async {
            game.handleGameBoardTapped(atLocation: boardLocation)
        }
    }
}

typealias GamePieceLocationPair = (boardLocation: BoardLocation, gamePiece: GamePiece)
