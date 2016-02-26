//
//  DateInliuneRow.swift
//  Eureka
//
//  Created by Martin Barreto on 2/24/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation




public class _DateInlineRow: _DateInlineFieldRow {
    
    public typealias InlineRow = DatePickerRow
    
    public required init(tag: String?) {
        super.init(tag: tag)
        dateFormatter = NSDateFormatter()
        dateFormatter?.timeStyle = .NoStyle
        dateFormatter?.dateStyle = .MediumStyle
        dateFormatter?.locale = .currentLocale()
    }
    
    public func setupInlineRow(inlineRow: DatePickerRow) {
        inlineRow.minimumDate = minimumDate
        inlineRow.maximumDate = maximumDate
        inlineRow.minuteInterval = minuteInterval
    }
}

public class _TimeInlineRow: _DateInlineFieldRow {
    
    public typealias InlineRow = TimePickerRow
    
    public required init(tag: String?) {
        super.init(tag: tag)
        dateFormatter = NSDateFormatter()
        dateFormatter?.timeStyle = .ShortStyle
        dateFormatter?.dateStyle = .NoStyle
        dateFormatter?.locale = .currentLocale()
    }
    
    public func setupInlineRow(inlineRow: TimePickerRow) {
        inlineRow.minimumDate = minimumDate
        inlineRow.maximumDate = maximumDate
        inlineRow.minuteInterval = minuteInterval
    }
}

public class _DateTimeInlineRow: _DateInlineFieldRow {
    
    public typealias InlineRow = DateTimePickerRow
    
    public required init(tag: String?) {
        super.init(tag: tag)
        dateFormatter = NSDateFormatter()
        dateFormatter?.timeStyle = .ShortStyle
        dateFormatter?.dateStyle = .ShortStyle
        dateFormatter?.locale = .currentLocale()
    }
    
    public func setupInlineRow(inlineRow: DateTimePickerRow) {
        inlineRow.minimumDate = minimumDate
        inlineRow.maximumDate = maximumDate
        inlineRow.minuteInterval = minuteInterval
    }
}

public class _CountDownInlineRow: _DateInlineFieldRow {
    
    public typealias InlineRow = CountDownPickerRow
    
    public required init(tag: String?) {
        super.init(tag: tag)
        displayValueFor =  {
            guard let date = $0 else {
                return nil
            }
            let hour = NSCalendar.currentCalendar().component(.Hour, fromDate: date)
            let min = NSCalendar.currentCalendar().component(.Minute, fromDate: date)
            if hour == 1{
                return "\(hour) hour \(min) min"
            }
            return "\(hour) hours \(min) min"
        }
    }
    
    public func setupInlineRow(inlineRow: CountDownPickerRow) {
        inlineRow.minimumDate = minimumDate
        inlineRow.maximumDate = maximumDate
        inlineRow.minuteInterval = minuteInterval
    }
}

/// A row with an NSDate as value where the user can select a date from an inline picker view.
public final class DateInlineRow_<T>: _DateInlineRow, RowType, InlineRowType {
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
}

public typealias DateInlineRow = DateInlineRow_<NSDate>


/// A row with an NSDate as value where the user can select date and time from an inline picker view.
public final class DateTimeInlineRow_<T>: _DateTimeInlineRow, RowType, InlineRowType {
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
}


public typealias DateTimeInlineRow = DateTimeInlineRow_<NSDate>


/// A row with an NSDate as value where the user can select a time from an inline picker view.
public final class TimeInlineRow_<T>: _TimeInlineRow, RowType, InlineRowType {
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
}

public typealias TimeInlineRow = TimeInlineRow_<NSDate>

///// A row with an NSDate as value where the user can select hour and minute as a countdown timer in an inline picker view.
public final class CountDownInlineRow_<T>: _CountDownInlineRow, RowType, InlineRowType {
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
}

public typealias CountDownInlineRow = CountDownInlineRow_<NSDate>


