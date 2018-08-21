//
//  Player.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import Foundation
import PromiseKit

protocol Player {
    var symbol: GamePiece { get }
    func takeTurn(onBoard board: GameBoard, rotationPattern: RotationPattern) -> Promise<GameBoard>
//    func takeTurn(onBoard board: GameBoard, rotationPattern: RotationPattern, completion: @escaping TurnCompletionHandler) throws
    func handleGameBoardTapped(atLocation boardLocation: BoardLocation)
}

extension Player {
    var opponentSymbol: GamePiece {
        return (symbol == .X) ? .O : .X
    }
    
    func handleGameBoardTapped(atLocation boardLocation: BoardLocation) {}
}

extension Equatable where Self: Player {}

func ==(lhs: Player, rhs: Player) -> Bool {
    // Players are considered equal if they have the same symbol
    return lhs.symbol == rhs.symbol
}
