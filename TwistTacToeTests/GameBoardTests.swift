//
//  GameBoardTests.swift
//  TwistTacToeTests
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import XCTest
@testable import TwistTacToe

class GameBoardTests: XCTestCase {
    
    func testGameBoardEquals() {
        let testBoard = GameBoard.newWithPattern([
            _X, __, _O,
            _O, __, __,
            _X, __, __
            ])

        XCTAssertEqual(testBoard, unfinishedBoard1)
        XCTAssertNotEqual(testBoard, unfinishedBoard2)
    }

    func testNewEmptyGameBoard() {
        let testBoard = GameBoard.newWithPattern([
            __, __, __,
            __, __, __,
            __, __, __
            ])
        let emptyBoard = GameBoard()
        
        XCTAssertEqual(testBoard, emptyBoard)
    }

    func testGameBoardIsFull() {
        XCTAssert(winningXBoard1.isFull)
        XCTAssert(winningOBoard1.isFull)
        XCTAssert(tiedBoard1.isFull)
        XCTAssert(noWinnerBoard1.isFull)
        XCTAssertFalse(unfinishedBoard1.isFull)
        XCTAssertFalse(unfinishedBoard2.isFull)
    }

    func testIsEmptyBoardLocation() {
        XCTAssert(unfinishedBoard1.isEmpty(boardLocation: 1))
        XCTAssert(unfinishedBoard1.isEmpty(boardLocation: 4))
        XCTAssert(unfinishedBoard1.isEmpty(boardLocation: 8))
        XCTAssertFalse(unfinishedBoard1.isEmpty(boardLocation: 0))
        XCTAssertFalse(unfinishedBoard1.isEmpty(boardLocation: 3))
    }

    func testOpenLocations() {
        XCTAssertEqual(unfinishedBoard1.openLocations(), [1, 4, 5, 7, 8])
        XCTAssertEqual(unfinishedBoard2.openLocations(), [1, 4, 5, 7])
        XCTAssertEqual(noWinnerBoard1.openLocations(), [3])
    }
    
    func testNewWithLocations() {
        do {
            let testBoard = try GameBoard.new(withXLocations: [0, 6, 8], oLocations: [2, 3])
            XCTAssertEqual(testBoard, unfinishedBoard2)
        }
        catch {
            XCTFail()
        }
    }
    
    func testGamePieceAtLocation() {
        do {
            let gamePieceAtLocation0 = try unfinishedBoard1.gamePiece(atLocation: 0)
            let gamePieceAtLocation3 = try unfinishedBoard1.gamePiece(atLocation: 3)
            let gamePieceAtLocation7 = try unfinishedBoard1.gamePiece(atLocation: 7)
            XCTAssertEqual(gamePieceAtLocation0, .X)
            XCTAssertEqual(gamePieceAtLocation3, .O)
            XCTAssertNil(gamePieceAtLocation7)
        }
        catch {
            XCTFail()
        }
    }

    func testGamePieceAtInvalidLocation() {
        do {
            let _ = try unfinishedBoard1.gamePiece(atLocation: 10)
            XCTFail()
        }
        catch GameBoardError.invalidBoardLocation {
            // This is the expected result.  PASS
        }
        catch {
            XCTFail()
        }
    }

    func testAddGamePieceToGameBoard() {
        do {
            let testBoard = try unfinishedBoard1.newByPlaying(.X, atLocation: 8)
            XCTAssertEqual(testBoard, unfinishedBoard2)
        }
        catch {
            XCTFail()
        }
    }
    
    func testAddGamePieceToInvalidBoardLocation() {
        do {
            let _ = try unfinishedBoard1.newByPlaying(.X, atLocation: 12)
            XCTFail()
        }
        catch GameBoardError.invalidBoardLocation {
            // This is the expected result.  PASS
        }
        catch {
            XCTFail()
        }
    }

    func testAddGamePieceToOccupiedBoardLocation() {
        do {
            let _ = try unfinishedBoard1.newByPlaying(.X, atLocation: 3)
            XCTFail()
        }
        catch GameBoardError.boardLocationAlreadyOccupied {
            // This is the expected result.  PASS
        }
        catch {
            XCTFail()
        }
    }

    func testGameResult() {
        XCTAssertEqual(winningXBoard1.gameResult, .X)
        XCTAssertEqual(winningOBoard1.gameResult, .O)
        XCTAssertEqual(tiedBoard1.gameResult, .tie)
        XCTAssertEqual(noWinnerBoard1.gameResult, .tie)
        XCTAssertEqual(unfinishedBoard1.gameResult, .unfinished)
    }
    
    func testRandomLocation() {
        do {
            let openLocation = try unfinishedBoard1.randomOpenLocation()
            XCTAssertNil(try unfinishedBoard1.gamePiece(atLocation: openLocation))
        }
        catch {
            XCTFail()
        }
    }

    func testNoRandomLocation() {
        do {
            let _ = try noWinnerBoard1.randomOpenLocation()
            XCTFail()
        }
        catch GameBoardError.boardIsFull {
            // This is the expected result.  PASS
        }
        catch {
            XCTFail()
        }
    }

    func testRotation() {
        do {
            let rotationPattern = try RotationPattern(withMapping: [
                2, 4, 6,
                8, 0, 1,
                3, 5, 7
            ])
            // unfinishedBoard1:  after rotation:
            // _X, __, _O,        __, _X, __,
            // _O, __, __,        __, _O, __,
            // _X, __, __         _X, __, _O
            let tempBoard = unfinishedBoard1.newByRotating(usingPattern: rotationPattern)
            XCTAssertNil(try tempBoard.gamePiece(atLocation: 0))
            XCTAssertEqual(try tempBoard.gamePiece(atLocation: 1), .X)
            XCTAssertNil(try tempBoard.gamePiece(atLocation: 2))
            XCTAssertNil(try tempBoard.gamePiece(atLocation: 3))
            XCTAssertEqual(try tempBoard.gamePiece(atLocation: 4), .O)
            XCTAssertEqual(try tempBoard.gamePiece(atLocation: 6), .X)
            XCTAssertEqual(try tempBoard.gamePiece(atLocation: 8), .O)
        }
        catch {
            XCTFail()
        }
    }
}
