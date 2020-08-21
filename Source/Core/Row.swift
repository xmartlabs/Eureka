//  Row.swift
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

open class RowOf<T>: BaseRow where T: Equatable {

    private var _value: T? {
        didSet {
            guard _value != oldValue else { return }
            forceTriggerDidChangeValue(value: _value)
        }
    }
    
    public func forceTriggerDidUpdateValue(value: T?) {
        guard let form = section?.form else { return }
            if let delegate = form.delegate {
                delegate.valueHasBeenChanged(for: self, oldValue: oldValue, newValue: value)
                callbackOnChange?()
            }
            guard let t = tag else { return }
            form.tagToValues[t] = (value != nil ? value! : NSNull())
            if let rowObservers = form.rowObservers[t]?[.hidden] {
                for rowObserver in rowObservers {
                    (rowObserver as? Hidable)?.evaluateHidden()
                }
            }
            if let rowObservers = form.rowObservers[t]?[.disabled] {
                for rowObserver in rowObservers {
                    (rowObserver as? Disableable)?.evaluateDisabled()
                }
            }
            if let rowObservers = form.rowObservers[t]?[.needsUpdate] {
                for rowObserver in rowObservers {
                    (rowObserver as? Updatable)?.updateAfterEnvironmentChange()
                }
            }
    }

    /// The typed value of this row.
    open var value: T? {
        set (newValue) {
            _value = newValue
            guard let _ = section?.form else { return }
            wasChanged = true
            if validationOptions.contains(.validatesOnChange) || (wasBlurred && validationOptions.contains(.validatesOnChangeAfterBlurred)) ||  (!isValid && validationOptions != .validatesOnDemand) {
                validate()
            }
        }
        get {
            return _value
        }
    }
    
    /// The reset value of this row. Sets the value property to the value of this row on the resetValue method call.
    open var resetValue: T?

    /// The untyped value of this row.
    public override var baseValue: Any? {
        get { return value }
        set { value = newValue as? T }
    }

    /// Block variable used to get the String that should be displayed for the value of this row.
    public var displayValueFor: ((T?) -> String?)? = {
        return $0.map { String(describing: $0) }
    }

    public required init(tag: String?) {
        super.init(tag: tag)
    }

    public internal(set) var rules: [RowRuleWrapping<T>] = []

    @discardableResult
    public override func validate(quietly: Bool = false) -> [ValidationError] {
        guard let form = section?.form else { return [] }
        var vErrors = [ValidationError]()
        #if swift(>=4.1)
        vErrors = rules.compactMap { $0.closure(value, form) }
        #else
        vErrors = limits.flatMap { $0.closure(value, form) }
        #endif
        if (!quietly) {
            validationErrors = vErrors
        }
        return vErrors
    }
    
    /// Resets the value of the row. Setting it's value to it's reset value.
    public func resetRowValue() {
        value = resetValue
    }

    @discardableResult
    public func add<Rule: RowRule>(_ rule: Rule, _ message: String, id: String?) -> Self where Rule.RowValue == T {
        let validationError = ValidationError(msg: message)
        let closure: (T?, Form) -> ValidationError? = {
            return rule.allows($0, in: $1) ? nil : validationError
        }
        rules.append(RowRuleWrapping(closure: closure, linkedError: validationError, id: id))
        return self
    }

    public func removeRule(by identifier: String) {
        rules.removeAll(where: { $0.id == identifier })
    }

    public func removeAllRules() {
        validationErrors.removeAll()
        rules.removeAll()
    }

}

/// Generic class that represents an Eureka row.
open class Row<Cell: CellType>: RowOf<Cell.Value>, TypedRowType where Cell: BaseCell {
    /// In a need to customize initialization of a cell, this is the method that should be overridden. By default it returns a cell from `cellProvider`
    open func newCell() -> Cell {
        return cellProvider.makeCell(style: self.cellStyle)
    }

    /// Responsible for creating the cell for this row.
    public var cellProvider = CellProvider<Cell>()

    /// The type of the cell associated to this row.
    public let cellType: Cell.Type! = Cell.self

    private var _cell: Cell! {
        didSet {
            RowDefaults.cellSetup["\(type(of: self))"]?(_cell, self)
            (callbackCellSetup as? ((Cell) -> Void))?(_cell)
        }
    }

    /// The cell associated to this row.
    public var cell: Cell! {
        return _cell ?? {
            let result = newCell()
            result.row = self
            result.setup()
            _cell = result
            return _cell
        }()
    }

    /// The untyped cell associated to this row
    public override var baseCell: BaseCell { return cell }

    public required init(tag: String?) {
        super.init(tag: tag)
    }

    /**
     Method that reloads the cell
     */
    override open func updateCell() {
        super.updateCell()
        cell.update()
        customUpdateCell()
        RowDefaults.cellUpdate["\(type(of: self))"]?(cell, self)
        callbackCellUpdate?()
    }

    /**
     Method called when the cell belonging to this row was selected. Must call the corresponding method in its cell.
     */
    open override func didSelect() {
        super.didSelect()
        if !isDisabled {
            cell?.didSelect()
        }
        customDidSelect()
        callbackCellOnSelection?()
    }

    /**
     Will be called inside `didSelect` method of the row. Can be used to customize row selection from the definition of the row.
     */
    open func customDidSelect() {}

    /**
     Will be called inside `updateCell` method of the row. Can be used to customize reloading a row from its definition.
     */
    open func customUpdateCell() {}

}
