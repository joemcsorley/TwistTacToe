//
//  UIView+TwistTacToe.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import UIKit

extension UIView {
    func addSubviewWithAutoLayout(_ subView: UIView) {
        subView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subView)
    }

    var normalizedLayoutGuide: UILayoutGuide {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide
        }
        else {
            return layoutMarginsGuide
        }
    }
}
