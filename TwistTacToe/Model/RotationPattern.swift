//
//  RotationPattern.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import Foundation

struct RotationPattern {
    // The rotation path, for display purposes
    private(set) var numberMap: [Int] = [-1, -1, -1, -1, -1, -1, -1, -1, -1]
    // The piece at board location 0 will rotate to board location nextMoves[0]
    private(set) var nextMoves: [BoardLocation] = [-1, -1, -1, -1, -1, -1, -1, -1, -1]
    // A series of bitmasks used to apply the rotation pattern
    private(set) var pattern: [RotationMove] = []
    
    init() {
        // Randomly scatter the numbers 0...8 around the board to define a rotation path
        // (i.e. a number map for display purposes).
        for num in boardRange {
            var i = Int(arc4random_uniform(9))
            while numberMap[i] >= 0 { i += (i < 8 ? 1 : -8) }
            numberMap[i] = num
        }
        
        setupNextMoves()
    }
    
    init(withMapping numberMap: [Int]) throws {
        guard numberMap.count == 9 else { throw RotationPatternError.invalidMapSize }
        try numberMap.forEach {
            guard boardRange.contains($0) else { throw RotationPatternError.invalidMapContent }
        }
        self.numberMap = numberMap
        setupNextMoves()
    }
    
    private mutating func setupNextMoves() {
        // Traverse the rotation path in order to convert it to a series of next moves
        for currentIndex in boardRange {
            let currentNumber = numberMap[currentIndex]
            let nextNumber = currentNumber + (currentNumber < 8 ? 1 : -8)
            let nextIndex = numberMap.index(of: nextNumber)!
            nextMoves[currentIndex] = nextIndex
            pattern.append((1 << currentIndex, 1 << nextIndex))
        }
    }
}

enum RotationPatternError: Error {
    case invalidMapSize
    case invalidMapContent
}

typealias RotationMove = (currentLocationBitmask: BoardBits, nextLocationBitmask: BoardBits)
