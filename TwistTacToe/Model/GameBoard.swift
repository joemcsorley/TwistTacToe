//
//  GameBoard.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import Foundation

// Class Documentation:

// This is an opaque value type that represents a 3x3 tic-tac-toe game board.
// Board locations are represented externally as Ints 0-8:
// 0 | 1 | 2
// --+---+--
// 3 | 4 | 5
// --+---+--
// 6 | 7 | 8

// Internally, board locations are represented as two Int16s, the low order
// 9 bits of which represent occupied X, and O locations.  The lowest order bit
// represents board location 0, etc.

struct GameBoard: Equatable {
    private(set) var xBits: BoardBits = 0
    private(set) var oBits: BoardBits = 0
    private(set) var isGameOver: Bool = false
    private(set) var gameResult: GameResult = .unfinished
    
    var isFull: Bool {
        return openLocations().count <= 1
    }
    
    // MARK: - Init / Setup
    
    init() {}
    
    init(xBits: BoardBits, oBits: BoardBits) {
        self.xBits = xBits
        self.oBits = oBits
        self.gameResult = gameResult(forXBits: xBits, oBits: oBits)
        self.isGameOver = gameResult != .unfinished
    }

    func gameResult(forXBits xBits: BoardBits, oBits: BoardBits) -> GameResult {
        let xHasWinningCombo = hasWinningCombination(xBits)
        let oHasWinningCombo = hasWinningCombination(oBits)
        if xHasWinningCombo && oHasWinningCombo { return .tie }
        else if xHasWinningCombo { return .X }
        else if oHasWinningCombo { return .O }
        else if isFull { return .tie }
        else { return .unfinished }
    }

    static func new(withXLocations xLocations: [BoardLocation], oLocations: [BoardLocation]) throws -> GameBoard {
        var board = GameBoard()
        try xLocations.forEach { board = try board.newByPlaying(.X, atLocation: $0) }
        try oLocations.forEach { board = try board.newByPlaying(.O, atLocation: $0) }
        return GameBoard(xBits: board.xBits, oBits: board.oBits)
    }

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

    func newByPlaying(_ symbol: GamePiece, atLocation boardLocation: BoardLocation) throws -> GameBoard {
        guard boardRange.contains(boardLocation) else { throw GameBoardError.invalidBoardLocation }
        guard isEmpty(boardLocation: boardLocation) else { throw GameBoardError.boardLocationAlreadyOccupied }
        let bitLoc: BoardBits = 1 << boardLocation
        var newXBits = xBits
        var newOBits = oBits
        if symbol == .X { newXBits |= bitLoc }
        else if symbol == .O { newOBits |= bitLoc }
        return GameBoard(xBits: newXBits, oBits: newOBits)
    }
    
    // MARK: - Helpers
    
    func isEmpty(boardLocation: BoardLocation) -> Bool {
        let bitLoc: BoardBits = 1 << boardLocation
        return (xBits | oBits) & bitLoc == 0
    }
    
    func openLocations() -> [BoardLocation] {
        var locations: [BoardLocation] = []
        var occupiedLocations = xBits | oBits
        for i in boardRange {
            if occupiedLocations & 1 == 0 {
                locations.append(i)
            }
            occupiedLocations >>= 1
        }
        return locations
    }
    
    func gamePiece(atLocation boardLocation: BoardLocation) throws -> GamePiece? {
        guard boardRange.contains(boardLocation) else { throw GameBoardError.invalidBoardLocation }
        let bitLoc: BoardBits = 1 << boardLocation
        if xBits & bitLoc == bitLoc { return .X }
        else if oBits & bitLoc == bitLoc { return .O }
        else { return nil }
    }
    
    // Return a random location on the board that is currently blank.
    func randomOpenLocation() throws -> BoardLocation {
        guard !isFull else { throw GameBoardError.boardIsFull }
        let boardLocations = openLocations()
        let locationCount = boardLocations.count
        let randomIndex = Int(arc4random_uniform(UInt32(locationCount)))
        return boardLocations[randomIndex]
    }
    
    // MARK: - Equatable
    
    static func ==(lhs: GameBoard, rhs: GameBoard) -> Bool {
        return lhs.xBits == rhs.xBits && lhs.oBits == rhs.oBits
    }
}

// MARK: - Board Helper Definitions

let _X = "X"
let _O = "O"
let __ = ""

typealias BoardLocation = Int
typealias BoardBits = Int16

enum GamePiece: String {
    case X
    case O
    
    var opposingPiece: GamePiece {
        return self == .X ? .O : .X
    }
}

enum GameResult: String {
    case X
    case O
    case tie
    case unfinished
    
    var winningSymbol: GamePiece? {
        return GamePiece(rawValue: rawValue)
    }
}

enum GameBoardError: Error {
    case invalidBoardLocation
    case boardLocationAlreadyOccupied
    case boardIsFull
}

func hasWinningCombination(_ playerBits: BoardBits) -> Bool {
    for winningCombo in gameWinningCombinations {
        if playerBits & winningCombo == winningCombo {
            return true
        }
    }
    return false
}

let boardRange = 0..<9

let gameWinningCombinations: [BoardBits] = [7, 56, 448, 73, 146, 292, 273, 84]
// BoardLocations: BoardBits values
// [0, 1, 2]: 000000111 = 7
// [3, 4, 5]: 000111000 = 56
// [6, 7, 8]: 111000000 = 448
// [0, 3, 6]: 001001001 = 73
// [1, 4, 7]: 010010010 = 146
// [2, 5, 8]: 100100100 = 292
// [0, 4, 8]: 100010001 = 273
// [2, 4, 6]: 001010100 = 84

// BoardLocation: BoardBits value
// 0: 1
// 1: 2
// 2: 4
// 3: 8
// 4: 16
// 5: 32
// 6: 64
// 7: 128
// 8: 256
