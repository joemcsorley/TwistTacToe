//
//  MinimizeLossesStrategy.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import Foundation

class MinimizeLossesStrategy: Strategy {
    let rotationPattern: RotationPattern
    let targetSymbol: GamePiece
    let boardEvaluator: WinLossEvaluator
    
    required init(withRotationPattern rotationPattern: RotationPattern, targetSymbol: GamePiece) {
        self.rotationPattern = rotationPattern
        self.targetSymbol = targetSymbol
        self.boardEvaluator = WinLossEvaluator(withRotationPattern: rotationPattern, targetSymbol: targetSymbol)
    }
    
    func bestPath(forBoard board: GameBoard) throws -> BoardLocation? {
        guard let turnEvaluation = boardEvaluator.getTurnEvaluation(forBoard: board),
            let pathEvaluation = turnEvaluation.max(by: pathEvaluationComparator)
            else { throw MinimizeLossesStrategyError.noBestPathForBoard }
        return pathEvaluation.boardLocation
    }
    
    // Return true iff rhs is a better path than lhs
    private func pathEvaluationComparator(lhs: PathEvaluation, rhs: PathEvaluation) -> Bool {
        return rhs.tally.losses(forSymbol: targetSymbol) < lhs.tally.losses(forSymbol: targetSymbol) ||
            (rhs.tally.losses(forSymbol: targetSymbol) == lhs.tally.losses(forSymbol: targetSymbol) &&
                rhs.tally.wins(forSymbol: targetSymbol) > lhs.tally.wins(forSymbol: targetSymbol))
    }
}

enum MinimizeLossesStrategyError: Error {
    case noBestPathForBoard
}
