//
//  Player.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import Foundation
import RxSwift

protocol Player {
    var gamePiece: GamePiece { get }
    var turnPublisher: PublishSubject<TurnResult> { get }
    func takeTurn(onBoard board: GameBoard, rotationPattern: RotationPattern)
    func handleGameBoardTapped(atLocation boardLocation: BoardLocation)
}

extension Player {
    var opponentSymbol: GamePiece {
        return (gamePiece == .X) ? .O : .X
    }

    func handleGameBoardTapped(atLocation boardLocation: BoardLocation) {}
}

extension Equatable where Self: Player {}

func ==(lhs: Player, rhs: Player) -> Bool {
    // Players are considered equal if they have the same symbol
    return lhs.gamePiece == rhs.gamePiece
}

typealias TurnResult = (boardLocation: BoardLocation, updatedBoard: GameBoard)
