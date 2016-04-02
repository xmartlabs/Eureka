//
//  DateFieldRow.swift
//  Eureka
//
//  Created by Martin Barreto on 2/24/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

public protocol DatePickerRowProtocol {
    var minimumDate : NSDate? { get set }
    var maximumDate : NSDate? { get set }
    var minuteInterval : Int? { get set }
}


public class DateCell : Cell<NSDate>, CellType {
    
    lazy public var datePicker = UIDatePicker()
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        height = { BaseRow.estimatedRowHeight }
    }
    
    public override func setup() {
        super.setup()
        accessoryType = .None
        editingAccessoryType =  .None
        datePicker.datePickerMode = datePickerMode()
        datePicker.addTarget(self, action: #selector(DateCell.datePickerValueChanged(_:)), forControlEvents: .ValueChanged)
    }
    
    deinit {
        datePicker.removeTarget(self, action: nil, forControlEvents: .AllEvents)
    }
    
    public override func update() {
        super.update()
        selectionStyle = row.isDisabled ? .None : .Default
        detailTextLabel?.text = row.displayValueFor?(row.value)
        datePicker.setDate(row.value ?? NSDate(), animated: row is CountDownPickerRow)
        datePicker.minimumDate = (row as? DatePickerRowProtocol)?.minimumDate
        datePicker.maximumDate = (row as? DatePickerRowProtocol)?.maximumDate
        if let minuteIntervalValue = (row as? DatePickerRowProtocol)?.minuteInterval{
            datePicker.minuteInterval = minuteIntervalValue
        }
    }
    
    public override func didSelect() {
        super.didSelect()
        row.deselect()
    }
    
    override public var inputView : UIView? {
        if let v = row.value{
            datePicker.setDate(v, animated:row is CountDownRow)
        }
        return datePicker
    }
    
    func datePickerValueChanged(sender: UIDatePicker){
        row.value = sender.date
        detailTextLabel?.text = row.displayValueFor?(row.value)
    }
    
    private func datePickerMode() -> UIDatePickerMode{
        switch row {
        case is DateRow:
            return .Date
        case is TimeRow:
            return .Time
        case is DateTimeRow:
            return .DateAndTime
        case is CountDownRow:
            return .CountDownTimer
        default:
            return .Date
        }
    }
    
    public override func cellCanBecomeFirstResponder() -> Bool {
        return canBecomeFirstResponder()
    }
    
    public override func canBecomeFirstResponder() -> Bool {
        return !row.isDisabled;
    }
}


public class _DateFieldRow: Row<NSDate, DateCell>, DatePickerRowProtocol {
    
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
