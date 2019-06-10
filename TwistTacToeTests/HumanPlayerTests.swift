//
//  HumanPlayerTests.swift
//  TwistTacToeTests
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import XCTest
@testable import TwistTacToe

class HumanPlayerTests: XCTestCase {
    
    func testPlayerTakesTurnAtLocation() {
        let ex = self.expectation()
        let player = HumanPlayer(symbol: .O)
        let tapLocation = 4
        player.takeTurn(onBoard: unfinishedBoard1, rotationPattern: RotationPattern())
            .done { board in
                do {
                    // Verify that the player played in the correct location
                    XCTAssertEqual(try board.gamePiece(atLocation: tapLocation), .O)
                    // Verify that the player didn't modify the board in any other way
                    let expectedBoard = try unfinishedBoard1.newByPlaying(player.gamePiece, atLocation: tapLocation)
                    XCTAssertEqual(board, expectedBoard)
                    ex.fulfill()
                } catch {
                    XCTFail()
                }
            }
            .catch { error in
                XCTFail()
            }
        player.handleGameBoardTapped(atLocation: tapLocation)
        ex.assertCompletion()
    }
    
    func testPlayerTakesTurnAtInvalidLocation() {
        let ex = self.expectation()
        let player = HumanPlayer(symbol: .X)
        let tapLocation = 12
        player.takeTurn(onBoard: unfinishedBoard1, rotationPattern: RotationPattern())
            .done { board in
                XCTFail()
            }
            .catch { error in
                XCTAssertEqual(error as! GameBoardError, GameBoardError.invalidBoardLocation)
                ex.fulfill()
            }
        player.handleGameBoardTapped(atLocation: tapLocation)
        ex.assertCompletion()
    }

    func testPlayerTakesTurnAtOccupiedLocation() {
        let ex = self.expectation()
        let player = HumanPlayer(symbol: .X)
        let tapLocation = 2
        player.takeTurn(onBoard: unfinishedBoard1, rotationPattern: RotationPattern())
            .done { board in
                XCTFail()
            }
            .catch { error in
                XCTFail()
            }
        player.handleGameBoardTapped(atLocation: tapLocation)
        ex.assertTimeout()
    }
}
