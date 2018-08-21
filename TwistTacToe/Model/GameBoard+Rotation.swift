//
//  GameBoard+Rotation.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import Foundation

extension GameBoard {
    func newByRotating(usingPattern rotationPattern: RotationPattern) -> GameBoard {
        let newXBits = xBits.rotate(usingPattern: rotationPattern)
        let newOBits = oBits.rotate(usingPattern: rotationPattern)
        return GameBoard(xBits: newXBits, oBits: newOBits)
    }
}

extension BoardBits {
    func rotate(usingPattern rotationPattern: RotationPattern) -> BoardBits {
        var newValue: BoardBits = 0
        rotationPattern.pattern.forEach { rotationMove in
            if self & rotationMove.currentLocationBitmask > 0 {
                newValue |= rotationMove.nextLocationBitmask
            }
        }
        return newValue
    }
}
