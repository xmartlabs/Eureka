//  PickerInlineRow.swift
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

open class PickerInlineCell<T: Equatable> : Cell<T>, CellType {

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func setup() {
        super.setup()
        accessoryType = .none
        editingAccessoryType =  .none
    }

    open override func update() {
        super.update()
        selectionStyle = row.isDisabled ? .none : .default
    }

    open override func didSelect() {
        super.didSelect()
        row.deselect()
    }
}

// MARK: PickerInlineRow

open class _PickerInlineRow<T> : Row<PickerInlineCell<T>>, NoValueDisplayTextConformance where T: Equatable {

    public typealias InlineRow = PickerRow<T>
    open var options = [T]()
    open var noValueDisplayText: String?

    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A generic inline row where the user can pick an option from a picker view which shows and hides itself automatically
public final class PickerInlineRow<T> : _PickerInlineRow<T>, RowType, InlineRowType where T: Equatable {

    required public init(tag: String?) {
        super.init(tag: tag)
        onExpandInlineRow { cell, row, _ in
            let color = cell.detailTextLabel?.textColor
            row.onCollapseInlineRow { cell, _, _ in
                cell.detailTextLabel?.textColor = color
            }
            cell.detailTextLabel?.textColor = cell.tintColor
        }
    }

    public override func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            toggleInlineRow()
        }
    }

    public func setupInlineRow(_ inlineRow: InlineRow) {
        inlineRow.options = self.options
        inlineRow.displayValueFor = self.displayValueFor
        inlineRow.cell.height = { UITableViewAutomaticDimension }
    }
}

open class _DoublePickerInlineRow<A, B> : Row<PickerInlineCell<Tuple<A, B>>>, NoValueDisplayTextConformance where A: Equatable, B: Equatable {

    public typealias InlineRow = DoublePickerRow<A, B>

    /// Options for first component. Will be called often so should be O(1)
    public var firstOptions: (() -> [A]) = {[]}

    /// Options for second component given the selected value from the first component. Will be called often so should be O(1)
    public var secondOptions: ((A) -> [B]) = { _ in [] }
    
    public var noValueDisplayText: String?

    required public init(tag: String?) {
        super.init(tag: tag)
        self.displayValueFor = { [weak self] tuple in
            if let tuple = tuple {
                return String(describing: tuple.a) + ", " + String(describing: tuple.b)
            }
            return self?.noValueDisplayText
        }
    }
}

/// A generic inline row where the user can pick an option from a picker view which shows and hides itself automatically
public final class DoublePickerInlineRow<A, B> : _DoublePickerInlineRow<A, B>, RowType, InlineRowType where A: Equatable, B: Equatable {

    required public init(tag: String?) {
        super.init(tag: tag)
        onExpandInlineRow { cell, row, _ in
            let color = cell.detailTextLabel?.textColor
            row.onCollapseInlineRow { cell, _, _ in
                cell.detailTextLabel?.textColor = color
            }
            cell.detailTextLabel?.textColor = cell.tintColor
        }
    }

    public override func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            toggleInlineRow()
        }
    }

    public func setupInlineRow(_ inlineRow: InlineRow) {
        inlineRow.firstOptions = firstOptions
        inlineRow.secondOptions = secondOptions
        inlineRow.displayValueFor = self.displayValueFor
        inlineRow.cell.height = { UITableViewAutomaticDimension }
    }
}

open class _TriplePickerInlineRow<A, B, C> : Row<PickerInlineCell<Tuple3<A, B, C>>>, NoValueDisplayTextConformance
    where A: Equatable, B: Equatable, C: Equatable {

    public typealias InlineRow = TriplePickerRow<A, B, C>

    /// Options for first component. Will be called often so should be O(1)
    public var firstOptions: (() -> [A]) = {[]}
    /// Options for second component given the selected value from the first component. Will be called often so should be O(1)
    public var secondOptions: ((A) -> [B]) = { _ in [] }
    /// Options for third component given the selected value from the first and second components. Will be called often so should be O(1)
    public var thirdOptions: ((A, B) -> [C]) = {_, _ in []}

    open var noValueDisplayText: String?

    required public init(tag: String?) {
        super.init(tag: tag)
        self.displayValueFor = { [weak self] tuple in
            if let tuple = tuple {
                return String(describing: tuple.a) + ", " + String(describing: tuple.b) + ", " + String(describing: tuple.c)
            }
            return self?.noValueDisplayText
        }
    }
}

/// A generic inline row where the user can pick an option from a picker view which shows and hides itself automatically
public final class TriplePickerInlineRow<A, B, C> : _TriplePickerInlineRow<A, B, C>, RowType, InlineRowType
    where A: Equatable, B: Equatable, C: Equatable {

    required public init(tag: String?) {
        super.init(tag: tag)
        onExpandInlineRow { cell, row, _ in
            let color = cell.detailTextLabel?.textColor
            row.onCollapseInlineRow { cell, _, _ in
                cell.detailTextLabel?.textColor = color
            }
            cell.detailTextLabel?.textColor = cell.tintColor
        }
    }

    public override func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            toggleInlineRow()
        }
    }

    public func setupInlineRow(_ inlineRow: InlineRow) {
        inlineRow.firstOptions = firstOptions
        inlineRow.secondOptions = secondOptions
        inlineRow.thirdOptions = thirdOptions
        inlineRow.displayValueFor = self.displayValueFor
        inlineRow.cell.height = { UITableViewAutomaticDimension }
    }
}
