//
//  AutomatedPlayer.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class AutomatedRandomPlayer: Player {
    private(set) var gamePiece: GamePiece
    let turnPublisher = PublishSubject<TurnResult>()

    init(symbol: GamePiece) {
        self.gamePiece = symbol
    }

    func takeTurn(onBoard board: GameBoard, rotationPattern: RotationPattern) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.future(seconds: 0.5)) {
            do {
                let boardLocation = try board.randomOpenLocation()
                let updatedBoard = try board.newByPlaying(self.gamePiece, atLocation: boardLocation)
                self.turnPublisher.onNext((boardLocation, updatedBoard))
            } catch {
                print("Error: Something went wrong handling automated play for player \(self.gamePiece)")
                self.turnPublisher.onError(error)
            }
        }
        return
    }
}
