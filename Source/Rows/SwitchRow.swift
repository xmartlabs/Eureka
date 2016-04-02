//
//  SwitchRow.swift
//  Eureka
//
//  Created by Martin Barreto on 2/23/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

// MARK: SwitchCell

public class SwitchCell : Cell<Bool>, CellType {
    
    public typealias Value = Bool
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        height = { BaseRow.estimatedRowHeight }
    }
    
    public var switchControl: UISwitch? {
        return accessoryView as? UISwitch
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .None
        accessoryView = UISwitch()
        editingAccessoryView = accessoryView
        switchControl?.addTarget(self, action: #selector(SwitchCell.valueChanged), forControlEvents: .ValueChanged)
    }
    
    deinit {
        switchControl?.removeTarget(self, action: nil, forControlEvents: .AllEvents)
    }
    
    public override func update() {
        super.update()
        switchControl?.on = row.value ?? false
        switchControl?.enabled = !row.isDisabled
    }
    
    func valueChanged() {
        row.value = switchControl?.on.boolValue ?? false
    }
}

// MARK: SwitchRow

public class _SwitchRow: Row<Bool, SwitchCell> {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
}


/// Boolean row that has a UISwitch as accessoryType
public final class SwitchRow: _SwitchRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
