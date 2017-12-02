//  DateRow.swift
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

open class DatePickerCell: Cell<Date>, CellType {

    @IBOutlet weak public var datePicker: UIDatePicker!

    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        let datePicker = UIDatePicker()
        self.datePicker = datePicker
        self.datePicker.translatesAutoresizingMaskIntoConstraints = false

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(self.datePicker)
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[picker]-0-|", options: [], metrics: nil, views: ["picker": self.datePicker]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[picker]-0-|", options: [], metrics: nil, views: ["picker": self.datePicker]))
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func setup() {
        super.setup()
        selectionStyle = .none
        accessoryType = .none
        editingAccessoryType =  .none
        height = { UITableViewAutomaticDimension }
        datePicker.datePickerMode = datePickerMode()
        datePicker.addTarget(self, action: #selector(DatePickerCell.datePickerValueChanged(_:)), for: .valueChanged)
    }

    deinit {
        datePicker?.removeTarget(self, action: nil, for: .allEvents)
    }

    open override func update() {
        super.update()
        selectionStyle = row.isDisabled ? .none : .default
        datePicker.isUserInteractionEnabled = !row.isDisabled
        detailTextLabel?.text = nil
        textLabel?.text = nil
        datePicker.setDate(row.value ?? Date(), animated: row is CountDownPickerRow)
        datePicker.minimumDate = (row as? DatePickerRowProtocol)?.minimumDate
        datePicker.maximumDate = (row as? DatePickerRowProtocol)?.maximumDate
        if let minuteIntervalValue = (row as? DatePickerRowProtocol)?.minuteInterval {
            datePicker.minuteInterval = minuteIntervalValue
        }
    }

    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        row?.value = sender.date
    }

    private func datePickerMode() -> UIDatePickerMode {
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

open class _DatePickerRow: Row<DatePickerCell>, DatePickerRowProtocol {

    open var minimumDate: Date?
    open var maximumDate: Date?
    open var minuteInterval: Int?

    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
}

/// A row with an Date as value where the user can select a date directly.
public final class DatePickerRow: _DatePickerRow, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A row with an Date as value where the user can select a time directly.
public final class TimePickerRow: _DatePickerRow, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A row with an Date as value where the user can select date and time directly.
public final class DateTimePickerRow: _DatePickerRow, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A row with an Date as value where the user can select hour and minute as a countdown timer.
public final class CountDownPickerRow: _DatePickerRow, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}
