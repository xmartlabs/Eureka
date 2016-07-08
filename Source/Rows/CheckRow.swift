//
//  CheckRow.swift
//  Eureka
//
//  Created by Martin Barreto on 2/23/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

// MARK: CheckCell

public final class CheckCell : Cell<Bool>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func update() {
        super.update()
        accessoryType = row.value == true ? .checkmark : .none
        editingAccessoryType = accessoryType
        selectionStyle = .default
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        tintColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        if row.isDisabled {
            tintColor = UIColor(red: red, green: green, blue: blue, alpha: 0.3)
            selectionStyle = .none
        }
        else {
            tintColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
        }
    }
    
    public override func setup() {
        super.setup()
        accessoryType =  .checkmark
        editingAccessoryType = accessoryType
    }
    
    public override func didSelect() {
        row.value = row.value ?? false ? false : true
        row.deselect()
        row.updateCell()
    }
    
}

// MARK: CheckRow

public class _CheckRow: Row<CheckCell> {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
}

///// Boolean row that has a checkmark as accessoryType
public final class CheckRow: _CheckRow, RowType {
        
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
