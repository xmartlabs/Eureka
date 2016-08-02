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

public class BaseRow : BaseRowType {
    
    var callbackOnChange: (()->Void)?
    var callbackCellUpdate: (()->Void)?
    var callbackCellSetup: Any?
    var callbackCellOnSelection: (()->Void)?
    var callbackOnCellHighlight: (()->Void)?
    var callbackOnCellUnHighlight: (()->Void)?
    var callbackOnExpandInlineRow: Any?
    var callbackOnCollapseInlineRow: Any?
    var _inlineRow: BaseRow?
    
    /// The title will be displayed in the textLabel of the row.
    public var title: String?
    
    /// Parameter used when creating the cell for this row.
    public var cellStyle = UITableViewCellStyle.Value1
    
    /// String that uniquely identifies a row. Must be unique among rows and sections.
    public var tag: String?
    
    /// The untyped cell associated to this row.
    public var baseCell: BaseCell! { return nil }
    
    /// The untyped value of this row.
    public var baseValue: Any? {
        set {}
        get { return nil }
    }
    
    public static var estimatedRowHeight: CGFloat = 44.0
    
    /// Condition that determines if the row should be disabled or not.
    public var disabled : Condition? {
        willSet { removeFromDisabledRowObservers() }
        didSet  { addToDisabledRowObservers() }
    }
    
    /// Condition that determines if the row should be hidden or not.
    public var hidden : Condition? {
        willSet { removeFromHiddenRowObservers() }
        didSet  { addToHiddenRowObservers() }
    }
    
    /// Returns if this row is currently disabled or not
    public var isDisabled : Bool { return disabledCache }
    
    /// Returns if this row is currently hidden or not
    public var isHidden : Bool { return hiddenCache }
    
    /// The section to which this row belongs.
    public weak var section: Section?
    
    public required init(tag: String? = nil){
        self.tag = tag
    }
    
    /**
     Method that reloads the cell
     */
    public func updateCell() {}
    
    /**
     Method called when the cell belonging to this row was selected. Must call the corresponding method in its cell.
     */
    public func didSelect() {}
    
    /**
     Method that is responsible for highlighting the cell.
     */
    public func highlightCell() {}
    
    @available(*, unavailable, message="Deprecated. Use 'highlightCell' instead.")
    public func hightlightCell() { highlightCell() }
    
    /**
     Method that is responsible for unhighlighting the cell.
     */
    public func unhighlightCell() {}
    
    public func prepareForSegue(segue: UIStoryboardSegue) {}
    
    /**
     Returns the NSIndexPath where this row is in the current form.
     */
    public final func indexPath() -> NSIndexPath? {
        guard let sectionIndex = section?.index, let rowIndex = section?.indexOf(self) else { return nil }
        return NSIndexPath(forRow: rowIndex, inSection: sectionIndex)
    }
    
    private var hiddenCache = false
    private var disabledCache = false {
        willSet {
            if newValue == true && disabledCache == false  {
                baseCell.cellResignFirstResponder()
            }
        }
    }
    
    // MARK: - Validation Extension
    public var validator:IdaValidator?
    public var fireValidatorOnChange: Bool = false
}

extension BaseRow {
    
    /**
     Evaluates if the row should be hidden or not and updates the form accordingly
     */
    public final func evaluateHidden() {
        guard let h = hidden, let form = section?.form else { return }
        switch h {
        case .Function(_ , let callback):
            hiddenCache = callback(form)
        case .Predicate(let predicate):
            hiddenCache = predicate.evaluateWithObject(self, substitutionVariables: form.dictionaryValuesToEvaluatePredicate())
        }
        if hiddenCache {
            section?.hideRow(self)
        }
        else{
            section?.showRow(self)
        }
    }
    
    /**
     Evaluates if the row should be disabled or not and updates it accordingly
     */
    public final func evaluateDisabled() {
        guard let d = disabled, form = section?.form else { return }
        switch d {
        case .Function(_ , let callback):
            disabledCache = callback(form)
        case .Predicate(let predicate):
            disabledCache = predicate.evaluateWithObject(self, substitutionVariables: form.dictionaryValuesToEvaluatePredicate())
        }
        updateCell()
    }
    
    final func wasAddedToFormInSection(section: Section) {
        self.section = section
        if let t = tag {
            assert(section.form?.rowsByTag[t] == nil, "Duplicate tag \(t)")
            self.section?.form?.rowsByTag[t] = self
            self.section?.form?.tagToValues[t] = baseValue as? AnyObject ?? NSNull()
        }
        addToRowObservers()
        evaluateHidden()
        evaluateDisabled()
    }
    
    final func addToHiddenRowObservers() {
        guard let h = hidden else { return }
        switch h {
        case .Function(let tags, _):
            section?.form?.addRowObservers(self, rowTags: tags, type: .Hidden)
        case .Predicate(let predicate):
            section?.form?.addRowObservers(self, rowTags: predicate.predicateVars, type: .Hidden)
        }
    }
    
    final func addToDisabledRowObservers() {
        guard let d = disabled else { return }
        switch d {
        case .Function(let tags, _):
            section?.form?.addRowObservers(self, rowTags: tags, type: .Disabled)
        case .Predicate(let predicate):
            section?.form?.addRowObservers(self, rowTags: predicate.predicateVars, type: .Disabled)
        }
    }
    
    final func addToRowObservers(){
        addToHiddenRowObservers()
        addToDisabledRowObservers()
    }
    
    final func willBeRemovedFromForm(){
        (self as? BaseInlineRowType)?.collapseInlineRow()
        if let t = tag {
            section?.form?.rowsByTag[t] = nil
            section?.form?.tagToValues[t] = nil
        }
        removeFromRowObservers()
    }
    
    
    final func removeFromHiddenRowObservers() {
        guard let h = hidden else { return }
        switch h {
        case .Function(let tags, _):
            section?.form?.removeRowObservers(self, rows: tags, type: .Hidden)
        case .Predicate(let predicate):
            section?.form?.removeRowObservers(self, rows: predicate.predicateVars, type: .Hidden)
        }
    }
    
    final func removeFromDisabledRowObservers() {
        guard let d = disabled else { return }
        switch d {
        case .Function(let tags, _):
            section?.form?.removeRowObservers(self, rows: tags, type: .Disabled)
        case .Predicate(let predicate):
            section?.form?.removeRowObservers(self, rows: predicate.predicateVars, type: .Disabled)
        }
    }
    
    final func removeFromRowObservers(){
        removeFromHiddenRowObservers()
        removeFromDisabledRowObservers()
    }
}

extension BaseRow: Equatable, Hidable, Disableable {}


extension BaseRow {
    
    public func reload(rowAnimation: UITableViewRowAnimation = .None) {
        guard let tableView = baseCell?.formViewController()?.tableView ?? (section?.form?.delegate as? FormViewController)?.tableView, indexPath = indexPath() else { return }
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: rowAnimation)
    }
    
    public func deselect(animated: Bool = true) {
        guard let indexPath = indexPath(), tableView = baseCell?.formViewController()?.tableView ?? (section?.form?.delegate as? FormViewController)?.tableView  else { return }
        tableView.deselectRowAtIndexPath(indexPath, animated: animated)
    }
    
    public func select(animated: Bool = false) {
        guard let indexPath = indexPath(), tableView = baseCell?.formViewController()?.tableView ?? (section?.form?.delegate as? FormViewController)?.tableView  else { return }
        tableView.selectRowAtIndexPath(indexPath, animated: animated, scrollPosition: .None)
    }
}

public func ==(lhs: BaseRow, rhs: BaseRow) -> Bool{
    return lhs === rhs
}
