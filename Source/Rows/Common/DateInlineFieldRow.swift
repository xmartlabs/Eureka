//
//  DateInlineFieldRow.swift
//  Eureka
//
//  Created by Martin Barreto on 2/24/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation


public class DateInlineCell : Cell<Date>, CellType {
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func setup() {
        super.setup()
        accessoryType = .none
        editingAccessoryType =  .none
    }
    
    public override func update() {
        super.update()
        selectionStyle = row.isDisabled ? .none : .default
    }
    
    public override func didSelect() {
        super.didSelect()
        row.deselect()
    }
}


public class _DateInlineFieldRow: Row<DateInlineCell>, DatePickerRowProtocol, NoValueDisplayTextConformance {
    
    /// The minimum value for this row's UIDatePicker
    public var minimumDate : Date?
    
    /// The maximum value for this row's UIDatePicker
    public var maximumDate : Date?
    
    /// The interval between options for this row's UIDatePicker
    public var minuteInterval : Int?
    
    /// The formatter for the date picked by the user
    public var dateFormatter: DateFormatter?
    
    public var noValueDisplayText: String?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        dateFormatter = DateFormatter()
        dateFormatter?.locale = Locale.current
        displayValueFor = { [unowned self] value in
            guard let val = value, let formatter = self.dateFormatter else { return nil }
            return formatter.string(from: val)
        }
    }
}
