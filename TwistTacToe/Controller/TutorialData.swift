//
//  TutorialData.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import Foundation

struct TutorialData {
    
    static let playHistory: [GameStateSnapshot] = [
        (0, .xPlaysNext, GameBoard.newWithPattern([
            __, __, __,
            __, __, __,
            __, __, __])),
        (1, .oPlaysNext, GameBoard.newWithPattern([
            __, __, __,
            _X, __, __,
            __, __, __])),
        (2, .boardNeedsRotation, GameBoard.newWithPattern([
            __, __, __,
            _X, __, __,
            _O, __, __])),
        (3, .xPlaysNext, GameBoard.newWithPattern([
            __, __, __,
            _O, __, __,
            __, _X, __])),
        (4, .oPlaysNext, GameBoard.newWithPattern([
            __, __, _X,
            _O, __, __,
            __, _X, __])),
        (5, .boardNeedsRotation, GameBoard.newWithPattern([
            __, __, _X,
            _O, _O, __,
            __, _X, __])),
        (6, .xPlaysNext, GameBoard.newWithPattern([
            __, __, _X,
            __, _X, __,
            __, _O, _O])),
        (7, .oPlaysNext, GameBoard.newWithPattern([
            __, __, _X,
            __, _X, __,
            _X, _O, _O])),
        (8, .boardNeedsRotation, GameBoard.newWithPattern([
            _O, __, _X,
            __, _X, __,
            _X, _O, _O])),
        (9, .gameOver, GameBoard.newWithPattern([
            _O, _O, _O,
            _X, _X, __,
            __, __, _X])),
    ]
    
    static let tutorialText: [String] = [
        "X always plays first.",
        "Then O plays.",
        "Next, all the pieces on the board rotate according to the numeric pattern (1 -> 2, 2 -> 3, ... 9 -> 1)",
        "X plays again.",
        "O plays again.",
        "All pieces rotate.",
        "The next (3rd) rotation is the first opportunity for someone to win.",
        "In order to win, your pieces must rotate into a winning position (X has not won here).",
        "All pieces rotate.",
        "O wins!",
    ]
    
    static func getRotationPattern() throws -> RotationPattern {
        return try RotationPattern(withMapping: [
            5, 6, 2,
            0, 3, 7,
            8, 1, 4
        ])
    }
}
