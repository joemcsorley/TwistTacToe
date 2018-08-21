//
//  AutomatedPlayer.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import Foundation
import PromiseKit

class AutomatedRandomPlayer: Player {
    private(set) var symbol: GamePiece
    private let boardLocationCenter = 4
    private var strategy: MinimizeLossesStrategy?
    
    init(symbol: GamePiece) {
        self.symbol = symbol
    }

    func takeTurn(onBoard board: GameBoard, rotationPattern: RotationPattern) -> Promise<GameBoard> {
        return Promise<GameBoard> { resolver in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.future(seconds: 0.5)) {
                do {
                    let updatedBoard = try board.newByPlaying(self.symbol, atLocation: board.randomOpenLocation())
                    resolver.fulfill(updatedBoard)
                } catch {
                    resolver.reject(error)
                }
            }
            return
        }
    }
}
