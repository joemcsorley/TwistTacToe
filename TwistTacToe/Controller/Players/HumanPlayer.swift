//
//  HumanPlayer.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import Foundation

class HumanPlayer: Player {
    private(set) var gamePiece: GamePiece
    private var currentBoard: GameBoard?
    
    init(symbol: GamePiece) {
        self.gamePiece = symbol
        setupObservers()
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleGameBoardTapped), name: UINotification.gameBoardTapped, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func takeTurn(onBoard board: GameBoard, rotationPattern: RotationPattern) {
        self.currentBoard = board
    }

    @objc
    func handleGameBoardTapped(_ notification: NSNotification) {
        guard let board = currentBoard,
            let boardLocation = notification.userInfo?[UINotificationKey.boardLocation] as? BoardLocation
            else { return }
        do {
            let updatedBoard = try board.newByPlaying(gamePiece, atLocation: boardLocation)
            currentBoard = nil
            let userInfo: [AnyHashable: Any] = [PlayerNotificationKey.boardLocation: boardLocation,
                                                PlayerNotificationKey.updatedBoard: updatedBoard]
            NotificationCenter.default.post(name: PlayerNotification.playerHasPlayed, object: self, userInfo: userInfo)
        }
        catch GameBoardError.boardLocationAlreadyOccupied {
            // If the user tapped on an already-occupied space, then ignore it
        }
        catch {
            print("Error: Something went wrong handling a user tap on the game board for player \(gamePiece)")
            NotificationCenter.default.post(name: PlayerNotification.playerError, object: self,
                                            userInfo: [PlayerNotificationKey.error: error])
        }
    }
}
