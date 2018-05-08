//
//  MultiplePickerRow.swift
//  Eureka
//
//  Created by Mathias Claassen on 5/8/18.
//  Copyright © 2018 Xmartlabs. All rights reserved.
//

import Foundation

public struct Tuple<A: Equatable, B: Equatable> {
    let a: A
    let b: B

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

open class MultiplePickerCell<A, B> : PickerCell<Tuple<A, B>> where A: Equatable, B: Equatable {

    private var pickerRow: _MultiplePickerRow<A, B>! { return row as? _MultiplePickerRow<A, B> }

    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func selectValue() {
        if let selectedValue = pickerRow.value, let indexA = pickerRow.firstOptions().index(of: selectedValue.a),
            let indexB = pickerRow.secondOptions(selectedValue.a).index(of: selectedValue.b) {
            picker.selectRow(indexA, inComponent: 0, animated: true)
            picker.selectRow(indexB, inComponent: 1, animated: true)
        }
    }

    open override func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    open override func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return  component == 0 ? pickerRow.firstOptions().count : pickerRow.value.map { pickerRow.secondOptions($0.a).count }  ?? 0
    }

    open override func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return String(describing: pickerRow.firstOptions()[row])
        } else {
            let a = pickerRow.value?.a ?? pickerRow.firstOptions()[0]
            return String(describing: pickerRow.secondOptions(a)[row])
        }
    }

    open override func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            let a = pickerRow.firstOptions()[row]
            if let value = pickerRow.value {
                if value.a == a {
                    return
                }
                if pickerRow.secondOptions(a).contains(value.b) {
                    pickerRow.value = Tuple(a: a, b: value.b)
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
            let a = pickerRow.value?.a ?? pickerRow.firstOptions()[0]
            pickerRow.value = Tuple(a: a, b: pickerRow.secondOptions(a)[row])
        }
    }

}

// MARK: PickerRow
open class _MultiplePickerRow<A, B> : Row<MultiplePickerCell<A, B>> where A: Equatable, B: Equatable {

    open var firstOptions: (() -> [A]) = {[]}
    open var secondOptions: ((A) -> [B]) = {_ in []}

    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A generic row where the user can pick an option from a picker view
public final class MultiplePickerRow<A, B>: _MultiplePickerRow<A, B>, RowType where A: Equatable, B: Equatable {

    required public init(tag: String?) {
        super.init(tag: tag)
    }

}
