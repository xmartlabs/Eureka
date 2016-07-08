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
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var switchControl: UISwitch? {
        return accessoryView as? UISwitch
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        accessoryView = UISwitch()
        editingAccessoryView = accessoryView
        switchControl?.addTarget(self, action: #selector(SwitchCell.valueChanged), for: .valueChanged)
    }
    
    deinit {
        switchControl?.removeTarget(self, action: nil, for: .allEvents)
    }
    
    public override func update() {
        super.update()
        switchControl?.isOn = row.value ?? false
        switchControl?.isEnabled = !row.isDisabled
    }
    
    func valueChanged() {
        row.value = switchControl?.isOn.boolValue ?? false
    }
}

// MARK: SwitchRow

public class _SwitchRow: Row<SwitchCell> {
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
