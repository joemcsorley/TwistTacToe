//
//  UIColor+TwistTacToe.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import UIKit

extension UIColor {
    /// Initializes a color given a hex string. The string can include or exclude the "#" character.
    ///
    /// - Parameter hex: a 6 character string representing a hex color value
    convenience init(_ hex: String) {
        let cleanHex = hex.replacingOccurrences(of: "#", with: "")
        let characterset = CharacterSet(charactersIn: "abcdefABCDEF0123456789")
        let defaultColor = (CGFloat(213), CGFloat(38), CGFloat(181), CGFloat(1))
        
        // verify the correct number of characters
        guard cleanHex.count == 6 else {
            self.init(red: defaultColor.0, green: defaultColor.1, blue: defaultColor.2, alpha: defaultColor.3)
            return
        }
        // verify all characters are valid hexidecimal characters
        guard cleanHex.rangeOfCharacter(from: characterset.inverted) == nil else {
            self.init(red: defaultColor.0, green: defaultColor.1, blue: defaultColor.2, alpha: defaultColor.3)
            return
        }
        
        let scanner = Scanner(string: cleanHex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        if !scanner.scanHexInt64(&rgbValue) {
            self.init(red: defaultColor.0, green: defaultColor.1, blue: defaultColor.2, alpha: defaultColor.3)
        } else {
            let r = (rgbValue & 0xff0000) >> 16
            let g = (rgbValue & 0xff00) >> 8
            let b = rgbValue & 0xff
            
            self.init(red: CGFloat(r) / 0xff, green: CGFloat(g) / 0xff, blue: CGFloat(b) / 0xff, alpha: 1)
        }
    }
    
    func withBrightnessComponent(_ brightness: CGFloat) -> UIColor {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        self.getHue(&hue, saturation: &saturation, brightness: nil, alpha: &alpha)
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    func withSaturationComponent(_ saturation: CGFloat) -> UIColor {
        var hue: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        self.getHue(&hue, saturation: nil, brightness: &brightness, alpha: &alpha)
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
}
