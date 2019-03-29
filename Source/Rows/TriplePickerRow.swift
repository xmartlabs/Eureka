//
//  TriplePickerRow.swift
//  Eureka
//
//  Created by Mathias Claassen on 5/9/18.
//  Copyright © 2018 Xmartlabs. All rights reserved.
//

import Foundation
import UIKit

public struct Tuple3<A: Equatable, B: Equatable, C: Equatable> {
    public let a: A
    public let b: B
    public let c: C

    public init(a: A, b: B, c: C) {
        self.a = a
        self.b = b
        self.c = c
    }

}

extension Tuple3: Equatable {}

public func == <A: Equatable, B: Equatable, C: Equatable>(lhs: Tuple3<A, B, C>, rhs: Tuple3<A, B, C>) -> Bool {
    return lhs.a == rhs.a && lhs.b == rhs.b && lhs.c == rhs.c
}

// MARK: MultiplePickerCell

open class TriplePickerCell<A, B, C> : _PickerCell<Tuple3<A, B, C>> where A: Equatable, B: Equatable, C: Equatable {

    private var pickerRow: _TriplePickerRow<A, B, C>? { return row as? _TriplePickerRow<A, B, C> }

    public required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func update() {
        super.update()
        if let selectedValue = pickerRow?.value, let indexA = pickerRow?.firstOptions().firstIndex(of: selectedValue.a),
            let indexB = pickerRow?.secondOptions(selectedValue.a).firstIndex(of: selectedValue.b),
            let indexC = pickerRow?.thirdOptions(selectedValue.a, selectedValue.b).firstIndex(of: selectedValue.c) {
            picker.selectRow(indexA, inComponent: 0, animated: true)
            picker.selectRow(indexB, inComponent: 1, animated: true)
            picker.selectRow(indexC, inComponent: 2, animated: true)
        }
    }

    open override func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }

    open override func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let pickerRow = pickerRow else { return 0 }
        if component == 0 {
            return pickerRow.firstOptions().count
        } else if component == 1 {
            return pickerRow.secondOptions(pickerRow.selectedFirst()).count
        } else {
            return pickerRow.thirdOptions(pickerRow.selectedFirst(), pickerRow.selectedSecond()).count
        }
    }

    open override func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let pickerRow = pickerRow else { return "" }
        if component == 0 {
            return pickerRow.displayValueForFirstRow(pickerRow.firstOptions()[row])
        } else if component == 1 {
            return pickerRow.displayValueForSecondRow(pickerRow.secondOptions(pickerRow.selectedFirst())[row])
        } else {
            return pickerRow.displayValueForThirdRow(pickerRow.thirdOptions(pickerRow.selectedFirst(), pickerRow.selectedSecond())[row])
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

                let b: B = pickerRow.secondOptions(a).contains(value.b) ? value.b : pickerRow.secondOptions(a)[0]
                let c: C = pickerRow.thirdOptions(a, b).contains(value.c) ? value.c : pickerRow.thirdOptions(a, b)[0]
                pickerRow.value = Tuple3(a: a, b: b, c: c)
                pickerView.reloadComponent(1)
                pickerView.reloadComponent(2)
                if b != value.b {
                    pickerView.selectRow(0, inComponent: 1, animated: true)
                }
                if c != value.c {
                    pickerView.selectRow(0, inComponent: 2, animated: true)
                }
            } else {
                let b = pickerRow.secondOptions(a)[0]
                pickerRow.value = Tuple3(a: a, b: b, c: pickerRow.thirdOptions(a, b)[0])
                pickerView.reloadComponent(1)
                pickerView.reloadComponent(2)
                pickerView.selectRow(0, inComponent: 1, animated: true)
                pickerView.selectRow(0, inComponent: 2, animated: true)
            }
        } else if component == 1 {
            let a = pickerRow.selectedFirst()
            let b = pickerRow.secondOptions(a)[row]
            if let value = pickerRow.value {
                guard value.b != b else {
                    return
                }
                if pickerRow.thirdOptions(a, b).contains(value.c) {
                    pickerRow.value = Tuple3(a: a, b: b, c: value.c)
                    pickerView.reloadComponent(2)
                    return
                } else {
                    pickerRow.value = Tuple3(a: a, b: b, c: pickerRow.thirdOptions(a, b)[0])
                }
            } else {
                pickerRow.value = Tuple3(a: a, b: b, c: pickerRow.thirdOptions(a, b)[0])
            }
            pickerView.reloadComponent(2)
            pickerView.selectRow(0, inComponent: 2, animated: true)
        } else {
            let a = pickerRow.selectedFirst()
            let b = pickerRow.selectedSecond()
            pickerRow.value = Tuple3(a: a, b: b, c: pickerRow.thirdOptions(a, b)[row])
        }
    }

}

// MARK: PickerRow
open class _TriplePickerRow<A, B, C> : Row<TriplePickerCell<A, B, C>> where A: Equatable, B: Equatable, C: Equatable {

    /// Options for first component. Will be called often so should be O(1)
    public var firstOptions: (() -> [A]) = {[]}
    /// Options for second component given the selected value from the first component. Will be called often so should be O(1)
    public var secondOptions: ((A) -> [B]) = {_ in []}
    /// Options for third component given the selected value from the first and second components. Will be called often so should be O(1)
    public var thirdOptions: ((A, B) -> [C]) = {_, _ in []}
    
    /// Modify the displayed values for the first picker row.
    public var displayValueForFirstRow: ((A) -> (String)) = { a in return String(describing: a) }
    /// Modify the displayed values for the second picker row.
    public var displayValueForSecondRow: ((B) -> (String)) = { b in return String(describing: b) }
    /// Modify the displayed values for the third picker row.
    public var displayValueForThirdRow: ((C) -> (String)) = { c in return String(describing: c) }

    required public init(tag: String?) {
        super.init(tag: tag)
    }

    func selectedFirst() -> A {
        return value?.a ?? firstOptions()[0]
    }

    func selectedSecond() -> B {
        return value?.b ?? secondOptions(selectedFirst())[0]
    }

}

/// A generic row where the user can pick an option from a picker view
public final class TriplePickerRow<A, B, C>: _TriplePickerRow<A, B, C>, RowType where A: Equatable, B: Equatable, C: Equatable {

    required public init(tag: String?) {
        super.init(tag: tag)
    }

}
