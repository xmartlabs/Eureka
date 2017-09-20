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
                    return [String(str[str.characters.index(str.startIndex, offsetBy: 1)..<range.lowerBound])]
                } else {
                    return [String(str[str.characters.index(str.startIndex, offsetBy: 1)...])]
                }
            default:
                return []
        }
    }
}
