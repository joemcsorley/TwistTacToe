//
//  HumanPlayer.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class HumanPlayer: Player {
    private(set) var gamePiece: GamePiece
    private var currentBoard: GameBoard?
    let turnPublisher = PublishSubject<TurnResult>()

    init(symbol: GamePiece) {
        self.gamePiece = symbol
    }
    
    func takeTurn(onBoard board: GameBoard, rotationPattern: RotationPattern) {
        self.currentBoard = board
    }

    func handleGameBoardTapped(atLocation boardLocation: BoardLocation) {
        guard let board = currentBoard else { return }
        do {
            let updatedBoard = try board.newByPlaying(gamePiece, atLocation: boardLocation)
            currentBoard = nil
            turnPublisher.onNext((boardLocation, updatedBoard))
        }
        catch GameBoardError.boardLocationAlreadyOccupied {
            // If the user tapped on an already-occupied space, then ignore it
        }
        catch {
            print("Error: Something went wrong handling a user tap on the game board for player \(gamePiece)")
            turnPublisher.onError(error)
        }
    }
}
