//
//  HumanPlayerTests.swift
//  TwistTacToeTests
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import XCTest
@testable import TwistTacToe

class HumanPlayerTests: XCTestCase {
    var playerHasPlayedCallback: (GameBoard) -> Void = { _ in }
    var errorCallback: (Error) -> Void = { _ in }

    func testPlayerTakesTurnAtLocation() {
        let ex = self.expectation()
        let player = HumanPlayer(symbol: .O)
        let tapLocation = 4
        observePlayerHasPlayed { updatedBoard in
            do {
                // Verify that the player played in the correct location
                XCTAssertEqual(try updatedBoard.gamePiece(atLocation: tapLocation), .O)
                // Verify that the player didn't modify the board in any other way
                let expectedBoard = try unfinishedBoard1.newByPlaying(player.gamePiece, atLocation: tapLocation)
                XCTAssertEqual(updatedBoard, expectedBoard)
                ex.fulfill()
            } catch {
                XCTFail()
            }
        }
        observePlayerError { _ in XCTFail() }
        player.takeTurn(onBoard: unfinishedBoard1, rotationPattern: RotationPattern())
        NotificationCenter.default.post(name: UINotification.gameBoardTapped, object: self,
                                        userInfo: [UINotificationKey.boardLocation: tapLocation])
        ex.assertCompletion()
    }
    
    func testPlayerTakesTurnAtInvalidLocation() {
        let ex = self.expectation()
        let player = HumanPlayer(symbol: .X)
        let tapLocation = 12
        observePlayerHasPlayed { _ in XCTFail() }
        observePlayerError { error in
            XCTAssertEqual(error as! GameBoardError, GameBoardError.invalidBoardLocation)
            ex.fulfill()
        }
        player.takeTurn(onBoard: unfinishedBoard1, rotationPattern: RotationPattern())
        NotificationCenter.default.post(name: UINotification.gameBoardTapped, object: self,
                                        userInfo: [UINotificationKey.boardLocation: tapLocation])
        ex.assertCompletion()
    }

    func testPlayerTakesTurnAtOccupiedLocation() {
        let ex = self.expectation()
        let player = HumanPlayer(symbol: .X)
        let tapLocation = 2
        observePlayerHasPlayed { _ in XCTFail() }
        observePlayerError { _ in XCTFail() }
        player.takeTurn(onBoard: unfinishedBoard1, rotationPattern: RotationPattern())
        NotificationCenter.default.post(name: UINotification.gameBoardTapped, object: self,
                                        userInfo: [UINotificationKey.boardLocation: tapLocation])
        ex.assertTimeout()
    }
    
    // MARK: - Helpers
    
    private func observePlayerHasPlayed(withCallback callback: @escaping (GameBoard) -> Void) {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerHasPlayed), name: PlayerNotification.playerHasPlayed, object: nil)
        playerHasPlayedCallback = callback
    }
    
    private func observePlayerError(withCallback callback: @escaping (Error) -> Void) {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerError), name: PlayerNotification.playerError, object: nil)
        errorCallback = callback
    }

    @objc
    func handlePlayerHasPlayed(_ notification: NSNotification) {
        NotificationCenter.default.removeObserver(self)
        guard let updatedBoard = notification.userInfo?[PlayerNotificationKey.updatedBoard] as? GameBoard else { return }
        playerHasPlayedCallback(updatedBoard)
        playerHasPlayedCallback = { _ in }
    }

    @objc
    func handlePlayerError(_ notification: NSNotification) {
        NotificationCenter.default.removeObserver(self)
        guard let error = notification.userInfo?[PlayerNotificationKey.error] as? Error else { return }
        errorCallback(error)
        errorCallback = { _ in }
    }
}
