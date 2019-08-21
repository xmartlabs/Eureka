//
//  MultiplePickerRow.swift
//  Eureka
//
//  Created by Mathias Claassen on 5/8/18.
//  Copyright © 2018 Xmartlabs. All rights reserved.
//

import Foundation
import UIKit

public struct Tuple<A: Equatable, B: Equatable> {
    
    public let a: A
    public let b: B

    public init(a: A, b: B) {
        self.a = a
        self.b = b
    }

}

extension Tuple: Equatable {}

public func == <A: Equatable, B: Equatable>(lhs: Tuple<A, B>, rhs: Tuple<A, B>) -> Bool {
    return lhs.a == rhs.a && lhs.b == rhs.b
}

// MARK: MultiplePickerCell

open class DoublePickerCell<A, B> : _PickerCell<Tuple<A, B>> where A: Equatable, B: Equatable {

    private var pickerRow: _DoublePickerRow<A, B>? { return row as? _DoublePickerRow<A, B> }

    public required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func update() {
        super.update()
        if let selectedValue = pickerRow?.value, let indexA = pickerRow?.firstOptions().firstIndex(of: selectedValue.a),
            let indexB = pickerRow?.secondOptions(selectedValue.a).firstIndex(of: selectedValue.b) {
            picker.selectRow(indexA, inComponent: 0, animated: true)
            picker.selectRow(indexB, inComponent: 1, animated: true)
        }
    }

    open override func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    open override func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let pickerRow = pickerRow else { return 0 }
        return component == 0 ? pickerRow.firstOptions().count : pickerRow.secondOptions(pickerRow.selectedFirst()).count
    }

    open override func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let pickerRow = pickerRow else { return "" }
        if component == 0 {
            return pickerRow.displayValueForFirstRow(pickerRow.firstOptions()[row])
        } else {
            return pickerRow.displayValueForSecondRow(pickerRow.secondOptions(pickerRow.selectedFirst())[row])
        }
    }

    open override func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let pickerRow = pickerRow else { return }
        if component == 0 {
            let a = pickerRow.firstOptions()[row]
            if let value = pickerRow.value {
                guard value.a != a else {
                    return
                }
                if pickerRow.secondOptions(a).contains(value.b) {
                    pickerRow.value = Tuple(a: a, b: value.b)
                    pickerView.reloadComponent(1)
                    return
                } else {
                    pickerRow.value = Tuple(a: a, b: pickerRow.secondOptions(a)[0])
                }
            } else {
                pickerRow.value = Tuple(a: a, b: pickerRow.secondOptions(a)[0])
            }
            pickerView.reloadComponent(1)
            pickerView.selectRow(0, inComponent: 1, animated: true)
        } else {
            let a = pickerRow.selectedFirst()
            pickerRow.value = Tuple(a: a, b: pickerRow.secondOptions(a)[row])
        }
    }

}

// MARK: PickerRow
open class _DoublePickerRow<A, B> : Row<DoublePickerCell<A, B>> where A: Equatable, B: Equatable {

    /// Options for first component. Will be called often so should be O(1)
    public var firstOptions: (() -> [A]) = {[]}
    /// Options for second component given the selected value from the first component. Will be called often so should be O(1)
    public var secondOptions: ((A) -> [B]) = {_ in []}
    
    /// Modify the displayed values for the first picker row.
    public var displayValueForFirstRow: ((A) -> (String)) = { a in return String(describing: a) }
    /// Modify the displayed values for the second picker row.
    public var displayValueForSecondRow: ((B) -> (String)) = { b in return String(describing: b) }

    required public init(tag: String?) {
        super.init(tag: tag)
    }

    func selectedFirst() -> A {
        return value?.a ?? firstOptions()[0]
    }

}

/// A generic row where the user can pick an option from a picker view
public final class DoublePickerRow<A, B>: _DoublePickerRow<A, B>, RowType where A: Equatable, B: Equatable {

    required public init(tag: String?) {
        super.init(tag: tag)
    }

}
