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
        let game = newObservedGame()
        
        eventHandlerQueue.append { gameState in
            // Verify the first player is X
            self.verify(gameState: gameState, isEqualTo: .xPlaysNext)
        }
        eventHandlerQueue.append { gameState in
            // Verify the game is ready for X to play, then initiate X's (invalid) play
            self.verify(gameState: gameState, isEqualTo: .awaitingXPlay) {
                game.handleGameBoardTapped(atLocation: invalidTapLocation)
            }
        }
        eventHandlerQueue.append { error in
            // Verify an invalidBoardLocation error occurs
            self.verify(gameBoardError: error, isEqualTo: .invalidBoardLocation) {
                ex.fulfill()
            }
        }
        
        game.play()
        ex.assertCompletion()
    }

    func testGameDeclaresWinner() {
        let ex = self.expectation()
        let xTapLocation: BoardLocation = 2
        let xRotatedLocation: BoardLocation = 5
        let oTapLocation: BoardLocation = 4
        let oRotatedLocation: BoardLocation = 7
        let game = newObservedGame(withInitialGameBoard: self.xWinsInLocation2Board)

        eventHandlerQueue.append { gameState in
            // Verify the first player is X
            self.verify(gameState: gameState, isEqualTo: .xPlaysNext)
        }
        eventHandlerQueue.append { gameState in
            // Verify the game is ready for X to play, then initiate X's play
            self.verify(gameState: gameState, isEqualTo: .awaitingXPlay) {
                game.handleGameBoardTapped(atLocation: xTapLocation)
            }
        }
        eventHandlerQueue.append { updateBoard in
            // Verify the board reflects X's play
            self.verify(updatedBoard: updateBoard, withGamePieceLocations: [(xTapLocation, .X)])
        }
        eventHandlerQueue.append { gameState in
            // Verify the next player is O
            self.verify(gameState: gameState, isEqualTo: .oPlaysNext)
        }
        eventHandlerQueue.append { gameState in
            // Verify the game is ready for O to play, then initiate O's play
            self.verify(gameState: gameState, isEqualTo: .awaitingOPlay) {
                game.handleGameBoardTapped(atLocation: oTapLocation)
            }
        }
        eventHandlerQueue.append { updateBoard in
            // Verify the board reflects O's play
            self.verify(updatedBoard: updateBoard, withGamePieceLocations: [(oTapLocation, .O)])
        }
        eventHandlerQueue.append { gameState in
            // Verify the board pieces are about to be rotated
            self.verify(gameState: gameState, isEqualTo: .boardNeedsRotation)
        }
        eventHandlerQueue.append { updateBoard in
            // Verify the board pieces are all rotated
            self.verify(updatedBoard: updateBoard, withGamePieceLocations: [(xRotatedLocation, .X), (oRotatedLocation, .O)])
        }
        eventHandlerQueue.append { gameState in
            // Verify the game is over, and X is the winner
            self.verify(gameState: gameState, isEqualTo: .gameOver) {
                XCTAssertEqual(game.gameBoard.gameResult, .X)
                ex.fulfill()
            }
        }

        game.play()
        ex.assertCompletion(withinTimeout: 2)
    }

    func testGameDeclaresTie() {
        let ex = self.expectation()
        let xTapLocation: BoardLocation = 7
        let xRotatedLocation: BoardLocation = 2
        let oTapLocation: BoardLocation = 8
        let oRotatedLocation: BoardLocation = 0
        let game = newObservedGame(withInitialGameBoard: self.tiedBoard)

        eventHandlerQueue.append { gameState in
            // Verify the first player is X
            self.verify(gameState: gameState, isEqualTo: .xPlaysNext)
        }
        eventHandlerQueue.append { gameState in
            // Verify the game is ready for X to play, then initiate X's play
            self.verify(gameState: gameState, isEqualTo: .awaitingXPlay) {
                game.handleGameBoardTapped(atLocation: xTapLocation)
            }
        }
        eventHandlerQueue.append { updateBoard in
            // Verify the board reflects X's play
            self.verify(updatedBoard: updateBoard, withGamePieceLocations: [(xTapLocation, .X)])
        }
        eventHandlerQueue.append { gameState in
            // Verify the next player is O
            self.verify(gameState: gameState, isEqualTo: .oPlaysNext)
        }
        eventHandlerQueue.append { gameState in
            // Verify the game is ready for O to play, then initiate O's play
            self.verify(gameState: gameState, isEqualTo: .awaitingOPlay) {
                game.handleGameBoardTapped(atLocation: oTapLocation)
            }
        }
        eventHandlerQueue.append { updateBoard in
            // Verify the board reflects O's play
            self.verify(updatedBoard: updateBoard, withGamePieceLocations: [(oTapLocation, .O)])
        }
        eventHandlerQueue.append { gameState in
            // Verify the board pieces are about to be rotated
            self.verify(gameState: gameState, isEqualTo: .boardNeedsRotation)
        }
        eventHandlerQueue.append { updateBoard in
            // Verify the board pieces are all rotated
            self.verify(updatedBoard: updateBoard, withGamePieceLocations: [(xRotatedLocation, .X), (oRotatedLocation, .O)])
        }
        eventHandlerQueue.append { gameState in
            // Verify the game is over, and that it's a tie
            self.verify(gameState: gameState, isEqualTo: .gameOver) {
                XCTAssertEqual(game.gameBoard.gameResult, .tie)
                ex.fulfill()
            }
        }
        
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
        game.gameStatePublisher.subscribe { event in
            print("Event (game state): \(event)")
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
        
        game.updatedBoardPublisher.subscribe { event in
            print("Event (updated board): \(event)")
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
    
    private func verify(gameState: Any?, isEqualTo expectedGameState: GameState, then completionBlock: () -> Void = {}) {
        guard let gameState = gameState as? GameState, gameState == expectedGameState else {
            XCTFail()
            return
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
    
    private func verify(updatedBoard: Any?, withGamePieceLocations expectedGamePieceLocations: [GamePieceLocationPair], then completionBlock: () -> Void = {}) {
        guard let updatedBoard = updatedBoard as? GameBoard else {
            XCTFail()
            return
        }
        // Verify that all expected game pieces are at their expected board locations
        do {
            try expectedGamePieceLocations.forEach {
                let gamePieceAtLocation = try updatedBoard.gamePiece(atLocation: $0.boardLocation)
                XCTAssertEqual(gamePieceAtLocation, $0.gamePiece)
            }
        } catch {
            XCTFail()
        }
        completionBlock()
    }
}

typealias GamePieceLocationPair = (boardLocation: BoardLocation, gamePiece: GamePiece)
