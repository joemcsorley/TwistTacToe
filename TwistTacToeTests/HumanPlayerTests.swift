//
//  HumanPlayerTests.swift
//  TwistTacToeTests
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import XCTest
import RxSwift
@testable import TwistTacToe

class HumanPlayerTests: XCTestCase {
    var playerHasPlayedCallback: (GameBoard) -> Void = { _ in }
    var errorCallback: (Error) -> Void = { _ in }
    private let disposeBag = DisposeBag()
    
    func testPlayerTakesTurnAtLocation() {
        let ex = self.expectation()
        let tapLocation = 4
        let player = HumanPlayer(symbol: .O)
        player.turnPublisher.subscribe(
            onNext: { turnResult in
                do {
                    // Verify that the player played in the correct location
                    XCTAssertEqual(try turnResult.updatedBoard.gamePiece(atLocation: tapLocation), .O)
                    // Verify that the player didn't modify the board in any other way
                    let expectedBoard = try unfinishedBoard1.newByPlaying(player.gamePiece, atLocation: tapLocation)
                    XCTAssertEqual(turnResult.updatedBoard, expectedBoard)
                    ex.fulfill()
                } catch {
                    XCTFail()
                }
            },
            onError: { error in
                XCTFail()
            }).disposed(by: disposeBag)
        player.takeTurn(onBoard: unfinishedBoard1, rotationPattern: RotationPattern())
        player.handleGameBoardTapped(atLocation: tapLocation)
        ex.assertCompletion()
    }
    
    func testPlayerTakesTurnAtInvalidLocation() {
        let ex = self.expectation()
        let tapLocation = 12
        let player = HumanPlayer(symbol: .X)
        player.turnPublisher.subscribe(
            onNext: { turnResult in
                XCTFail()
            },
            onError: { error in
                XCTAssertEqual(error as! GameBoardError, GameBoardError.invalidBoardLocation)
                ex.fulfill()
            }).disposed(by: disposeBag)
        player.takeTurn(onBoard: unfinishedBoard1, rotationPattern: RotationPattern())
        player.handleGameBoardTapped(atLocation: tapLocation)
        ex.assertCompletion()
    }

    func testPlayerTakesTurnAtOccupiedLocation() {
        let ex = self.expectation()
        let tapLocation = 2
        let player = HumanPlayer(symbol: .X)
        player.turnPublisher.subscribe(
            onNext: { turnResult in
                XCTFail()
            },
            onError: { error in
                XCTFail()
            }).disposed(by: disposeBag)
        player.takeTurn(onBoard: unfinishedBoard1, rotationPattern: RotationPattern())
        player.handleGameBoardTapped(atLocation: tapLocation)
        ex.assertTimeout()
    }
}
