//
//  DateRow.swift
//  Eureka
//
//  Created by Martin Barreto on 2/24/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

public class DatePickerCell : Cell<Date>, CellType {
    
    public lazy var datePicker: UIDatePicker = { [unowned self] in
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(picker)
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[picker]-0-|", options: [], metrics: nil, views: ["picker": picker]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[picker]-0-|", options: [], metrics: nil, views: ["picker": picker]))
        picker.addTarget(self, action: #selector(DatePickerCell.datePickerValueChanged(_:)), for: .valueChanged)
        return picker
        }()
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func setup() {
        super.setup()
        accessoryType = .none
        editingAccessoryType =  .none
        datePicker.datePickerMode = datePickerMode()
    }
    
    deinit {
        datePicker.removeTarget(self, action: nil, for: .allEvents)
    }
    
    public override func update() {
        super.update()
        selectionStyle = row.isDisabled ? .none : .default
        datePicker.isUserInteractionEnabled = !row.isDisabled
        detailTextLabel?.text = nil
        textLabel?.text = nil
        datePicker.setDate(row.value ?? Date(), animated: row is CountDownPickerRow)
        datePicker.minimumDate = (row as? DatePickerRowProtocol)?.minimumDate
        datePicker.maximumDate = (row as? DatePickerRowProtocol)?.maximumDate
        if let minuteIntervalValue = (row as? DatePickerRowProtocol)?.minuteInterval{
            datePicker.minuteInterval = minuteIntervalValue
        }
    }
    
    func datePickerValueChanged(_ sender: UIDatePicker){
        row?.value = sender.date
    }
    
    private func datePickerMode() -> UIDatePickerMode{
        switch row {
        case is DatePickerRow:
            return .date
        case is TimePickerRow:
            return .time
        case is DateTimePickerRow:
            return .dateAndTime
        case is CountDownPickerRow:
            return .countDownTimer
        default:
            return .date
        }
    }
}

public class _DatePickerRow : Row<DatePickerCell>, DatePickerRowProtocol {
    
    public var minimumDate : Date?
    public var maximumDate : Date?
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
