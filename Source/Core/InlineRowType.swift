//
//  InlineRowType.swift
//  Eureka
//
//  Created by Martin Barreto on 2/24/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

public protocol BaseInlineRowType {
    /**
     Method that can be called to expand (open) an inline row
     */
    func expandInlineRow()
    
    /**
     Method that can be called to collapse (close) an inline row
     */
    func collapseInlineRow()
    
    /**
     Method that can be called to change the status of an inline row (expanded/collapsed)
     */
    func toggleInlineRow()
}

/**
 *  Protocol that every inline row type has to conform to.
 */
public protocol InlineRowType: TypedRowType, BaseInlineRowType {
    
    associatedtype InlineRow: BaseRow, RowType, TypedRowType
    
    /**
     This function is responsible for setting up an inline row before it is first shown.
     */
    func setupInlineRow(inlineRow: InlineRow)
}


extension InlineRowType where Self: BaseRow, Self.InlineRow : BaseRow, Self.Cell.Value == Self.Value, Self.InlineRow.Cell.Value == Self.InlineRow.Value, Self.InlineRow.Value == Self.Value {
    
    /// The row that will be inserted below after the current one when it is selected.
    public var inlineRow : Self.InlineRow? { return _inlineRow as? Self.InlineRow }
    
    /**
     Method that can be called to expand (open) an inline row.
     */
    public func expandInlineRow() {
        guard inlineRow == nil else { return }
        if var section = section, let form = section.form {
            let inline = InlineRow.init() { _ in }
            inline.value = value
            inline.onChange { [weak self] in
                self?.value = $0.value
                self?.updateCell()
            }
            setupInlineRow(inline)
            if (form.inlineRowHideOptions ?? Form.defaultInlineRowHideOptions).contains(.AnotherInlineRowIsShown) {
                for row in form.allRows {
                    if let inlineRow = row as? BaseInlineRowType {
                        inlineRow.collapseInlineRow()
                    }
                }
            }
            if let onExpandInlineRowCallback = onExpandInlineRowCallback {
                onExpandInlineRowCallback(cell, self, inline)
            }
            if let indexPath = indexPath() {
                section.insert(inline, atIndex: indexPath.row + 1)
                _inlineRow = inline
            }
        }
    }
    
    /**
     Method that can be called to collapse (close) an inline row.
     */
    public func collapseInlineRow() {
        if let selectedRowPath = indexPath(), let inlineRow = _inlineRow {
            if let onCollapseInlineRowCallback = onCollapseInlineRowCallback {
                onCollapseInlineRowCallback(cell, self, inlineRow as! InlineRow)
            }
            section?.removeAtIndex(selectedRowPath.row + 1)
            _inlineRow = nil
        }
    }
    
    /**
     Method that can be called to change the status of an inline row (expanded/collapsed).
     */
    public func toggleInlineRow() {
        if let _ = inlineRow {
            collapseInlineRow()
        }
        else{
            expandInlineRow()
        }
    }
    
    /**
     Sets a block to be executed when a row is expanded.
     */
    public func onExpandInlineRow(callback: (Cell, Self, InlineRow)->()) -> Self {
        callbackOnExpandInlineRow = callback
        return self
    }
    
    /**
     Sets a block to be executed when a row is collapsed.
     */
    public func onCollapseInlineRow(callback: (Cell, Self, InlineRow)->()) -> Self {
        callbackOnCollapseInlineRow = callback
        return self
    }
    
    /// Returns the block that will be executed when this row expands
    public var onCollapseInlineRowCallback: ((Cell, Self, InlineRow)->())? {
        return callbackOnCollapseInlineRow as! ((Cell, Self, InlineRow)->())?
    }
    
    /// Returns the block that will be executed when this row collapses
    public var onExpandInlineRowCallback: ((Cell, Self, InlineRow)->())? {
        return callbackOnExpandInlineRow as! ((Cell, Self, InlineRow)->())?
    }
}
