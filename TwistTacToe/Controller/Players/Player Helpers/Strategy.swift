//
//  Strategy.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import Foundation

protocol Strategy {
    init(withRotationPattern rotationPattern: RotationPattern, targetSymbol: GamePiece)
    func bestPath(forBoard board: GameBoard) throws -> BoardLocation?
}
