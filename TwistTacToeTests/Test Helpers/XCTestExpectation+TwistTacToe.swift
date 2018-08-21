//
//  XCTestExpectation+TwistTacToe.swift
//  TwistTacToeTests
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import XCTest

extension XCTestExpectation {
    func assertCompletion(withinTimeout timeout: TimeInterval = 1, file: StaticString = #file, line: UInt = #line) {
        let result = XCTWaiter.wait(for: [self], timeout: timeout)
        switch result {
        case .timedOut:
            XCTFail("Failed to complete expectation with timeout of \(timeout).", file: file, line: line)
        case .incorrectOrder:
            XCTFail("Failed to execute in correct order.", file: file, line: line)
        case .interrupted:
            XCTFail("Failed with interruption.", file: file, line: line)
        case .invertedFulfillment:
            XCTFail("Failed because of inverted fulfillment.", file: file, line: line)
        case .completed: // Success
            return
        }
    }
    
    func assertTimeout(withinTimeout timeout: TimeInterval = 0.1, file: StaticString = #file, line: UInt = #line) {
        let result = XCTWaiter.wait(for: [self], timeout: timeout)
        switch result {
        case .timedOut: // Success
            return
        case .incorrectOrder:
            XCTFail("Failed to execute in correct order.", file: file, line: line)
        case .interrupted:
            XCTFail("Failed with interruption.", file: file, line: line)
        case .invertedFulfillment:
            XCTFail("Failed because of inverted fulfillment.", file: file, line: line)
        case .completed:
            XCTFail("Expected a timout. Instead got completion.", file: file, line: line)
        }
    }
}
