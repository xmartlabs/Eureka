//  Helpers.swift
//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2016 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import UIKit

extension UIView {

    public func findFirstResponder() -> UIView? {
        if isFirstResponder { return self }
        for subView in subviews {
            if let firstResponder = subView.findFirstResponder() {
                return firstResponder
            }
        }
        return nil
    }

    public func formCell() -> BaseCell? {
        if self is UITableViewCell {
            return self as? BaseCell
        }
        return superview?.formCell()
    }
}

extension NSPredicate {

    var predicateVars: [String] {
        var ret = [String]()
        if let compoundPredicate = self as? NSCompoundPredicate {
            for subPredicate in compoundPredicate.subpredicates where subPredicate is NSPredicate {
                ret.append(contentsOf: (subPredicate as! NSPredicate).predicateVars)
            }
        } else if let comparisonPredicate = self as? NSComparisonPredicate {
            ret.append(contentsOf: comparisonPredicate.leftExpression.expressionVars)
            ret.append(contentsOf: comparisonPredicate.rightExpression.expressionVars)
        }
        return ret
    }
}

extension NSExpression {

    var expressionVars: [String] {
        switch expressionType {
            case .function, .variable:
                let str = "\(self)"
                if let range = str.range(of: ".") {
                    return [str.substring(with: str.characters.index(str.startIndex, offsetBy: 1)..<range.lowerBound)]
                } else {
                    return [str.substring(from: str.characters.index(str.startIndex, offsetBy: 1))]
                }
            default:
                return []
        }
    }
}

extension UIColor {
    /// Initializes UIColor from hex color in "#ARGB" format
    convenience init? (eureka_hexColor hexColor: String) {
        var rgbValue : UInt32 = 0
        let scanner = Scanner(string: hexColor)
        scanner.scanLocation = hexColor.hasPrefix("#") ? 1 : 0;
        if scanner.scanHexInt32(&rgbValue) {
            var alpha = CGFloat(1.0)
            if hexColor.characters.count >= 8 {
                alpha = CGFloat((rgbValue & 0xFF0000) >> 24) / 255.0
            }
            let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((rgbValue & 0xFF00) >> 8) / 255.0
            let blue = CGFloat((rgbValue & 0xFF)) / 255.0
            
            self.init(red: red, green: green, blue: blue, alpha: alpha)
            return
        }
        
        return nil
    }
}
