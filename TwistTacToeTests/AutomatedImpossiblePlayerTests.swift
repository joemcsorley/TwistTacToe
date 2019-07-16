//
//  AutomatedImpossiblePlayerTests.swift
//  TwistTacToeTests
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import XCTest
import RxSwift
@testable import TwistTacToe

class AutomatedImpossiblePlayerTests: XCTestCase {
    private let disposeBag = DisposeBag()
    
    func testPlayerTakesTurn() {
        let ex = self.expectation()
        let openBoardLocations = [1, 4, 5, 7, 8]
        let player = AutomatedImpossiblePlayer(symbol: .O)
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

    // MARK: - Outcome Tests
    
    func testBestOutcome() {
        let bestoutcomeForX = [outcome1, outcome2, outcome3, outcome4].best(forGamePiece: .X)!
        let bestoutcomeForO = [outcome1, outcome2, outcome3, outcome4].best(forGamePiece: .O)!
        XCTAssertEqual(bestoutcomeForX, outcome4)
        XCTAssertEqual(bestoutcomeForO, outcome3)
    }

    func testSumOutcomes() {
        let outcomeSum1 = [outcome2, outcome4].sum(forBoardLocation: 1)
        let outcomeSum2 = [outcome1, outcome2, outcome3, outcome4].sum(forBoardLocation: 2)
        XCTAssertEqual(outcomeSum1, Outcome(boardLocation: 0, xWins: 9, oWins: 3, ties: 5))
        XCTAssertEqual(outcomeSum2, Outcome(boardLocation: 0, xWins: 11, oWins: 10, ties: 10))
    }
    
    func testOutcomeWinRatio() {
        XCTAssert(outcome1.winRatio(forGamePiece: .X).isEqualTo(0.25))
        XCTAssert(outcome1.winRatio(forGamePiece: .O).isEqualTo(0.5))
        XCTAssert(outcome2.winRatio(forGamePiece: .O).isEqualTo(3/10))
    }

    func testOutcomeLossRatio() {
        XCTAssert(outcome1.lossRatio(forGamePiece: .O).isEqualTo(0.25))
        XCTAssert(outcome1.lossRatio(forGamePiece: .X).isEqualTo(0.5))
        XCTAssert(outcome2.lossRatio(forGamePiece: .X).isEqualTo(3/10))
    }

    // MARK: - GameBoard Extension Tests

    func testBestNextPlayOutcomes() {
        let testBoard = GameBoard.newWithPattern([
            _O, _X, _O,
            __, _X, _O,
            __, _X, _X
        ])
        let rotationPattern = try! RotationPattern(withMapping: [
            6, 7, 8,
            1, 0, 2,
            3, 4, 5
        ])

        let bestOutcomeForX = testBoard.getBestNextPlayOutcome(forGamePiece: .X, withRotationPattern: rotationPattern)
        let bestOutcomeForO = testBoard.getBestNextPlayOutcome(forGamePiece: .O, withRotationPattern: rotationPattern)
        XCTAssertEqual(bestOutcomeForX, Outcome(boardLocation: 0, xWins: 0, oWins: 0, ties: 1))
        XCTAssertEqual(bestOutcomeForO, Outcome(boardLocation: 0, xWins: 0, oWins: 1, ties: 0))
    }
}

extension Outcome: Equatable {
    public static func ==(lhs: Outcome, rhs: Outcome) -> Bool {
        return lhs.xWins == rhs.xWins && lhs.oWins == rhs.oWins && lhs.ties == rhs.ties
    }
}

private let outcome1 = Outcome(boardLocation: 0, xWins: 1, oWins: 2, ties: 1)
private let outcome2 = Outcome(boardLocation: 0, xWins: 5, oWins: 3, ties: 2)
private let outcome3 = Outcome(boardLocation: 0, xWins: 1, oWins: 5, ties: 4)
private let outcome4 = Outcome(boardLocation: 0, xWins: 4, oWins: 0, ties: 3)
