//
//  DateRow.swift
//  Eureka
//
//  Created by Martin Barreto on 2/24/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

public class _DateRow: _DateFieldRow {
    required public init(tag: String?) {
        super.init(tag: tag)
        dateFormatter = NSDateFormatter()
        dateFormatter?.timeStyle = .NoStyle
        dateFormatter?.dateStyle = .MediumStyle
        dateFormatter?.locale = NSLocale.currentLocale()
    }
}


public class _TimeRow: _DateFieldRow {
    required public init(tag: String?) {
        super.init(tag: tag)
        dateFormatter = NSDateFormatter()
        dateFormatter?.timeStyle = .ShortStyle
        dateFormatter?.dateStyle = .NoStyle
        dateFormatter?.locale = NSLocale.currentLocale()
    }
}

public class _DateTimeRow: _DateFieldRow {
    required public init(tag: String?) {
        super.init(tag: tag)
        dateFormatter = NSDateFormatter()
        dateFormatter?.timeStyle = .ShortStyle
        dateFormatter?.dateStyle = .ShortStyle
        dateFormatter?.locale = NSLocale.currentLocale()
    }
}

public class _CountDownRow: _DateFieldRow {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = { [unowned self] value in
            guard let val = value else {
                return nil
            }
            if let formatter = self.dateFormatter {
                return formatter.stringFromDate(val)
            }
            let components = NSCalendar.currentCalendar().components(NSCalendarUnit.Minute.union(NSCalendarUnit.Hour), fromDate: val)
            var hourString = "hour"
            if components.hour != 1{
                hourString += "s"
            }
            return  "\(components.hour) \(hourString) \(components.minute) min"
        }
    }
}

/// A row with an NSDate as value where the user can select a date from a picker view.
public final class DateRow: _DateRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        onCellHighlight { cell, row in
            let color = cell.detailTextLabel?.textColor
            row.onCellUnHighlight { cell, _ in
                cell.detailTextLabel?.textColor = color
            }
            cell.detailTextLabel?.textColor = cell.tintColor
        }
    }
}


/// A row with an NSDate as value where the user can select a time from a picker view.
public final class TimeRow: _TimeRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        onCellHighlight { cell, row in
            let color = cell.detailTextLabel?.textColor
            row.onCellUnHighlight { cell, _ in
                cell.detailTextLabel?.textColor = color
            }
            cell.detailTextLabel?.textColor = cell.tintColor
        }
    }
}

/// A row with an NSDate as value where the user can select date and time from a picker view.
public final class DateTimeRow: _DateTimeRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        onCellHighlight { cell, row in
            let color = cell.detailTextLabel?.textColor
            row.onCellUnHighlight { cell, _ in
                cell.detailTextLabel?.textColor = color
            }
            cell.detailTextLabel?.textColor = cell.tintColor
        }
    }
}

/// A row with an NSDate as value where the user can select hour and minute as a countdown timer in a picker view.
public final class CountDownRow: _CountDownRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        onCellHighlight { cell, row in
            let color = cell.detailTextLabel?.textColor
            row.onCellUnHighlight { cell, _ in
                cell.detailTextLabel?.textColor = color
            }
            cell.detailTextLabel?.textColor = cell.tintColor
        }
    }
}



