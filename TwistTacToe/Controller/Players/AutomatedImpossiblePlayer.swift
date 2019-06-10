//
//  AutomatedImpossiblePlayer.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import Foundation
import PromiseKit

class AutomatedImpossiblePlayer: Player {
    private(set) var gamePiece: GamePiece
    private let boardLocationCenter = 4
    private var strategy: MinimizeLossesStrategy?
    
    init(symbol: GamePiece) {
        self.gamePiece = symbol
    }
    
    func takeTurn(onBoard board: GameBoard, rotationPattern: RotationPattern) {
        if strategy == nil {
            strategy = MinimizeLossesStrategy(withRotationPattern: rotationPattern, targetSymbol: gamePiece)
        }
        
        var bestBoardLocation: BoardLocation
        do {
            if let boardLocation = try strategy?.bestPath(forBoard: board) {
                bestBoardLocation = boardLocation
            }
            else {
                bestBoardLocation = try board.randomOpenLocation()
            }

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.future(seconds: 0.5)) {
                do {
                    let updatedBoard = try board.newByPlaying(self.gamePiece, atLocation: bestBoardLocation)
                    let userInfo: [AnyHashable: Any] = [PlayerNotificationKey.boardLocation: bestBoardLocation,
                                                        PlayerNotificationKey.updatedBoard: updatedBoard]
                    NotificationCenter.default.post(name: PlayerNotification.playerHasPlayed, object: self, userInfo: userInfo)
                } catch {
                    print("Error: Something went wrong handling automated play for player \(self.gamePiece)")
                    NotificationCenter.default.post(name: PlayerNotification.playerError, object: self,
                                                    userInfo: [PlayerNotificationKey.error: error])
                }
            }

        } catch {
            print("Error: Something went wrong handling automated play for player \(self.gamePiece)")
            NotificationCenter.default.post(name: PlayerNotification.playerError, object: self,
                                            userInfo: [PlayerNotificationKey.error: error])
        }
    }
}
