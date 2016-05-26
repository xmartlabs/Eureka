//  RowType.swift
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

protocol Disableable : Taggable {
    func evaluateDisabled()
    var disabled : Condition? { get set }
    var isDisabled : Bool { get }
}

protocol Hidable: Taggable {
    func evaluateHidden()
    var hidden : Condition? { get set }
    var isHidden : Bool { get }
}

public protocol KeyboardReturnHandler : BaseRowType {
    var keyboardReturnType : KeyboardReturnTypeConfiguration? { get set }
}

public protocol Taggable : AnyObject {
    var tag: String? { get set }
}

public protocol BaseRowType: Taggable {
    
    /// The cell associated to this row.
    var baseCell: BaseCell! { get }
    
    /// The section to which this row belongs.
    var section: Section? { get }
    
    /// Parameter used when creating the cell for this row.
    var cellStyle : UITableViewCellStyle { get set }
    
    /// The title will be displayed in the textLabel of the row.
    var title: String? { get set }
    
    /**
     Method that should re-display the cell
     */
    func updateCell()
    
    /**
     Method called when the cell belonging to this row was selected. Must call the corresponding method in its cell.
     */
    func didSelect()
}

public protocol TypedRowType: BaseRowType {
    
    associatedtype Value: Equatable
    associatedtype Cell: BaseCell, TypedCellType
    
    /// The typed cell associated to this row.
    var cell : Self.Cell! { get }
    
    /// The typed value this row stores.
    var value : Self.Value? { get set }
}

/**
 *  Protocol that every row type has to conform to.
 */
public protocol RowType {
    init(_ tag: String?, @noescape _ initializer: (Self -> ()))
}

extension RowType where Self: TypedRowType, Self: BaseRow, Self.Cell.Value == Self.Value {
    
    /**
     Default initializer for a row
     */
    public init(_ tag: String? = nil, @noescape _ initializer: (Self -> ()) = { _ in }) {
        self.init(tag: tag)
        RowDefaults.rowInitialization["\(self.dynamicType)"]?(self)
        initializer(self)
    }
}


extension RowType where Self: TypedRowType, Self: BaseRow, Self.Cell.Value == Self.Value {
    
    /// The default block executed when the cell is updated. Applies to every row of this type.
    public static var defaultCellUpdate:((Cell, Self) -> ())? {
        set {
            if let newValue = newValue {
                let wrapper : (BaseCell, BaseRow) -> Void = { (baseCell: BaseCell, baseRow: BaseRow) in
                    newValue(baseCell as! Cell, baseRow as! Self)
                }
                RowDefaults.cellUpdate["\(self)"] = wrapper
                RowDefaults.rawCellUpdate["\(self)"] = newValue
            }
            else {
                RowDefaults.cellUpdate["\(self)"] = nil
                RowDefaults.rawCellUpdate["\(self)"] = nil
            }
        }
        get{ return RowDefaults.rawCellUpdate["\(self)"] as? ((Cell, Self) -> ()) }
    }
    
    /// The default block executed when the cell is created. Applies to every row of this type.
    public static var defaultCellSetup:((Cell, Self) -> ())? {
        set {
            if let newValue = newValue {
                let wrapper : (BaseCell, BaseRow) -> Void = { (baseCell: BaseCell, baseRow: BaseRow) in
                    newValue(baseCell as! Cell, baseRow as! Self)
                }
                RowDefaults.cellSetup["\(self)"] = wrapper
                RowDefaults.rawCellSetup["\(self)"] = newValue
            }
            else {
                RowDefaults.cellSetup["\(self)"] = nil
                RowDefaults.rawCellSetup["\(self)"] = nil
            }
        }
        get{ return RowDefaults.rawCellSetup["\(self)"] as? ((Cell, Self) -> ()) }
    }
    
    /// The default block executed when the cell becomes first responder. Applies to every row of this type.
    public static var defaultOnCellHighlight:((Cell, Self) -> ())? {
        set {
            if let newValue = newValue {
                let wrapper : (BaseCell, BaseRow) -> Void = { (baseCell: BaseCell, baseRow: BaseRow) in
                    newValue(baseCell as! Cell, baseRow as! Self)
                }
                RowDefaults.onCellHighlight["\(self)"] = wrapper
                RowDefaults.rawOnCellHighlight["\(self)"] = newValue
            }
            else {
                RowDefaults.onCellHighlight["\(self)"] = nil
                RowDefaults.rawOnCellHighlight["\(self)"] = nil
            }
        }
        get{ return RowDefaults.rawOnCellHighlight["\(self)"] as? ((Cell, Self) -> ()) }
    }
    
    /// The default block executed when the cell resigns first responder. Applies to every row of this type.
    public static var defaultOnCellUnHighlight:((Cell, Self) -> ())? {
        set {
            if let newValue = newValue {
                let wrapper : (BaseCell, BaseRow) -> Void = { (baseCell: BaseCell, baseRow: BaseRow) in
                    newValue(baseCell as! Cell, baseRow as! Self)
                }
                RowDefaults.onCellUnHighlight ["\(self)"] = wrapper
                RowDefaults.rawOnCellUnHighlight["\(self)"] = newValue
            }
            else {
                RowDefaults.onCellUnHighlight["\(self)"] = nil
                RowDefaults.rawOnCellUnHighlight["\(self)"] = nil
            }
        }
        get { return RowDefaults.rawOnCellUnHighlight["\(self)"] as? ((Cell, Self) -> ()) }
    }
    
    /// The default block executed to initialize a row. Applies to every row of this type.
    public static var defaultRowInitializer:(Self -> ())? {
        set {
            if let newValue = newValue {
                let wrapper : (BaseRow) -> Void = { (baseRow: BaseRow) in
                    newValue(baseRow as! Self)
                }
                RowDefaults.rowInitialization["\(self)"] = wrapper
                RowDefaults.rawRowInitialization["\(self)"] = newValue
            }
            else {
                RowDefaults.rowInitialization["\(self)"] = nil
                RowDefaults.rawRowInitialization["\(self)"] = nil
            }
        }
        get { return RowDefaults.rawRowInitialization["\(self)"] as? (Self -> ()) }
    }
    
    /**
     Sets a block to be called when the value of this row changes.
     
     - returns: this row
     */
    public func onChange(callback: Self -> ()) -> Self{
        callbackOnChange = { [unowned self] in callback(self) }
        return self
    }
    
    /**
     Sets a block to be called when the cell corresponding to this row is refreshed.
     
     - returns: this row
     */
    public func cellUpdate(callback: ((cell: Cell, row: Self) -> ())) -> Self{
        callbackCellUpdate = { [unowned self] in  callback(cell: self.cell, row: self) }
        return self
    }
    
    /**
     Sets a block to be called when the cell corresponding to this row is created.
     
     - returns: this row
     */
    public func cellSetup(callback: ((cell: Cell, row: Self) -> ())) -> Self{
        callbackCellSetup = { [unowned self] (cell:Cell) in  callback(cell: cell, row: self) }
        return self
    }
    
    /**
     Sets a block to be called when the cell corresponding to this row is selected.
     
     - returns: this row
     */
    public func onCellSelection(callback: ((cell: Cell, row: Self) -> ())) -> Self{
        callbackCellOnSelection = { [unowned self] in  callback(cell: self.cell, row: self) }
        return self
    }
    
    /**
     Sets a block to be called when the cell corresponding to this row becomes first responder.
     
     - returns: this row
     */
    public func onCellHighlight(callback: (cell: Cell, row: Self)->()) -> Self {
        callbackOnCellHighlight = { [unowned self] in  callback(cell: self.cell, row: self) }
        return self
    }
    
    /**
     Sets a block to be called when the cell corresponding to this row resigns first responder.
     
     - returns: this row
     */
    public func onCellUnHighlight(callback: (cell: Cell, row: Self)->()) -> Self {
        callbackOnCellUnHighlight = { [unowned self] in  callback(cell: self.cell, row: self) }
        return self
    }
}

