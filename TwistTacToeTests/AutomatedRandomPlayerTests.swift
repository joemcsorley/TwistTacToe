//
//  AutomatedRandomPlayerTests.swift
//  TwistTacToeTests
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import XCTest
import RxSwift
@testable import TwistTacToe

class AutomatedRandomPlayerTests: XCTestCase {
    private let disposeBag = DisposeBag()

    func testPlayerTakesTurn() {
        let ex = self.expectation()
        let openBoardLocations = [1, 4, 5, 7, 8]
        let player = AutomatedRandomPlayer(symbol: .O)
        player.turnPublisher.subscribe(
            onNext: { turnResult in
                do {
                    // Verify that only one of the possible open board locations was played in
                    for boardLocation in openBoardLocations {
                        guard try turnResult.updatedBoard.gamePiece(atLocation: boardLocation) == .O else { continue }
                        let expectedBoard = try unfinishedBoard1.newByPlaying(player.gamePiece, atLocation: boardLocation)
                        XCTAssertEqual(turnResult.updatedBoard, expectedBoard)
                        break
                    }
                    ex.fulfill()
                } catch {
                    XCTFail()
                }
            },
            onError: { error in
                XCTFail()
            }).disposed(by: disposeBag)
        player.takeTurn(onBoard: unfinishedBoard1, rotationPattern: RotationPattern())
        ex.assertCompletion()
    }
}
