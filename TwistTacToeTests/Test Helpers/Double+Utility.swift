//
//  Double+Utility.swift
//  TwistTacToeTests
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import Foundation

extension Double {
    func isEqualTo(_ d: Double, withVariance v: Double = Double.ulpOfOne) -> Bool {
        return fabs(self-d) < v
    }
}
