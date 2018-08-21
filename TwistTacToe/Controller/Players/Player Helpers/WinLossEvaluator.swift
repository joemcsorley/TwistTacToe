//
//  WinLossEvaluator.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import Foundation

class WinLossEvaluator {
    private(set) var boardEvaluation: BoardEvaluation = [:]
    private let rotationPattern: RotationPattern
    private let targetSymbol: GamePiece
    
    init(withRotationPattern rotationPattern: RotationPattern, targetSymbol: GamePiece) {
        self.rotationPattern = rotationPattern
        self.targetSymbol = targetSymbol
        do {
            try createBoardEvaluation()
        } catch {
            print("Error: Something went wrong evaluating the game")
        }
    }
    
    private func createBoardEvaluation() throws {
        let board = GameBoard()
        try getTurnEvaluation(currentSymbol: .X, board: board)
    }
    
    @discardableResult
    private func getTurnEvaluation(currentSymbol: GamePiece, board: GameBoard) throws -> TurnEvaluation {
        let turnEvaluation = try board.openLocations().map { boardLocation -> PathEvaluation in
            let newBoard = try board.newByPlaying(currentSymbol, atLocation: boardLocation)
            let tally = try getWinLossTally(forBoard: newBoard, lastSymbolPlayed: currentSymbol)
            return PathEvaluation(boardLocation: boardLocation, tally: tally)
        }
        // This "side effect" is what actually builds the persistent board evaluation
        if currentSymbol == targetSymbol {
            boardEvaluation[board.hashableKey] = turnEvaluation
        }
        return turnEvaluation
    }

    private func getWinLossTally(forBoard board: GameBoard, lastSymbolPlayed: GamePiece) throws -> WinLossTally {
        var boardForEvaluation = board
        if lastSymbolPlayed == .O {
            boardForEvaluation = board.newByRotating(usingPattern: rotationPattern)
            let gameResult = boardForEvaluation.gameResult
            if gameResult != .unfinished {
                return WinLossTally.new(withWinner: gameResult.winningSymbol)
            }
        }
        let turnEvaluation = try getTurnEvaluation(currentSymbol: lastSymbolPlayed.opposingPiece, board: boardForEvaluation)
        return WinLossTally.new(byTallying: turnEvaluation)
    }
    
    func getTurnEvaluation(forBoard board: GameBoard) -> TurnEvaluation? {
        return boardEvaluation[board.hashableKey]
    }
}

typealias BoardEvaluation = [Int32: TurnEvaluation]
typealias TurnEvaluation = [PathEvaluation]

struct PathEvaluation {
    let boardLocation: BoardLocation
    let tally: WinLossTally
}

struct WinLossTally {
    let xWins: Int
    let oWins: Int
    
    func wins(forSymbol symbol: GamePiece) -> Int {
        return symbol == .X ? xWins : oWins
    }

    func losses(forSymbol symbol: GamePiece) -> Int {
        return symbol == .X ? oWins : xWins
    }

    static func new(withWinner winner: GamePiece?) -> WinLossTally {
        return WinLossTally(xWins: winner == .X ? 1 : 0, oWins: winner == .O ? 1 : 0)
    }

    static func new(byTallying turnEvaluation: TurnEvaluation) -> WinLossTally {
        return turnEvaluation.reduce(WinLossTally(xWins: 0, oWins: 0)) { (tally, pathEvaluation) in
            return WinLossTally(xWins: tally.xWins + pathEvaluation.tally.xWins, oWins: tally.oWins + pathEvaluation.tally.oWins)
        }
    }
}

// MARK: -  GameBoard Extension

extension GameBoard {
    var hashableKey: Int32 {
        return (Int32(self.xBits) << 16) | Int32(self.oBits)
    }
}
