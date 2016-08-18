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

open class RowOf<T: Equatable>: BaseRow {
    
    /// The typed value of this row.
    public var value : T?{
        didSet {
            guard value != oldValue else { return }
            guard let form = section?.form else { return }
            if let delegate = form.delegate {
                delegate.rowValueHasBeenChanged(self, oldValue: oldValue, newValue: value)
                callbackOnChange?()
            }
            guard let t = tag else { return }
            form.tagToValues[t] = (value as AnyObject) 
            if let rowObservers = form.rowObservers[t]?[.hidden]{
                for rowObserver in rowObservers {
                    (rowObserver as? Hidable)?.evaluateHidden()
                }
            }
            if let rowObservers = form.rowObservers[t]?[.disabled]{
                for rowObserver in rowObservers {
                    (rowObserver as? Disableable)?.evaluateDisabled()
                }
            }
        }
    }
    
    /// The untyped value of this row.
    public override var baseValue: Any? {
        get { return value }
        set { value = newValue as? T }
    }
    
    /// Variable used in rows with options that serves to generate the options for that row.
    public var dataProvider: DataProvider<T>?
    
    /// Block variable used to get the String that should be displayed for the value of this row.
    public var displayValueFor : ((T?) -> String?)? = {
        if let t = $0 {
            return String(describing: t)
        }
        return nil
    }
    
    public required init(tag: String?){
        super.init(tag: tag)
    }
}

/// Generic class that represents an Eureka row.
open class Row<Cell: CellType>: RowOf<Cell.Value>, TypedRowType where Cell: BaseCell {
    
    /// Responsible for creating the cell for this row.
    public var cellProvider = CellProvider<Cell>()
    
    /// The type of the cell associated to this row.
    public let cellType: Cell.Type! = Cell.self
    
    private var _cell: Cell! {
        didSet {
            RowDefaults.cellSetup["\(type(of: self))"]?(_cell, self)
            (callbackCellSetup as? ((Cell) -> ()))?(_cell)
        }
    }
    
    /// The cell associated to this row.
    public var cell : Cell! {
        return _cell ?? {
            let result = cellProvider.createCell(self.cellStyle)
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
    override public func updateCell() {
        super.updateCell()
        cell.update()
        customUpdateCell()
        RowDefaults.cellUpdate["\(type(of: self))"]?(cell, self)
        callbackCellUpdate?()
    }
    
    /**
     Method called when the cell belonging to this row was selected. Must call the corresponding method in its cell.
     */
    public override func didSelect() {
        super.didSelect()
        if !isDisabled {
            cell?.didSelect()
        }
        customDidSelect()
        callbackCellOnSelection?()
    }
    
    /**
     Method that is responsible for highlighting the cell.
     */
    override public func highlightCell() {
        super.highlightCell()
        cell.highlight()
        RowDefaults.onCellHighlight["\(type(of: self))"]?(cell, self)
        callbackOnCellHighlight?()
    }
    
    /**
     Method that is responsible for unhighlighting the cell.
     */
    public override func unhighlightCell() {
        super.unhighlightCell()
        cell.unhighlight()
        RowDefaults.onCellUnHighlight["\(type(of: self))"]?(cell, self)
        callbackOnCellUnHighlight?()
    }
    
    /**
     Will be called inside `didSelect` method of the row. Can be used to customize row selection from the definition of the row.
     */
    public func customDidSelect(){}
    
    /**
     Will be called inside `updateCell` method of the row. Can be used to customize reloading a row from its definition.
     */
    public func customUpdateCell(){}
    
}


