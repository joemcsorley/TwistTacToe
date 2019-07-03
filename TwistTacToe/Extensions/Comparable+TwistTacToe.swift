//
//  Comparable+TwistTacToe.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import Foundation

extension Comparable {
    func clamp(_ minValue: Self, _ maxValue: Self) -> Self {
        return min(maxValue, max(minValue, self))
    }
}
