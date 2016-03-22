//
//  DateRow.swift
//  Eureka
//
//  Created by Martin Barreto on 2/24/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

public class DatePickerCell : Cell<NSDate>, CellType {
    
    public lazy var datePicker: UIDatePicker = { [unowned self] in
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(picker)
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[picker]-0-|", options: [], metrics: nil, views: ["picker": picker]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[picker]-0-|", options: [], metrics: nil, views: ["picker": picker]))
        picker.addTarget(self, action: #selector(DatePickerCell.datePickerValueChanged(_:)), forControlEvents: .ValueChanged)
        return picker
        }()
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func setup() {
        super.setup()
        height = { 213 }
        accessoryType = .None
        editingAccessoryType =  .None
        datePicker.datePickerMode = datePickerMode()
    }
    
    deinit {
        datePicker.removeTarget(self, action: nil, forControlEvents: .AllEvents)
    }
    
    public override func update() {
        super.update()
        selectionStyle = row.isDisabled ? .None : .Default
        datePicker.userInteractionEnabled = !row.isDisabled
        detailTextLabel?.text = nil
        textLabel?.text = nil
        datePicker.setDate(row.value ?? NSDate(), animated: row is CountDownPickerRow)
        datePicker.minimumDate = (row as? DatePickerRowProtocol)?.minimumDate
        datePicker.maximumDate = (row as? DatePickerRowProtocol)?.maximumDate
        if let minuteIntervalValue = (row as? DatePickerRowProtocol)?.minuteInterval{
            datePicker.minuteInterval = minuteIntervalValue
        }
    }
    
    func datePickerValueChanged(sender: UIDatePicker){
        row.value = sender.date
    }
    
    private func datePickerMode() -> UIDatePickerMode{
        switch row {
        case is DatePickerRow:
            return .Date
        case is TimePickerRow:
            return .Time
        case is DateTimePickerRow:
            return .DateAndTime
        case is CountDownPickerRow:
            return .CountDownTimer
        default:
            return .Date
        }
    }
}

public class _DatePickerRow : Row<NSDate, DatePickerCell>, DatePickerRowProtocol {
    
    public var minimumDate : NSDate?
    public var maximumDate : NSDate?
    public var minuteInterval : Int?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
}

/// A row with an NSDate as value where the user can select a date directly.
public final class DatePickerRow : _DatePickerRow, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A row with an NSDate as value where the user can select a time directly.
public final class TimePickerRow : _DatePickerRow, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A row with an NSDate as value where the user can select date and time directly.
public final class DateTimePickerRow : _DatePickerRow, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A row with an NSDate as value where the user can select hour and minute as a countdown timer.
public final class CountDownPickerRow : _DatePickerRow, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}
