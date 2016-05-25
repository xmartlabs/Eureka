//
//  PickerInlineRow.swift
//  Eureka
//
//  Created by Martin Barreto on 2/23/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

public class PickerInlineCell<T: Equatable> : Cell<T>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func setup() {
        super.setup()
        accessoryType = .None
        editingAccessoryType =  .None
    }
    
    public override func update() {
        super.update()
        selectionStyle = row.isDisabled ? .None : .Default
    }
    
    public override func didSelect() {
        super.didSelect()
        row.deselect()
    }
}

//MARK: PickerInlineRow

public class _PickerInlineRow<T where T: Equatable> : Row<T, PickerInlineCell<T>>, NoValueDisplayTextConformance {
    
    public typealias InlineRow = PickerRow<T>
    public var options = [T]()
    public var noValueDisplayText: String?
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A generic inline row where the user can pick an option from a picker view
public final class PickerInlineRow<T where T: Equatable> : _PickerInlineRow<T>, RowType, InlineRowType {
    
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
    
    public func setupInlineRow(inlineRow: InlineRow) {
        inlineRow.options = self.options
        inlineRow.displayValueFor = self.displayValueFor
    }
}

