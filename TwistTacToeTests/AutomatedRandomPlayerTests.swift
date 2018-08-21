//
//  AutomatedRandomPlayerTests.swift
//  TwistTacToeTests
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import XCTest
@testable import TwistTacToe

class AutomatedRandomPlayerTests: XCTestCase {

    func testPlayerTakesTurn() {
        let ex = self.expectation()
        let player = AutomatedRandomPlayer(symbol: .O)
        let openBoardLocations = [1, 4, 5, 7, 8]
        player.takeTurn(onBoard: unfinishedBoard1, rotationPattern: RotationPattern())
            .done { board in
                do {
                    // Verify that only one of the possible open board locations was played in
                    for boardLocation in openBoardLocations {
                        guard try board.gamePiece(atLocation: boardLocation) == .O else { continue }
                        let expectedBoard = try unfinishedBoard1.newByPlaying(player.symbol, atLocation: boardLocation)
                        XCTAssertEqual(board, expectedBoard)
                        break
                    }
                    ex.fulfill()
                } catch {
                    XCTFail()
                }
            }
            .catch { error in
                XCTFail()
            }
        ex.assertCompletion()
    }
}
