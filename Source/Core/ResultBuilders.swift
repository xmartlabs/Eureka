//  ResultBuilders.swift
//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2022 Xmartlabs ( http://xmartlabs.com )
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

#if swift(>=5.4)
public protocol RowsProvider {
    var rows: [BaseRow] { get }
}

extension BaseRow: RowsProvider {
    public var rows: [BaseRow] { [self] }
}

extension Array: RowsProvider where Element == BaseRow {
    public var rows: [BaseRow] { self }
}

@resultBuilder
public struct SectionBuilder {
    public static func buildBlock(_ components: RowsProvider...) -> [BaseRow] {
        components.flatMap { $0.rows }
    }

    public static func buildFinalResult(_ components: [BaseRow]) -> Section {
        .init(components)
    }
    
    public static func buildEither(first components: [RowsProvider]) -> [BaseRow] {
        components.flatMap { $0.rows }
    }
    
    public static func buildEither(second components: [RowsProvider]) -> [BaseRow] {
        components.flatMap { $0.rows }
    }

    public static func buildOptional(_ components: [RowsProvider]?) -> [BaseRow] {
        components?.flatMap { $0.rows } ?? []
    }
    
    public static func buildExpression(_ expression: String?) -> [BaseRow] {
        [.init(tag: expression)]
    }
    
    public static func buildExpression(_ expression: BaseRow?) -> [BaseRow] {
        expression.flatMap { [$0] } ?? []
    }
}
#endif
