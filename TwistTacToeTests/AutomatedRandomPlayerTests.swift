//
//  AutomatedRandomPlayerTests.swift
//  TwistTacToeTests
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import XCTest
@testable import TwistTacToe

class AutomatedRandomPlayerTests: XCTestCase {
    var callback: (GameBoard) -> Void = { _ in }
    
    func testPlayerTakesTurn() {
        let ex = self.expectation()
        let player = AutomatedRandomPlayer(symbol: .O)
        let openBoardLocations = [1, 4, 5, 7, 8]
        observePlayerNotification { updatedBoard in
            do {
                // Verify that only one of the possible open board locations was played in
                for boardLocation in openBoardLocations {
                    guard try updatedBoard.gamePiece(atLocation: boardLocation) == .O else { continue }
                    let expectedBoard = try unfinishedBoard1.newByPlaying(player.gamePiece, atLocation: boardLocation)
                    XCTAssertEqual(updatedBoard, expectedBoard)
                    break
                }
                ex.fulfill()
            } catch {
                XCTFail()
            }
        }
        
        player.takeTurn(onBoard: unfinishedBoard1, rotationPattern: RotationPattern())
        ex.assertCompletion()
    }
    
    // MARK: - Helpers
    
    private func observePlayerNotification(withCallback callback: @escaping (GameBoard) -> Void) {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerHasPlayed), name: PlayerNotification.playerHasPlayed, object: nil)
        self.callback = callback
    }
    
    @objc
    func handlePlayerHasPlayed(_ notification: NSNotification) {
        NotificationCenter.default.removeObserver(self)
        guard let updatedBoard = notification.userInfo?[PlayerNotificationKey.updatedBoard] as? GameBoard else { return }
        callback(updatedBoard)
        callback = { _ in }
    }
}
