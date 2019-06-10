//
//  Player.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import Foundation
import PromiseKit

protocol Player {
    var gamePiece: GamePiece { get }
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

// MARK: - Notifications

struct PlayerNotification {
    static let playerHasPlayed = NSNotification.Name("playerHasPlayed")
    static let playerError = NSNotification.Name("playerError")
}

// MARK: - Notification Keys

struct PlayerNotificationKey {
    static let boardLocation = "boardLocation"
    static let updatedBoard = "updatedBoard"
    static let error = "error"
}
