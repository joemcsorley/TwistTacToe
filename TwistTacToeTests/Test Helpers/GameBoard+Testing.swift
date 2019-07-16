//
//  GameBoard+Testing.swift
//  TwistTacToeTests
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import Foundation
@testable import TwistTacToe

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
