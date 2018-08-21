//
//  DispatchTime+Future.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import Foundation

public extension DispatchTime {
    static func future(seconds: TimeInterval) -> DispatchTime {
        return self.future(milliseconds: Int(seconds * TimeInterval(1000)))
    }
    
    static func future(milliseconds: Int) -> DispatchTime {
        return DispatchTime.now() + .milliseconds(milliseconds)
    }
}
