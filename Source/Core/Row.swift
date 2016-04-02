//
//  Row.swift
//  Eureka
//
//  Created by Martin Barreto on 2/23/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

public class RowOf<T: Equatable>: BaseRow {
    
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
            form.tagToValues[t] = value as? AnyObject ?? NSNull()
            if let rowObservers = form.rowObservers[t]?[.Hidden]{
                for rowObserver in rowObservers {
                    (rowObserver as? Hidable)?.evaluateHidden()
                }
            }
            if let rowObservers = form.rowObservers[t]?[.Disabled]{
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
    public var displayValueFor : (T? -> String?)? = {
        if let t = $0 {
            return String(t)
        }
        return nil
    }
    
    public required init(tag: String?){
        super.init(tag: tag)
    }
}

/// Generic class that represents an Eureka row.
public class Row<T: Equatable, Cell: CellType where Cell: TypedCellType, Cell: BaseCell, Cell.Value == T>: RowOf<T>,  TypedRowType {
    
    /// Responsible for creating the cell for this row.
    public var cellProvider = CellProvider<Cell>()
    
    /// The type of the cell associated to this row.
    public let cellType: Cell.Type! = Cell.self
    
    private var _cell: Cell! {
        didSet {
            RowDefaults.cellSetup["\(self.dynamicType)"]?(_cell, self)
            (callbackCellSetup as? (Cell -> ()))?(_cell)
        }
    }
    
    /// The cell associated to this row.
    public var cell : Cell! {
        guard _cell == nil else{
            return _cell
        }
        let result = cellProvider.createCell(self.cellStyle)
        result.row = self
        result.setup()
        _cell = result
        return _cell
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
        RowDefaults.cellUpdate["\(self.dynamicType)"]?(cell, self)
        callbackCellUpdate?()
        cell.setNeedsLayout()
        cell.setNeedsUpdateConstraints()
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
    override public func hightlightCell() {
        super.hightlightCell()
        cell.highlight()
        RowDefaults.onCellHighlight["\(self.dynamicType)"]?(cell, self)
        callbackOnCellHighlight?()
    }
    
    /**
     Method that is responsible for unhighlighting the cell.
     */
    public override func unhighlightCell() {
        super.unhighlightCell()
        cell.unhighlight()
        RowDefaults.onCellUnHighlight["\(self.dynamicType)"]?(cell, self)
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


