//
//  GameControllerTests.swift
//  TwistTacToeTests
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import XCTest
@testable import TwistTacToe

class GameControllerTests: XCTestCase {
    var notificationHandlerQueue: [(NSNotification) -> Void] = []
    
    override func setUp() {
        notificationHandlerQueue = []
        observeGameNotifications()
    }
    
    override func tearDown() {
        NotificationCenter.default.removeObserver(self)
    }

    func testInvalidPlayTerminatesGame() {
        let ex = self.expectation()
        let playerX = HumanPlayer(symbol: .X)
        let playerO = HumanPlayer(symbol: .O)
        let game = GameController(playerX: playerX, playerO: playerO, rotationPattern: testRotationPattern!)
        let invalidTapLocation = 22
        
        notificationHandlerQueue.append { (notification) in
            // Verify the first player is X, then initiate X's (invalid) play
            self.verifyCurrentPlayerNotification(notification, withGamePiece: .X) {
                self.tapGameBoard(atLocation: invalidTapLocation)
            }
        }
        notificationHandlerQueue.append { (notification) in
            // Verify an invalidBoardLocation error occurs
            self.verifyGameErrorNotification(notification, withError: GameBoardError.invalidBoardLocation) {
                ex.fulfill()
            }
        }
        game.play()
        ex.assertCompletion()
    }

    func testGameDeclaresWinner() {
        let ex = self.expectation()
        let playerX = HumanPlayer(symbol: .X)
        let playerO = HumanPlayer(symbol: .O)
        let game = GameController(playerX: playerX, playerO: playerO, rotationPattern: testRotationPattern!)
        game.initialGameBoard = { return self.xWinsInLocation2Board }
        let xTapLocation: BoardLocation = 2
        let xRotatedLocation: BoardLocation = 5
        let oTapLocation: BoardLocation = 4
        let oRotatedLocation: BoardLocation = 7

        notificationHandlerQueue.append { (notification) in
            // Verify the first player is X, then initiate X's play
            self.verifyCurrentPlayerNotification(notification, withGamePiece: .X) {
                self.tapGameBoard(atLocation: xTapLocation)
            }
        }
        notificationHandlerQueue.append { (notification) in
            // Verify the board reflects X's play
            self.verifyUpdatedBoardNotification(notification, withGamePieceLocations: [(xTapLocation, .X)])
        }
        notificationHandlerQueue.append { (notification) in
            // Verify the next player is O, then initiate O's play
            self.verifyCurrentPlayerNotification(notification, withGamePiece: .O) {
                self.tapGameBoard(atLocation: oTapLocation)
            }
        }
        notificationHandlerQueue.append { (notification) in
            // Verify the board reflects O's play
            self.verifyUpdatedBoardNotification(notification, withGamePieceLocations: [(oTapLocation, .O)])
        }
        notificationHandlerQueue.append { (notification) in
            // Verify the board is rotated
            self.verifyUpdatedBoardNotification(notification, withGamePieceLocations: [(xRotatedLocation, .X), (oRotatedLocation, .O)])
        }
        notificationHandlerQueue.append { (notification) in
            // Verify X is declared the winner
            self.verifyGameOverNotification(notification, withGameResult: .X) {
                ex.fulfill()
            }
        }

        game.play()
        ex.assertCompletion(withinTimeout: 2)
    }

    func testGameDeclaresTie() {
        let ex = self.expectation()
        let playerX = HumanPlayer(symbol: .X)
        let playerO = HumanPlayer(symbol: .O)
        let game = GameController(playerX: playerX, playerO: playerO, rotationPattern: testRotationPattern!)
        game.initialGameBoard = { return self.tiedBoard }
        let xTapLocation: BoardLocation = 7
        let xRotatedLocation: BoardLocation = 2
        let oTapLocation: BoardLocation = 8
        let oRotatedLocation: BoardLocation = 0
        
        notificationHandlerQueue.append { (notification) in
            // Verify the first player is X, then initiate X's play
            self.verifyCurrentPlayerNotification(notification, withGamePiece: .X) {
                self.tapGameBoard(atLocation: xTapLocation)
            }
        }
        notificationHandlerQueue.append { (notification) in
            // Verify the board reflects X's play
            self.verifyUpdatedBoardNotification(notification, withGamePieceLocations: [(xTapLocation, .X)])
        }
        notificationHandlerQueue.append { (notification) in
            // Verify the next player is O, then initiate O's play
            self.verifyCurrentPlayerNotification(notification, withGamePiece: .O) {
                self.tapGameBoard(atLocation: oTapLocation)
            }
        }
        notificationHandlerQueue.append { (notification) in
            // Verify the board reflects O's play
            self.verifyUpdatedBoardNotification(notification, withGamePieceLocations: [(oTapLocation, .O)])
        }
        notificationHandlerQueue.append { (notification) in
            // Verify the board is rotated
            self.verifyUpdatedBoardNotification(notification, withGamePieceLocations: [(xRotatedLocation, .X), (oRotatedLocation, .O)])
        }
        notificationHandlerQueue.append { (notification) in
            // Verify that a tie is declared
            self.verifyGameOverNotification(notification, withGameResult: .tie) {
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

    private func verifyCurrentPlayerNotification(_ notification: NSNotification,
                                                 withGamePiece expectedGamePiece: GamePiece,
                                                 thenExecute completionBlock: () -> Void) {
        XCTAssertEqual(notification.name, GameNotification.currentPlayer)
        let gamePiece = notification.userInfo?[GameNotificationKey.gamePiece] as? GamePiece
        XCTAssertEqual(gamePiece, expectedGamePiece)
        completionBlock()
    }
    
    private func tapGameBoard(atLocation boardLocation: BoardLocation) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: UINotification.gameBoardTapped, object: self,
                                            userInfo: [UINotificationKey.boardLocation: boardLocation])
        }
    }
    
    private func verifyUpdatedBoardNotification(_ notification: NSNotification,
                                                withGamePieceLocations expectedGamePieceLocations: [GamePieceLocationPair],
                                                thenExecute completionBlock: () -> Void = {}) {
        XCTAssertEqual(notification.name, GameNotification.boardHasBeenUpdated)
        guard let updatedBoard = notification.userInfo?[GameNotificationKey.updatedBoard] as? GameBoard else {
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
    
    private func verifyGameErrorNotification(_ notification: NSNotification,
                                             withError expectedError: Error,
                                             thenExecute completionBlock: () -> Void) {
        XCTAssertEqual(notification.name, GameNotification.gameError)
        guard let error = notification.userInfo?[GameNotificationKey.error] as? Error else {
            XCTFail()
            return
        }
        XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
        completionBlock()
    }

    private func verifyGameOverNotification(_ notification: NSNotification,
                                            withGameResult expectedGameResult: GameResult,
                                            thenExecute completionBlock: () -> Void) {
        XCTAssertEqual(notification.name, GameNotification.gameOver)
        guard let gameResult = notification.userInfo?[GameNotificationKey.gameResult] as? GameResult else {
            XCTFail()
            return
        }
        XCTAssertEqual(gameResult, expectedGameResult)
        completionBlock()
    }

    private func observeGameNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleGameNotification), name: GameNotification.currentPlayer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleGameNotification), name: GameNotification.boardHasBeenUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleGameNotification), name: GameNotification.gameOver, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleGameNotification), name: GameNotification.gameError, object: nil)
    }

    @objc
    func handleGameNotification(_ notification: NSNotification) {
        guard notificationHandlerQueue.count > 0 else { return }
        let notificationHandler = notificationHandlerQueue.remove(at: 0)
        notificationHandler(notification)
    }
}

typealias GamePieceLocationPair = (boardLocation: BoardLocation, gamePiece: GamePiece)
