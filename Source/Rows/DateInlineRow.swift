//  DateInliuneRow.swift
//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2016 Xmartlabs SRL ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation


extension DatePickerRowProtocol {
    
    func configureInlineRow(_ inlineRow: DatePickerRowProtocol){
        inlineRow.minimumDate = minimumDate
        inlineRow.maximumDate = maximumDate
        inlineRow.minuteInterval = minuteInterval
    }
    
}


open class _DateInlineRow: _DateInlineFieldRow {
    
    public typealias InlineRow = DatePickerRow
    
    public required init(tag: String?) {
        super.init(tag: tag)
        dateFormatter?.timeStyle = .none
        dateFormatter?.dateStyle = .medium
    }
    
    open func setupInlineRow(_ inlineRow: DatePickerRow) {
        configureInlineRow(inlineRow)
    }
}

open class _TimeInlineRow: _DateInlineFieldRow {
    
    public typealias InlineRow = TimePickerRow
    
    public required init(tag: String?) {
        super.init(tag: tag)
        dateFormatter?.timeStyle = .short
        dateFormatter?.dateStyle = .none
    }
    
    open func setupInlineRow(_ inlineRow: TimePickerRow) {
        configureInlineRow(inlineRow)
    }
}

open class _DateTimeInlineRow: _DateInlineFieldRow {
    
    public typealias InlineRow = DateTimePickerRow
    
    public required init(tag: String?) {
        super.init(tag: tag)
        dateFormatter?.timeStyle = .short
        dateFormatter?.dateStyle = .short
    }
    
    open func setupInlineRow(_ inlineRow: DateTimePickerRow) {
        configureInlineRow(inlineRow)
    }
}

open class _CountDownInlineRow: _DateInlineFieldRow {
    
    public typealias InlineRow = CountDownPickerRow
    
    public required init(tag: String?) {
        super.init(tag: tag)
        displayValueFor =  {
            guard let date = $0 else {
                return nil
            }
            let hour = Calendar.current.component(.hour, from: date)
            let min = Calendar.current.component(.minute, from: date)
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

/// A row with an Date as value where the user can select a date from an inline picker view.
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


/// A row with an Date as value where the user can select date and time from an inline picker view.
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


/// A row with an Date as value where the user can select a time from an inline picker view.
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

///// A row with an Date as value where the user can select hour and minute as a countdown timer in an inline picker view.
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


