//
//  HumanPlayer.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import Foundation
import PromiseKit

class HumanPlayer: Player {
    private(set) var symbol: GamePiece
    private var resolver: Resolver<GameBoard>?
    private var currentBoard: GameBoard?
    
    init(symbol: GamePiece) {
        self.symbol = symbol
        setupObservers()
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleGameBoardTapped), name: UINotifications.gameBoardTapped, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func takeTurn(onBoard board: GameBoard, rotationPattern: RotationPattern) -> Promise<GameBoard> {
        return Promise<GameBoard> { resolver in
            self.currentBoard = board
            self.resolver = resolver
        }
    }

    @objc
    func handleGameBoardTapped(_ notification: NSNotification) {
        guard let board = currentBoard,
            let boardLocation = notification.userInfo?[UINotificationKeys.boardLocation] as? BoardLocation
            else { return }
        do {
            let updatedBoard = try board.newByPlaying(symbol, atLocation: boardLocation)
            currentBoard = nil
            resolver?.fulfill(updatedBoard)
        }
        catch GameBoardError.boardLocationAlreadyOccupied {
            // If the user tapped on an already-occupied space, then ignore it
        }
        catch {
            print("Error: Something went wrong handling a user tap on the game board")
            resolver?.reject(error)
        }
    }
}
