//
//  RotationPatternTests.swift
//  TwistTacToeTests
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import XCTest
@testable import TwistTacToe

class RotationPatternTests: XCTestCase {

    func testNextMovesMatchNumberMap() {
        let rotationPattern = RotationPattern()
        for index in boardRange {
            let nextIndex = rotationPattern.nextMoves[index]
            let number = rotationPattern.numberMap[index]
            let nextNumber = number + (number < 8 ? 1 : -8)
            XCTAssertEqual(rotationPattern.numberMap[nextIndex], nextNumber)
        }
    }

    func testPatternBitmasksMatchNextMoves() {
        let rotationPattern = RotationPattern()
        for index in boardRange {
            let nextIndex = rotationPattern.nextMoves[index]
            let currentLocationBitmask = 1 << index as BoardBits
            let nextLocationBitmask = 1 << nextIndex as BoardBits
            XCTAssertEqual(rotationPattern.pattern[index].currentLocationBitmask, currentLocationBitmask)
            XCTAssertEqual(rotationPattern.pattern[index].nextLocationBitmask, nextLocationBitmask)
        }
    }
}
