//
//  AutomatedPlayer.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import Foundation

class AutomatedRandomPlayer: Player {
    private(set) var symbol: GamePiece
    
    init(symbol: GamePiece) {
        self.symbol = symbol
    }

    func takeTurn(onBoard board: GameBoard, rotationPattern: RotationPattern) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.future(seconds: 0.5)) {
            do {
                let updatedBoard = try board.newByPlaying(self.symbol, atLocation: board.randomOpenLocation())
                NotificationCenter.default.post(name: PlayerNotification.playerHasPlayed, object: self,
                                                userInfo: [PlayerNotificationKey.updatedBoard: updatedBoard])
            } catch {
                print("Error: Something went wrong handling automated play for player \(self.symbol)")
                NotificationCenter.default.post(name: PlayerNotification.playerError, object: self,
                                                userInfo: [PlayerNotificationKey.error: error])
            }
        }
        return
    }
}
