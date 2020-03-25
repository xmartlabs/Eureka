//  RuleLength.swift
//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2016 Xmartlabs SRL ( http://xmartlabs.com )
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

private enum Comparator<Unit: Comparable>: CustomStringConvertible {
    case equal(to: Unit)
    case greater(than: Unit)
    case less(than: Unit)
    case `in`(ClosedRange<Unit>)

    var description: String {
        switch self {
        case let .equal(to: number):
            return "must be \(number)"
        case let .greater(than: minimum):
            return "must greater than \(minimum)"
        case let .less(than: maximum):
            return "must less than \(maximum)"
        case let .in(range):
            return "must be in \(range.lowerBound)...\(range.upperBound) range"
        }
    }

    func contains(_ value: Unit) -> Bool {
        switch self {
        case let .equal(to: exactValue):
            return value == exactValue
        case let .greater(than: minimum):
            return value > minimum
        case let .less(than: maximum):
            return value < maximum
        case let .in(range):
            return range.contains(value)
        }
    }
}

public struct Length: RowRule, CustomStringConvertible {
    private let condition: Comparator<Int>

    public init(longerThan minimumLength: UInt) {
        condition = .greater(than: Int(minimumLength))
    }

    public init(shorterThan maximumLength: UInt) {
        condition = .less(than: Int(maximumLength))
    }

    public init(exactly length: UInt) {
        condition = .equal(to: Int(length))
    }

    public init(in validRange: ClosedRange<Int>) {
        condition = .in(validRange)
    }

    public func allows(_ value: String?, in _: Form) -> Bool {
        guard let value = value, !value.isEmpty else { return true }
        return condition.contains(value.count)
    }

    public var description: String {
        return "Length \(condition.description)"
    }
}

public struct Value<RowValue: Comparable>: RowRule {
    private let condition: Comparator<RowValue>

    public init(exactly exactValue: RowValue) {
        condition = .equal(to: exactValue)
    }

    public init(greaterThan minimum: RowValue) {
        condition = .greater(than: minimum)
    }

    public init(lessThan maximum: RowValue) {
        condition = .less(than: maximum)
    }

    public func allows(_ value: RowValue?, in form: Form) -> Bool {
        guard let value = value else { return true }
        return condition.contains(value)
    }
}
