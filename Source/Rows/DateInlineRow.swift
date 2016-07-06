//
//  DateInliuneRow.swift
//  Eureka
//
//  Created by Martin Barreto on 2/24/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation


extension DatePickerRowProtocol {
    
    func configureInlineRow(_ inlineRow: DatePickerRowProtocol){
        inlineRow.minimumDate = minimumDate
        inlineRow.maximumDate = maximumDate
        inlineRow.minuteInterval = minuteInterval
    }
    
}


public class _DateInlineRow: _DateInlineFieldRow {
    
    public typealias InlineRow = DatePickerRow
    
    public required init(tag: String?) {
        super.init(tag: tag)
        dateFormatter?.timeStyle = .none
        dateFormatter?.dateStyle = .medium
    }
    
    public func setupInlineRow(_ inlineRow: DatePickerRow) {
        configureInlineRow(inlineRow)
    }
}

public class _TimeInlineRow: _DateInlineFieldRow {
    
    public typealias InlineRow = TimePickerRow
    
    public required init(tag: String?) {
        super.init(tag: tag)
        dateFormatter?.timeStyle = .short
        dateFormatter?.dateStyle = .none
    }
    
    public func setupInlineRow(_ inlineRow: TimePickerRow) {
        configureInlineRow(inlineRow)
    }
}

public class _DateTimeInlineRow: _DateInlineFieldRow {
    
    public typealias InlineRow = DateTimePickerRow
    
    public required init(tag: String?) {
        super.init(tag: tag)
        dateFormatter?.timeStyle = .short
        dateFormatter?.dateStyle = .short
    }
    
    public func setupInlineRow(_ inlineRow: DateTimePickerRow) {
        configureInlineRow(inlineRow)
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
            let hour = Calendar.current.component(.hour, from: date as Date)
            let min = Calendar.current.component(.minute, from: date as Date)
            if hour == 1{
                return "\(hour) hour \(min) min"
            }
            return "\(hour) hours \(min) min"
        }
    }
    
    public func setupInlineRow(_ inlineRow: CountDownPickerRow) {
        configureInlineRow(inlineRow)
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

public typealias DateInlineRow = DateInlineRow_<Date>


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


public typealias DateTimeInlineRow = DateTimeInlineRow_<Date>


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

public typealias TimeInlineRow = TimeInlineRow_<Date>

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

public typealias CountDownInlineRow = CountDownInlineRow_<Date>


