//
//  GameControllerTests.swift
//  TwistTacToeTests
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import XCTest
@testable import TwistTacToe

class GameControllerTests: XCTestCase {
    var boardHandlerQueue: [(GameBoard) -> Void] = []
    
    override func setUp() {
        boardHandlerQueue = []
    }
    
    func testSuccessfulTurnCycle() {
        let ex = self.expectation()
        let playerX = HumanPlayer(symbol: .X)
        let playerO = HumanPlayer(symbol: .O)
        let game = GameController(playerX: playerX, playerO: playerO, rotationPattern: testRotationPattern!)
        game.updatedBoardHandler = testNextQueuedBoardHandler(_:)
        // Verify that X plays, O plays, and the board is rotated properly
        boardHandlerQueue.append(verifyGamePieceLocations([(7, .X)], thenTapLocation: 4, inGame: game))
        boardHandlerQueue.append(verifyGamePieceLocations([(4, .O)]))
        boardHandlerQueue.append(verifyGamePieceLocations([(4, .X), (8, .O)], thenFulfill: ex))
        _ = game.play()
        game.handleGameBoardTapped(atLocation: 7)
        ex.assertCompletion()
    }
    
    func testInvalidPlayTerminatesGame() {
        let ex = self.expectation()
        let playerX = HumanPlayer(symbol: .X)
        let playerO = HumanPlayer(symbol: .O)
        let game = GameController(playerX: playerX, playerO: playerO, rotationPattern: testRotationPattern!)
        game.updatedBoardHandler = testNextQueuedBoardHandler(_:)
        // Verify that O's invalid play throws an appropriate error
        boardHandlerQueue.append(verifyGamePieceLocations([(3, .X)], thenTapLocation: 22, inGame: game))
        game.play()
            .done { _ in
                XCTFail()
            }
            .catch { error in
                XCTAssertEqual(error as? GameBoardError, GameBoardError.invalidBoardLocation)
                ex.fulfill()
            }
        game.handleGameBoardTapped(atLocation: 3)
        ex.assertCompletion()
    }

    func testGameDeclaresWinner() {
        let ex = self.expectation()
        let playerX = HumanPlayer(symbol: .X)
        let playerO = HumanPlayer(symbol: .O)
        let game = GameController(playerX: playerX, playerO: playerO, rotationPattern: testRotationPattern!)
        game.initialGameBoard = { return winningXBoard1 }
        game.play()
            .done { winningSymbol in
                XCTAssertEqual(winningSymbol, .X)
                ex.fulfill()
            }
            .catch { error in
                XCTFail()
            }
        ex.assertCompletion()
    }

    func testGameDeclaresTie() {
        let ex = self.expectation()
        let playerX = HumanPlayer(symbol: .X)
        let playerO = HumanPlayer(symbol: .O)
        let game = GameController(playerX: playerX, playerO: playerO, rotationPattern: testRotationPattern!)
        game.initialGameBoard = { return tiedBoard1 }
        game.play()
            .done { winningSymbol in
                XCTAssertEqual(winningSymbol, nil)
                ex.fulfill()
            }
            .catch { error in
                XCTFail()
        }
        ex.assertCompletion()
    }

    // MARK: - Helpers
    
    private var testRotationPattern: RotationPattern? = {
        do {
            return try RotationPattern(withMapping: [
                4, 5, 1,
                2, 7, 3,
                0, 6, 8])
        }
        catch {
            return nil
        }
    }()

    // Each time this is called it pops the first board handler off the queue and executes it.
    private func testNextQueuedBoardHandler(_ updatedBoard: GameBoard) -> Void {
        guard let boardHandler = boardHandlerQueue.first else { return }
        _ = boardHandlerQueue.remove(at: 0)
        boardHandler(updatedBoard)
    }
    
    private func verifyGamePieceLocations(_ gamePieceLocationPairs: [GamePieceLocationPair],
                                  thenTapLocation tapLocation: BoardLocation? = nil,
                                  inGame game: GameController? = nil,
                                  thenFulfill expectation: XCTestExpectation? = nil) -> (GameBoard) -> Void {
        return { updatedBoard in
            do {
                // Verify that all expected symbols are at their expected board locations
                try gamePieceLocationPairs.forEach {
                    let gamePieceAtLocation = try updatedBoard.gamePiece(atLocation: $0.boardLocation)
                    XCTAssertEqual(gamePieceAtLocation, $0.symbol)
                }
                // Tap the next board location (on behalf of the next player)
                if let tapLocation = tapLocation, let game = game {
                    DispatchQueue.main.async {
                        game.handleGameBoardTapped(atLocation: tapLocation)
                    }
                }
                // Fulfill the expectation
                if let ex = expectation {
                    ex.fulfill()
                }
            }
            catch {
                XCTFail()
            }
        }
    }
}

typealias GamePieceLocationPair = (boardLocation: BoardLocation, symbol: GamePiece)
