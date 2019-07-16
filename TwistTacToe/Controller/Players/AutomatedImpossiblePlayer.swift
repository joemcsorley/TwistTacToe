//
//  AutomatedImpossiblePlayer.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/**
 Class Notes:
 
 This player employs a strategy that cannot be beaten, it will always either tie or win.
 
 For each play, it chooses its best next play, and makes it.  It does this by evaluating each possible move to
 determine how many wins & losses would result from each, then chooses the move that first minimizes its losses,
 and then maximizes its wins.
 
 In order to determine all possible game-end results (wins & losses) for a given move, it:
 1. Iterates over each possible next move by the opponent,
 2. for each of those it determines the best next move that it could make,
 3. then it sums up all of those best next moves.
 */

class AutomatedImpossiblePlayer: Player {
    private(set) var gamePiece: GamePiece
    let turnPublisher = PublishSubject<TurnResult>()

    init(symbol: GamePiece) {
        self.gamePiece = symbol
        bestNextPlayOutcomeDictionary = [:]
    }
    
    func takeTurn(onBoard board: GameBoard, rotationPattern: RotationPattern) {
        if bestNextPlayOutcomeDictionary.isEmpty {
            GameBoard.determineBestNextPlayOutcomes(forGamePiece: gamePiece, withRotationPattern: rotationPattern)
        }
        
        do {
            var bestBoardLocation: BoardLocation
            if let bestOutcome = bestNextPlayOutcomeDictionary[board], let boardLocation = bestOutcome.boardLocation {
                bestBoardLocation = boardLocation
            }
            else {
                print("Warning: Impossible player \(self.gamePiece) is choosing a random open location")
                bestBoardLocation = try board.randomOpenLocation()
            }
            let updatedBoard = try board.newByPlaying(self.gamePiece, atLocation: bestBoardLocation)
            self.turnPublisher.onNext((bestBoardLocation, updatedBoard))
        } catch {
            print("Error: Something went wrong handling automated play for player \(self.gamePiece)")
            self.turnPublisher.onError(error)
        }
    }
}

var bestNextPlayOutcomeDictionary: PlayOutcomes = [:]
private func addBestNextPlayOutcomeToDictionary(_ outcome: Outcome?, forBoard board: GameBoard) {
    guard let outcome = outcome, let _ = outcome.boardLocation else { return }
    bestNextPlayOutcomeDictionary[board] = outcome
}

extension GameBoard {
    static func determineBestNextPlayOutcomes(forGamePiece gamePiece: GamePiece, withRotationPattern rotationPattern: RotationPattern, onBoard board: GameBoard = GameBoard()) {
        if gamePiece == .X {
            let bestNextPlayOutcome = board.getBestNextPlayOutcome(forGamePiece: gamePiece, withRotationPattern: rotationPattern)
            addBestNextPlayOutcomeToDictionary(bestNextPlayOutcome, forBoard: board)
        }
        else {
            board.sumNextPlayOutcomes(forGamePiece: gamePiece, atLocation: -1, withRotationPattern: rotationPattern)
        }
    }
    
    func getBestNextPlayOutcome(forGamePiece gamePiece: GamePiece, withRotationPattern rotationPattern: RotationPattern) -> Outcome? {
        if let bestNextPlayOutcome = bestNextPlayOutcomeDictionary[self] { return bestNextPlayOutcome }
        
        var nextPlayOutcomes: [Outcome] = []
        for boardLocation in boardRange {
            guard let updatedBoard = try? newByPlaying(gamePiece, atLocation: boardLocation) else { continue }
            nextPlayOutcomes.append(updatedBoard.sumNextPlayOutcomes(forGamePiece: gamePiece, atLocation: boardLocation, withRotationPattern: rotationPattern))
        }
        return nextPlayOutcomes.best(forGamePiece: gamePiece)
    }
    
    @discardableResult
    func sumNextPlayOutcomes(forGamePiece gamePiece: GamePiece, atLocation boardLocation: BoardLocation, withRotationPattern rotationPattern: RotationPattern) -> Outcome {
        var bestNextPlayOutcomes: [Outcome] = []
        let opponentGamePiece = gamePiece.opposingPiece
        var board = self

        if gamePiece == .O {
            // Rotate the board, and handle game end if necessary
            board = newByRotating(usingPattern: rotationPattern)
            if let outcome = board.outcomeForFinishedGame(finalBoardLocation: boardLocation) { return outcome }
        }

        // Iterate over all possible next moves by the opponent
        for opponentNextLocation in boardRange {
            guard var updatedBoard = try? board.newByPlaying(opponentGamePiece, atLocation: opponentNextLocation) else { continue }
            
            if opponentGamePiece == .O {
                // Rotate the board, and handle game end (by the opponent play) if necessary
                updatedBoard = updatedBoard.newByRotating(usingPattern: rotationPattern)
                if let finalOutcome = updatedBoard.outcomeForFinishedGame(finalBoardLocation: boardLocation) {
                    bestNextPlayOutcomes.append(finalOutcome)
                    continue
                }
            }
            
            if let bestNextPlayOutcome = updatedBoard.getBestNextPlayOutcome(forGamePiece: gamePiece, withRotationPattern: rotationPattern) {
                bestNextPlayOutcomes.append(bestNextPlayOutcome)
                addBestNextPlayOutcomeToDictionary(bestNextPlayOutcome, forBoard: updatedBoard)
            }
        }
        return bestNextPlayOutcomes.sum(forBoardLocation: boardLocation)
    }
    
    func outcomeForFinishedGame(finalBoardLocation: BoardLocation?) -> Outcome? {
        switch gameResult {
        case .X: return Outcome(boardLocation: finalBoardLocation, xWins: 1, oWins: 0, ties: 0)
        case .O: return Outcome(boardLocation: finalBoardLocation, xWins: 0, oWins: 1, ties: 0)
        case .tie: return Outcome(boardLocation: finalBoardLocation, xWins: 0, oWins: 0, ties: 1)
        default: return nil
        }
    }
}

struct Outcome: CustomStringConvertible {
    var boardLocation: BoardLocation?
    let xWins: Int
    let oWins: Int
    let ties: Int

    var description: String {
        let total = Double(xWins + oWins + ties)
        return String(format: "loc: %d, xWins: %d (%.3f), oWins: %d (%.3f), ties: %d (%.3f)", boardLocation ?? -1, xWins, Double(xWins)/total, oWins, Double(oWins)/total, ties, Double(ties)/total)
    }

    func lossRatio(forGamePiece gamePiece: GamePiece) -> Double {
        let total = Double(xWins + oWins + ties)
        return gamePiece == .X ? Double(oWins)/total : Double(xWins)/total
    }

    func winRatio(forGamePiece gamePiece: GamePiece) -> Double {
        let total = Double(xWins + oWins + ties)
        return gamePiece == .X ? Double(xWins)/total : Double(oWins)/total
    }
}

extension Array where Element == Outcome {
    func sum(forBoardLocation boardLocation: BoardLocation) -> Outcome {
        return self.reduce(Outcome(boardLocation: boardLocation, xWins: 0, oWins: 0, ties: 0)) { (result, outcome) -> Outcome in
            return Outcome(
                boardLocation: boardLocation,
                xWins: result.xWins + outcome.xWins,
                oWins: result.oWins + outcome.oWins,
                ties: result.ties + outcome.ties)
        }
    }

    func best(forGamePiece gamePiece: GamePiece?) -> Outcome? {
        guard let gamePiece = gamePiece else { return nil }
        return self.sorted(by: { (lhs, rhs) -> Bool in
            return lhs.lossRatio(forGamePiece: gamePiece) < rhs.lossRatio(forGamePiece: gamePiece) ||
                (lhs.lossRatio(forGamePiece: gamePiece) == rhs.lossRatio(forGamePiece: gamePiece) && lhs.winRatio(forGamePiece: gamePiece) > rhs.winRatio(forGamePiece: gamePiece))
        }).first
    }
}

typealias PlayOutcomes = [GameBoard: Outcome]
