//
//  DateInlineFieldRow.swift
//  Eureka
//
//  Created by Martin Barreto on 2/24/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation


public class DateInlineCell : Cell<NSDate>, CellType {
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        height = { BaseRow.estimatedRowHeight }
    }
    
    public override func setup() {
        super.setup()
        accessoryType = .None
        editingAccessoryType =  .None
    }
    
    public override func update() {
        super.update()
        selectionStyle = row.isDisabled ? .None : .Default
        detailTextLabel?.text = row.displayValueFor?(row.value)
    }
    
    public override func didSelect() {
        super.didSelect()
        row.deselect()
    }
}


public class _DateInlineFieldRow: Row<NSDate, DateInlineCell>, DatePickerRowProtocol {
    
    /// The minimum value for this row's UIDatePicker
    public var minimumDate : NSDate?
    
    /// The maximum value for this row's UIDatePicker
    public var maximumDate : NSDate?
    
    /// The interval between options for this row's UIDatePicker
    public var minuteInterval : Int?
    
    /// The formatter for the date picked by the user
    public var dateFormatter: NSDateFormatter?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = { [unowned self] value in
            guard let val = value, let formatter = self.dateFormatter else { return nil }
            return formatter.stringFromDate(val)
        }
    }
}
