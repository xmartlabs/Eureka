//  BaseRow.swift
//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2016 Xmartlabs ( http://xmartlabs.com )
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
import UIKit

open class BaseRow: BaseRowType {

    var callbackOnChange: (() -> Void)?
    var callbackCellUpdate: (() -> Void)?
    var callbackCellSetup: Any?
    var callbackCellOnSelection: (() -> Void)?
    var callbackOnExpandInlineRow: Any?
    var callbackOnCollapseInlineRow: Any?
    var callbackOnCellHighlightChanged: (() -> Void)?
    var callbackOnRowValidationChanged: (() -> Void)?
    var _inlineRow: BaseRow?

    var _cachedOptionsData: Any?

    public var validationOptions: ValidationOptions = .validatesOnBlur
    // validation state
    public internal(set) var validationErrors = [ValidationError]() {
        didSet {
            guard validationErrors != oldValue else { return }
            RowDefaults.onRowValidationChanged["\(type(of: self))"]?(baseCell, self)
            callbackOnRowValidationChanged?()
            updateCell()
        }
    }

    public internal(set) var wasBlurred = false
    public internal(set) var wasChanged = false

    public var isValid: Bool { return validationErrors.isEmpty }
    public var isHighlighted: Bool = false

    /// The title will be displayed in the textLabel of the row.
    public var title: String?

    /// Parameter used when creating the cell for this row.
    public var cellStyle = UITableViewCell.CellStyle.value1

    /// String that uniquely identifies a row. Must be unique among rows and sections.
    public var tag: String?

    /// The untyped cell associated to this row.
    public var baseCell: BaseCell! { return nil }

    /// The untyped value of this row.
    public var baseValue: Any? {
        set {}
        get { return nil }
    }

    open func validate(quietly: Bool = false) -> [ValidationError] {
        return []
    }

    // Reset validation
    open func cleanValidationErrors() {
        validationErrors = []
    }

    public static var estimatedRowHeight: CGFloat = 44.0

    /// Condition that determines if the row should be disabled or not.
    public var disabled: Condition? {
        willSet { removeFromDisabledRowObservers() }
        didSet { addToDisabledRowObservers() }
    }

    /// Condition that determines if the row should be hidden or not.
    public var hidden: Condition? {
        willSet { removeFromHiddenRowObservers() }
        didSet { addToHiddenRowObservers() }
    }

    /// Returns if this row is currently disabled or not
    public var isDisabled: Bool { return disabledCache }

    /// Returns if this row is currently hidden or not
    public var isHidden: Bool { return hiddenCache }

    /// The section to which this row belongs.
    open weak var section: Section?
	
    public lazy var trailingSwipe = {[unowned self] in SwipeConfiguration(self)}()
	
    //needs the accessor because if marked directly this throws "Stored properties cannot be marked potentially unavailable with '@available'"
    private lazy var _leadingSwipe = {[unowned self] in SwipeConfiguration(self)}()

    @available(iOS 11,*)
    public var leadingSwipe: SwipeConfiguration{
        get { return self._leadingSwipe }
        set { self._leadingSwipe = newValue }
    }
    
    public required init(tag: String? = nil) {
        self.tag = tag
    }

    /**
     Method that reloads the cell
     */
    open func updateCell() {}

    /**
     Method called when the cell belonging to this row was selected. Must call the corresponding method in its cell.
     */
    open func didSelect() {}

    open func prepare(for segue: UIStoryboardSegue) {}

    /**
     Helps to pick destination part of the cell after scrolling
     */
    open var destinationScrollPosition: UITableView.ScrollPosition? = UITableView.ScrollPosition.bottom

    /**
     Returns the IndexPath where this row is in the current form.
     */
    public final var indexPath: IndexPath? {
        guard let sectionIndex = section?.index, let rowIndex = section?.firstIndex(of: self) else { return nil }
        return IndexPath(row: rowIndex, section: sectionIndex)
    }

    var hiddenCache = false
    var disabledCache = false {
        willSet {
            if newValue && !disabledCache {
                baseCell.cellResignFirstResponder()
            }
        }
    }
}

extension BaseRow {

    /**
     Evaluates if the row should be hidden or not and updates the form accordingly
     */
    public final func evaluateHidden() {
        guard let h = hidden, let form = section?.form else { return }
        switch h {
        case .function(_, let callback):
            hiddenCache = callback(form)
        case .predicate(let predicate):
            hiddenCache = predicate.evaluate(with: self, substitutionVariables: form.dictionaryValuesToEvaluatePredicate())
        }
        if hiddenCache {
            section?.hide(row: self)
        } else {
            section?.show(row: self)
        }
    }

    /**
     Evaluates if the row should be disabled or not and updates it accordingly
     */
    public final func evaluateDisabled() {
        guard let d = disabled, let form = section?.form else { return }
        switch d {
        case .function(_, let callback):
            disabledCache = callback(form)
        case .predicate(let predicate):
            disabledCache = predicate.evaluate(with: self, substitutionVariables: form.dictionaryValuesToEvaluatePredicate())
        }
        updateCell()
    }

    final func wasAddedTo(section: Section) {
        self.section = section
        if let t = tag {
            assert(section.form?.rowsByTag[t] == nil, "Duplicate tag \(t)")
            self.section?.form?.rowsByTag[t] = self
            self.section?.form?.tagToValues[t] = baseValue != nil ? baseValue! : NSNull()
        }
        addToRowObservers()
        evaluateHidden()
        evaluateDisabled()
    }

    final func addToHiddenRowObservers() {
        guard let h = hidden else { return }
        switch h {
        case .function(let tags, _):
            section?.form?.addRowObservers(to: self, rowTags: tags, type: .hidden)
        case .predicate(let predicate):
            section?.form?.addRowObservers(to: self, rowTags: predicate.predicateVars, type: .hidden)
        }
    }

    final func addToDisabledRowObservers() {
        guard let d = disabled else { return }
        switch d {
        case .function(let tags, _):
            section?.form?.addRowObservers(to: self, rowTags: tags, type: .disabled)
        case .predicate(let predicate):
            section?.form?.addRowObservers(to: self, rowTags: predicate.predicateVars, type: .disabled)
        }
    }

    final func addToRowObservers() {
        addToHiddenRowObservers()
        addToDisabledRowObservers()
    }

    final func willBeRemovedFromForm() {
        (self as? BaseInlineRowType)?.collapseInlineRow()
        if let t = tag {
            section?.form?.rowsByTag[t] = nil
            section?.form?.tagToValues[t] = nil
        }
        removeFromRowObservers()
    }

    final func willBeRemovedFromSection() {
        willBeRemovedFromForm()
        section = nil
    }

    final func removeFromHiddenRowObservers() {
        guard let h = hidden else { return }
        switch h {
        case .function(let tags, _):
            section?.form?.removeRowObservers(from: self, rowTags: tags, type: .hidden)
        case .predicate(let predicate):
            section?.form?.removeRowObservers(from: self, rowTags: predicate.predicateVars, type: .hidden)
        }
    }

    final func removeFromDisabledRowObservers() {
        guard let d = disabled else { return }
        switch d {
        case .function(let tags, _):
            section?.form?.removeRowObservers(from: self, rowTags: tags, type: .disabled)
        case .predicate(let predicate):
            section?.form?.removeRowObservers(from: self, rowTags: predicate.predicateVars, type: .disabled)
        }
    }

    final func removeFromRowObservers() {
        removeFromHiddenRowObservers()
        removeFromDisabledRowObservers()
    }
}

extension BaseRow: Equatable, Hidable, Disableable {}

extension BaseRow {

    public func reload(with rowAnimation: UITableView.RowAnimation = .none) {
        guard let tableView = baseCell?.formViewController()?.tableView ?? (section?.form?.delegate as? FormViewController)?.tableView, let indexPath = indexPath else { return }
        tableView.reloadRows(at: [indexPath], with: rowAnimation)
    }

    public func deselect(animated: Bool = true) {
        guard let indexPath = indexPath,
            let tableView = baseCell?.formViewController()?.tableView ?? (section?.form?.delegate as? FormViewController)?.tableView  else { return }
        tableView.deselectRow(at: indexPath, animated: animated)
    }

    public func select(animated: Bool = false, scrollPosition: UITableView.ScrollPosition = .none) {
        guard let indexPath = indexPath,
            let tableView = baseCell?.formViewController()?.tableView ?? (section?.form?.delegate as? FormViewController)?.tableView  else { return }
        tableView.selectRow(at: indexPath, animated: animated, scrollPosition: scrollPosition)
    }
}

public func == (lhs: BaseRow, rhs: BaseRow) -> Bool {
    return lhs === rhs
}
