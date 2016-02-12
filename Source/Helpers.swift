//  Helpers.swift
//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2015 Xmartlabs ( http://xmartlabs.com )
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
        if isFirstResponder() { return self }
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
        if let compoundPredicate = self as? NSCompoundPredicate{
            for subPredicate in compoundPredicate.subpredicates{
                ret.appendContentsOf(subPredicate.predicateVars)
            }
        }
        else if let comparisonPredicate = self as? NSComparisonPredicate{
            ret.appendContentsOf(comparisonPredicate.leftExpression.expressionVars)
            ret.appendContentsOf(comparisonPredicate.rightExpression.expressionVars)
        }
        return ret
    }
}

extension NSExpression {
    
    var expressionVars: [String] {
        switch expressionType{
            case .FunctionExpressionType, .VariableExpressionType:
                let str = "\(self)"
                if let range = str.rangeOfString("."){
                    return [str.substringWithRange(str.startIndex.advancedBy(1)..<range.startIndex)]
                }
                else{
                    return [str.substringFromIndex(str.startIndex.advancedBy(1))]
                }
            default:
                return []
        }
    }
}
