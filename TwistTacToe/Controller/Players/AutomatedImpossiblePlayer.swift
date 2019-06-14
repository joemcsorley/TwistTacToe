//
//  AutomatedImpossiblePlayer.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class AutomatedImpossiblePlayer: Player {
    private(set) var gamePiece: GamePiece
    private let boardLocationCenter = 4
    private var strategy: MinimizeLossesStrategy?
    let turnPublisher = PublishSubject<TurnResult>()

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
                    self.turnPublisher.onNext((bestBoardLocation, updatedBoard))
                } catch {
                    print("Error: Something went wrong handling automated play for player \(self.gamePiece)")
                    self.turnPublisher.onError(error)
                }
            }

        } catch {
            print("Error: Something went wrong handling automated play for player \(self.gamePiece)")
            self.turnPublisher.onError(error)
        }
    }
}
