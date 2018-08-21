//
//  GameBoard+Testing.swift
//  TwistTacToeTests
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import Foundation
@testable import TwistTacToe

extension GameBoard {
    static func newWithPattern(_ pattern: [String]) -> GameBoard {
        var xBits: BoardBits = 0
        var oBits: BoardBits = 0
        
        for i in boardRange {
            xBits |= pattern[i] == "X" ? 1 << i : 0
        }
        for i in boardRange {
            oBits |= pattern[i] == "O" ? 1 << i : 0
        }
        return GameBoard(xBits: xBits, oBits: oBits)
    }
    
//    mutating func set(gamePiece: GamePiece?, atLocation boardLocation: BoardLocation) {
//        let bitmask: BoardBits = 1 << boardLocation
//        if gamePiece == .X {
//            xBits |= bitmask
//        }
//        else if gamePiece == .O {
//            oBits |= bitmask
//        }
//        else {
//            let inverseMask = ~bitmask
//            xBits &= inverseMask
//            oBits &= inverseMask
//        }
//    }
    
    func prettyPrint() {
        func boardRangeToString(_ range: [Int]) throws -> String {
            var boardRangeString = ""
            for i in range {
                let symbol = try gamePiece(atLocation: i)
                boardRangeString += (symbol?.rawValue ?? "_") + ", "
            }
            return boardRangeString
        }
        
        do {
            print(try boardRangeToString([0, 1, 2]))
            print(try boardRangeToString([3, 4, 5]))
            print(try boardRangeToString([6, 7, 8]))
        } catch {
            print("Something went wrong pretty-printing the board")
        }
    }
}

let _X = "X"
let _O = "O"
let __ = ""

let unfinishedBoard1 = GameBoard.newWithPattern([
    _X, __, _O,
    _O, __, __,
    _X, __, __
])

let unfinishedBoard2 = GameBoard.newWithPattern([
    _X, __, _O,
    _O, __, __,
    _X, __, _X
])

let winningXBoard1 = GameBoard.newWithPattern([
    _X, __, _O,
    _O, _X, _O,
    _O, _X, _X
])

let winningOBoard1 = GameBoard.newWithPattern([
    _O, _O, _O,
    _X, __, _X,
    _X, _O, _X
])

let tiedBoard1 = GameBoard.newWithPattern([
    _O, _X, _X,
    _O, __, _X,
    _O, _O, _X
])

let noWinnerBoard1 = GameBoard.newWithPattern([
    _O, _X, _X,
    __, _X, _O,
    _O, _O, _X
])
