//  Core.swift
//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2015 Xmartlabs ( http://xmartlabs.com )
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

//MARK: Controller Protocols

/**
*  Base protocol for view controllers presented by Eureka rows.
*/
public protocol RowControllerType : NSObjectProtocol {
    
    /// A closure to be called when the controller disappears.
    var completionCallback : ((UIViewController) -> ())? { get set }
}

/**
 *  Protocol that view controllers pushed or presented by a row should conform to.
 */
public protocol TypedRowControllerType : RowControllerType {
    typealias RowValue: Equatable
    
    /// The row that pushed or presented this controller
    var row : RowOf<Self.RowValue>! { get set }
}

/// The delegate of the Eureka form.
public protocol FormDelegate : class {
    func sectionsHaveBeenAdded(sections: [Section], atIndexes: NSIndexSet)
    func sectionsHaveBeenRemoved(sections: [Section], atIndexes: NSIndexSet)
    func sectionsHaveBeenReplaced(oldSections oldSections:[Section], newSections: [Section], atIndexes: NSIndexSet)
    func rowsHaveBeenAdded(rows: [BaseRow], atIndexPaths:[NSIndexPath])
    func rowsHaveBeenRemoved(rows: [BaseRow], atIndexPaths:[NSIndexPath])
    func rowsHaveBeenReplaced(oldRows oldRows:[BaseRow], newRows: [BaseRow], atIndexPaths: [NSIndexPath])
    func rowValueHasBeenChanged(row: BaseRow, oldValue: Any?, newValue: Any?)
}

/// The delegate of the Eureka sections.
public protocol SectionDelegate: class {
    func rowsHaveBeenAdded(rows: [BaseRow], atIndexes:NSIndexSet)
    func rowsHaveBeenRemoved(rows: [BaseRow], atIndexes:NSIndexSet)
    func rowsHaveBeenReplaced(oldRows oldRows:[BaseRow], newRows: [BaseRow], atIndexes: NSIndexSet)
}

//MARK: Header Footer Protocols

/**
*  Protocol used to set headers and footers to sections.
*  Can be set with a view or a String
*/
public protocol HeaderFooterViewRepresentable {
    
    /**
     This method can be called to get the view corresponding to the header or footer of a section in a specific controller.
     
     - parameter section:    The section from which to get the view.
     - parameter type:       Either header or footer.
     - parameter controller: The controller from which to get that view.
     
     - returns: The header or footer of the specified section.
     */
    func viewForSection(section: Section, type: HeaderFooterType, controller: FormViewController) -> UIView?
    
    /// If the header or footer of a section was created with a String then it will be stored in the title.
    var title: String? { get set }
    
    /// The height of the header or footer.
    var height: (()->CGFloat)? { get set }
}

//MARK: Row Protocols

public protocol Taggable : AnyObject {
    var tag: String? { get set }
}

public protocol BaseRowType : Taggable {

    /// The cell associated to this row.
    var baseCell: BaseCell! { get }
    
    /// The section to which this row belongs.
    var section: Section? { get }
    
    /// Parameter used when creating the cell for this row.
    var cellStyle : UITableViewCellStyle { get set }
    
    /// The title will be displayed in the textLabel of the row.
    var title: String? { get set }
    
    /**
     Method that should re-display the cell
     */
    func updateCell()
    
    /**
     Method called when the cell belonging to this row was selected. Must call the corresponding method in its cell.
     */
    func didSelect()
}

public protocol TypedRowType : BaseRowType {
    
    typealias Value : Equatable
    typealias Cell : BaseCell, CellType
    
    /// The typed cell associated to this row.
    var cell : Self.Cell! { get }
    
    /// The typed value this row stores.
    var value : Self.Value? { get set }
}

/**
 *  Protocol that every row type has to conform to.
 */
public protocol RowType : TypedRowType {
    init(_ tag: String?, @noescape _ initializer: (Self -> ()))
}

public protocol BaseInlineRowType {
    /**
     Method that can be called to expand (open) an inline row
     */
    func expandInlineRow()
    
    /**
     Method that can be called to collapse (close) an inline row
     */
    func collapseInlineRow()
    
    /**
     Method that can be called to change the status of an inline row (expanded/collapsed)
     */
    func toggleInlineRow()
}


/**
 *  Protocol that every inline row type has to conform to.
 */
public protocol InlineRowType: TypedRowType, BaseInlineRowType {
    typealias InlineRow: RowType
    
    /**
     This function is responsible for setting up an inline row before it is first shown.
     */
    func setupInlineRow(inlineRow: InlineRow)
}

extension InlineRowType where Self: BaseRow, Self.InlineRow : BaseRow, Self.Cell : TypedCellType, Self.Cell.Value == Self.Value, Self.InlineRow.Cell.Value == Self.InlineRow.Value, Self.InlineRow.Value == Self.Value {
    
    /// The row that will be inserted below after the current one when it is selected.
    public var inlineRow : Self.InlineRow? { return _inlineRow as? Self.InlineRow }
    
    /**
     Method that can be called to expand (open) an inline row.
     */
    public func expandInlineRow() {
        guard inlineRow == nil else { return }
        if var section = section, let form = section.form {
            let inline = InlineRow.init() { _ in }
            inline.value = value
            inline.onChange { [weak self] in
                self?.value = $0.value
                self?.updateCell()
            }
            setupInlineRow(inline)
            if (form.inlineRowHideOptions ?? Form.defaultInlineRowHideOptions).contains(.AnotherInlineRowIsShown) {
                for row in form.allRows {
                    if let inlineRow = row as? BaseInlineRowType {
                        inlineRow.collapseInlineRow()
                    }
                }
            }
            if let onExpandInlineRowCallback = onExpandInlineRowCallback {
                onExpandInlineRowCallback(cell, self, inline)
            }
            if let indexPath = indexPath() {
                section.insert(inline, atIndex: indexPath.row + 1)
                _inlineRow = inline
            }
        }
    }
    
    /**
     Method that can be called to collapse (close) an inline row.
     */
    public func collapseInlineRow() {
        if let selectedRowPath = indexPath(), let inlineRow = _inlineRow {
            if let onCollapseInlineRowCallback = onCollapseInlineRowCallback {
                onCollapseInlineRowCallback(cell, self, inlineRow as! InlineRow)
            }
            section?.removeAtIndex(selectedRowPath.row + 1)
            _inlineRow = nil
        }
    }
    
    /**
     Method that can be called to change the status of an inline row (expanded/collapsed).
     */
    public func toggleInlineRow() {
        if let _ = inlineRow {
            collapseInlineRow()
        }
        else{
            expandInlineRow()
        }
    }
    
    /**
     Sets a block to be executed when a row is expanded.
     */
    public func onExpandInlineRow(callback: (Cell, Self, InlineRow)->()) -> Self {
        callbackOnExpandInlineRow = callback
        return self
    }
    
    /**
     Sets a block to be executed when a row is collapsed.
     */
    public func onCollapseInlineRow(callback: (Cell, Self, InlineRow)->()) -> Self {
        callbackOnCollapseInlineRow = callback
        return self
    }
    
    /// Returns the block that will be executed when this row expands
    public var onCollapseInlineRowCallback: ((Cell, Self, InlineRow)->())? {
        return callbackOnCollapseInlineRow as! ((Cell, Self, InlineRow)->())?
    }
    
    /// Returns the block that will be executed when this row collapses
    public var onExpandInlineRowCallback: ((Cell, Self, InlineRow)->())? {
        return callbackOnExpandInlineRow as! ((Cell, Self, InlineRow)->())?
    }
}


/**
 *  Every row that shall be used in a SelectableSection must conform to this protocol.
 */
public protocol SelectableRowType : RowType {
    var selectableValue : Value? { get set }
}

/**
 *  Protocol that every row that displays a new view controller must conform to.
 *  This includes presenting or pushing view controllers.
 */
public protocol PresenterRowType: TypedRowType {
    
    typealias ProviderType : UIViewController, TypedRowControllerType
    
    /// Defines how the view controller will be presented, pushed, etc.
    var presentationMode: PresentationMode<ProviderType>? { get set }
    
    /// Will be called before the presentation occurs.
    var onPresentCallback: ((FormViewController, ProviderType)->())? { get set }
}

public protocol KeyboardReturnHandler : BaseRowType {
    var keyboardReturnType : KeyboardReturnTypeConfiguration? { get set }
}

//MARK: Cell Protocols

public protocol BaseCellType : class {
    
    /// Method that will return the height of the cell
    var height : (()->CGFloat)? { get }
    
    /**
     Method called once when creating a cell. Responsible for setting up the cell.
     */
    func setup()
    
    /**
     Method called each time the cell is updated (e.g. 'cellForRowAtIndexPath' is called). Responsible for updating the cell.
     */
    func update()
    
    /**
     Method called each time the cell is selected (tapped on by the user).
     */
    func didSelect()
    
    /**
     Method called each time the cell is selected (tapped on by the user).
     */
    func highlight()
    
    /**
     Method called each time the cell is deselected (looses first responder).
     */
    func unhighlight()
    
    /**
     Called when cell is about to become first responder
     
     - returns: If the cell should become first responder.
     */
    func cellCanBecomeFirstResponder() -> Bool
    
    /**
     Method called when the cell becomes first responder
     */
    func cellBecomeFirstResponder(direction: Direction) -> Bool
    
    /**
     Method called when the cell resigns first responder
     */
    func cellResignFirstResponder() -> Bool
    
    /**
     A reference to the controller in which the cell is displayed.
     */
    func formViewController () -> FormViewController?
}


public protocol TypedCellType : BaseCellType {
    typealias Value : Equatable
    
    /// The row associated to this cell.
    var row : RowOf<Value>! { get set }
}

public protocol CellType: TypedCellType {}

//MARK: Form

/// The class representing the Eureka form.
public final class Form {

    /// Defines the default options of the navigation accessory view.
    public static var defaultNavigationOptions = RowNavigationOptions.Enabled.union(.SkipCanNotBecomeFirstResponderRow)
    
    /// The default options that define when an inline row will be hidden. Applies only when `inlineRowHideOptions` is nil.
    public static var defaultInlineRowHideOptions = InlineRowHideOptions.FirstResponderChanges.union(.AnotherInlineRowIsShown)
    
    /// The options that define when an inline row will be hidden. If nil then `defaultInlineRowHideOptions` are used
    public var inlineRowHideOptions : InlineRowHideOptions?
    
    /// Which `UIReturnKeyType` should be used by default. Applies only when `keyboardReturnType` is nil.
    public static var defaultKeyboardReturnType = KeyboardReturnTypeConfiguration()
    
    /// Which `UIReturnKeyType` should be used in this form. If nil then `defaultKeyboardReturnType` is used
    public var keyboardReturnType : KeyboardReturnTypeConfiguration?
    
    /// This form's delegate
    public weak var delegate: FormDelegate?

    public init(){}
    
    /**
     Returns the row at the given indexPath
     */
    public subscript(indexPath: NSIndexPath) -> BaseRow {
        return self[indexPath.section][indexPath.row]
    }
    
    /**
     Returns the row whose tag is passed as parameter. Uses a dictionary to get the row faster
     */
    public func rowByTag<T: Equatable>(tag: String) -> RowOf<T>? {
        let row: BaseRow? = rowByTag(tag)
        return row as? RowOf<T>
    }
    
    /**
     Returns the row whose tag is passed as parameter. Uses a dictionary to get the row faster
     */
    public func rowByTag<Row: RowType>(tag: String) -> Row? {
        let row: BaseRow? = rowByTag(tag)
        return row as? Row
    }
    
    /**
     Returns the row whose tag is passed as parameter. Uses a dictionary to get the row faster
     */
    public func rowByTag(tag: String) -> BaseRow? {
        return rowsByTag[tag]
    }
    
    /**
     Returns the section whose tag is passed as parameter.
     */
    public func sectionByTag(tag: String) -> Section? {
        return kvoWrapper._allSections.filter( { $0.tag == tag }).first
    }
    
    /**
     Method used to get all the values of all the rows of the form. Only rows with tag are included.
     
     - parameter includeHidden: If the values of hidden rows should be included.
     
     - returns: A dictionary mapping the rows tag to its value. [tag: value]
     */
    public func values(includeHidden includeHidden: Bool = false) -> [String: Any?]{
        if includeHidden {
            return allRows.filter({ $0.tag != nil })
                          .reduce([String: Any?]()) {
                               var result = $0
                               result[$1.tag!] = $1.baseValue
                               return result
                          }
        }
        return rows.filter({ $0.tag != nil })
                   .reduce([String: Any?]()) {
                        var result = $0
                        result[$1.tag!] = $1.baseValue
                        return result
                    }
    }
    
    /**
     Set values to the rows of this form
     
     - parameter values: A dictionary mapping tag to value of the rows to be set. [tag: value]
     */
    public func setValues(values: [String: Any?]){
        for (key, value) in values{
            let row: BaseRow? = rowByTag(key)
            row?.baseValue = value
        }
    }
    
    /// The visible rows of this form
    public var rows: [BaseRow] { return flatMap { $0 } }
    
    /// All the rows of this form. Includes the hidden rows.
    public var allRows: [BaseRow] { return kvoWrapper._allSections.map({ $0.kvoWrapper._allRows }).flatMap { $0 } }
    
    /**
     * Hides all the inline rows of this form.
     */
    public func hideInlineRows() {
        for row in self.allRows {
            if let inlineRow = row as? BaseInlineRowType {
                inlineRow.collapseInlineRow()
            }
        }
    }
    
    //MARK: Private
    
    var rowObservers = [String: [ConditionType: [Taggable]]]()
    var rowsByTag = [String: BaseRow]()
    private lazy var kvoWrapper : KVOWrapper = { [unowned self] in return KVOWrapper(form: self) }()
}

extension Form : MutableCollectionType {
    
    // MARK: MutableCollectionType
    
    public var startIndex: Int { return 0 }
    public var endIndex: Int { return kvoWrapper.sections.count }
    public subscript (position: Int) -> Section {
        get { return kvoWrapper.sections[position] as! Section }
        set { kvoWrapper.sections[position] = newValue }
    }
}

extension Form : RangeReplaceableCollectionType {
    
    // MARK: RangeReplaceableCollectionType

    public func append(formSection: Section){
        kvoWrapper.sections.insertObject(formSection, atIndex: kvoWrapper.sections.count)
        kvoWrapper._allSections.append(formSection)
        formSection.wasAddedToForm(self)
    }

    public func appendContentsOf<S : SequenceType where S.Generator.Element == Section>(newElements: S) {
        kvoWrapper.sections.addObjectsFromArray(newElements.map { $0 })
        kvoWrapper._allSections.appendContentsOf(newElements)
        for section in newElements{
            section.wasAddedToForm(self)
        }
    }
    
    public func reserveCapacity(n: Int){}

    public func replaceRange<C : CollectionType where C.Generator.Element == Section>(subRange: Range<Int>, with newElements: C) {
        for i in subRange {
            if let section = kvoWrapper.sections.objectAtIndex(i) as? Section {
                section.willBeRemovedFromForm()
                kvoWrapper._allSections.removeAtIndex(kvoWrapper._allSections.indexOf(section)!)
            }
        }
        kvoWrapper.sections.replaceObjectsInRange(NSMakeRange(subRange.startIndex, subRange.endIndex - subRange.startIndex), withObjectsFromArray: newElements.map { $0 })
        kvoWrapper._allSections.insertContentsOf(newElements, at: indexForInsertionAtIndex(subRange.startIndex))
        
        for section in newElements{
            section.wasAddedToForm(self)
        }
    }
    
    public func removeAll(keepCapacity keepCapacity: Bool = false) {
        // not doing anything with capacity
        for section in kvoWrapper._allSections{
            section.willBeRemovedFromForm()
        }
        kvoWrapper.sections.removeAllObjects()
        kvoWrapper._allSections.removeAll()
    }
    
    private func indexForInsertionAtIndex(index: Int) -> Int {
        guard index != 0 else { return 0 }
        
        let row = kvoWrapper.sections[index-1]
        if let i = kvoWrapper._allSections.indexOf(row as! Section){
            return i + 1
        }
        return kvoWrapper._allSections.count
    }
}

extension Form {
    
    // MARK: Private Helpers
    
    private class KVOWrapper : NSObject {
        dynamic var _sections = NSMutableArray()
        var sections : NSMutableArray { return mutableArrayValueForKey("_sections") }
        var _allSections = [Section]()
        weak var form: Form?
        
        init(form: Form){
            self.form = form
            super.init()
            addObserver(self, forKeyPath: "_sections", options: NSKeyValueObservingOptions.New.union(.Old), context:nil)
        }
        
        deinit { removeObserver(self, forKeyPath: "_sections") }
        
        override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
            
            let newSections = change?[NSKeyValueChangeNewKey] as? [Section] ?? []
            let oldSections = change?[NSKeyValueChangeOldKey] as? [Section] ?? []
            guard let delegateValue = form?.delegate, let keyPathValue = keyPath, let changeType = change?[NSKeyValueChangeKindKey] else { return }
            guard keyPathValue == "_sections" else { return }
            switch changeType.unsignedLongValue {
                case NSKeyValueChange.Setting.rawValue:
                    let indexSet = change![NSKeyValueChangeIndexesKey] as? NSIndexSet ?? NSIndexSet(index: 0)
                    delegateValue.sectionsHaveBeenAdded(newSections, atIndexes: indexSet)
                case NSKeyValueChange.Insertion.rawValue:
                    let indexSet = change![NSKeyValueChangeIndexesKey] as! NSIndexSet
                    delegateValue.sectionsHaveBeenAdded(newSections, atIndexes: indexSet)
                case NSKeyValueChange.Removal.rawValue:
                    let indexSet = change![NSKeyValueChangeIndexesKey] as! NSIndexSet
                    delegateValue.sectionsHaveBeenRemoved(oldSections, atIndexes: indexSet)
                case NSKeyValueChange.Replacement.rawValue:
                    let indexSet = change![NSKeyValueChangeIndexesKey] as! NSIndexSet
                    delegateValue.sectionsHaveBeenReplaced(oldSections: oldSections, newSections: newSections, atIndexes: indexSet)
                default:
                    assertionFailure()
            }
        }
    }
    
    func dictionaryValuesToEvaluatePredicate() -> [String: AnyObject] {
        return rowsByTag.reduce([String: AnyObject]()) {
            var result = $0
            result[$1.0] = $1.1.baseValue as? AnyObject ?? NSNull()
            return result
        }
    }
    
    private func addRowObservers(taggable: Taggable, rowTags: [String], type: ConditionType) {
        for rowTag in rowTags{
            if rowObservers[rowTag] == nil {
              rowObservers[rowTag] = Dictionary()
            }
            if let _ = rowObservers[rowTag]?[type]{
                if !rowObservers[rowTag]![type]!.contains({ $0 === taggable }){
                    rowObservers[rowTag]?[type]!.append(taggable)
                }
            }
            else{
                rowObservers[rowTag]?[type] = [taggable]
            }
        }
    }
    
    private func removeRowObservers(taggable: Taggable, rows: [String], type: ConditionType) {
        for row in rows{
            guard var arr = rowObservers[row]?[type], let index = arr.indexOf({ $0 === taggable }) else { continue }
            arr.removeAtIndex(index)
        }
    }
    
    func nextRowForRow(currentRow: BaseRow) -> BaseRow? {
        let allRows = rows
        guard let index = allRows.indexOf(currentRow) else { return nil }
        guard index < allRows.count - 1 else { return nil }
        return allRows[index + 1]
    }
    
    func previousRowForRow(currentRow: BaseRow) -> BaseRow? {
        let allRows = rows
        guard let index = allRows.indexOf(currentRow) else { return nil }
        guard index > 0 else { return nil }
        return allRows[index - 1]
    }
    
    private func hideSection(section: Section){
        kvoWrapper.sections.removeObject(section)
    }
    
    private func showSection(section: Section){
        guard !kvoWrapper.sections.containsObject(section) else { return }
        guard var index = kvoWrapper._allSections.indexOf(section) else { return }
        var formIndex = NSNotFound
        while (formIndex == NSNotFound && index > 0){
            index = index - 1
            let previous = kvoWrapper._allSections[index]
            formIndex = kvoWrapper.sections.indexOfObject(previous)
        }
        kvoWrapper.sections.insertObject(section, atIndex: formIndex == NSNotFound ? 0 : formIndex + 1 )
    }
}


// MARK: Section

extension Section : Equatable {}

public func ==(lhs: Section, rhs: Section) -> Bool{
    return lhs === rhs
}

extension Section : Hidable, SectionDelegate {}

extension Section {
    
    public func reload(rowAnimation: UITableViewRowAnimation = .None) {
        guard let tableView = (form?.delegate as? FormViewController)?.tableView, index = index else { return }
        tableView.reloadSections(NSIndexSet(index: index), withRowAnimation: rowAnimation)
    }
}

/// The class representing the sections in a Eureka form.
public class Section {

    /// The tag is used to uniquely identify a Section. Must be unique among sections and rows.
    public var tag: String?
    
    /// The form that contains this section
    public private(set) weak var form: Form?
    
    /// The header of this section.
    public var header: HeaderFooterViewRepresentable?
    
    /// The footer of this section
    public var footer: HeaderFooterViewRepresentable?
    
    /// Index of this section in the form it belongs to.
    public var index: Int? { return form?.indexOf(self) }
    
    /// Condition that determines if the section should be hidden or not.
    public var hidden : Condition? {
        willSet { removeFromRowObservers() }
        didSet { addToRowObservers() }
    }
    
    /// Returns if the section is currently hidden or not
    public var isHidden : Bool { return hiddenCache }
    
    public required init(){}
    
    public required init(@noescape _ initializer: Section -> ()){
        initializer(self)
    }

    public init(_ header: String, @noescape _ initializer: Section -> () = { _ in }){
        self.header = HeaderFooterView(stringLiteral: header)
        initializer(self)
    }
    
    public init(header: String, footer: String, @noescape _ initializer: Section -> () = { _ in }){
        self.header = HeaderFooterView(stringLiteral: header)
        self.footer = HeaderFooterView(stringLiteral: footer)
        initializer(self)
    }
    
    public init(footer: String, @noescape _ initializer: Section -> () = { _ in }){
        self.footer = HeaderFooterView(stringLiteral: footer)
        initializer(self)
    }
    
    //MARK: SectionDelegate
    
    /**
     *  Delegate method called by the framework when one or more rows have been added to the section.
     */
    public func rowsHaveBeenAdded(rows: [BaseRow], atIndexes:NSIndexSet) {}
    
    /**
     *  Delegate method called by the framework when one or more rows have been removed from the section.
     */
    public func rowsHaveBeenRemoved(rows: [BaseRow], atIndexes:NSIndexSet) {}
    
    /**
     *  Delegate method called by the framework when one or more rows have been replaced in the section.
     */
    public func rowsHaveBeenReplaced(oldRows oldRows:[BaseRow], newRows: [BaseRow], atIndexes: NSIndexSet) {}
    
    //MARK: Private
    private lazy var kvoWrapper: KVOWrapper = { [unowned self] in return KVOWrapper(section: self) }()
    private var headerView: UIView?
    private var footerView: UIView?
    private var hiddenCache = false
}


extension Section : MutableCollectionType {
    
//MARK: MutableCollectionType
    
    public var startIndex: Int { return 0 }
    public var endIndex: Int { return kvoWrapper.rows.count }
    public subscript (position: Int) -> BaseRow {
        get {
            if position >= kvoWrapper.rows.count{
                assertionFailure("Section: Index out of bounds")
            }
            return kvoWrapper.rows[position] as! BaseRow
        }
        set { kvoWrapper.rows[position] = newValue }
    }
}

extension Section : RangeReplaceableCollectionType {

// MARK: RangeReplaceableCollectionType
    
    public func append(formRow: BaseRow){
        kvoWrapper.rows.insertObject(formRow, atIndex: kvoWrapper.rows.count)
        kvoWrapper._allRows.append(formRow)
        formRow.wasAddedToFormInSection(self)
    }
    
    public func appendContentsOf<S : SequenceType where S.Generator.Element == BaseRow>(newElements: S) {
        kvoWrapper.rows.addObjectsFromArray(newElements.map { $0 })
        kvoWrapper._allRows.appendContentsOf(newElements)
        for row in newElements{
            row.wasAddedToFormInSection(self)
        }
    }
    
    public func reserveCapacity(n: Int){}
    
    public func replaceRange<C : CollectionType where C.Generator.Element == BaseRow>(subRange: Range<Int>, with newElements: C) {
        for i in subRange.startIndex..<subRange.endIndex {
            if let row = kvoWrapper.rows.objectAtIndex(i) as? BaseRow {
                row.willBeRemovedFromForm()
                kvoWrapper._allRows.removeAtIndex(kvoWrapper._allRows.indexOf(row)!)
            }
        }
        kvoWrapper.rows.replaceObjectsInRange(NSMakeRange(subRange.startIndex, subRange.endIndex - subRange.startIndex), withObjectsFromArray: newElements.map { $0 })
        
        kvoWrapper._allRows.insertContentsOf(newElements, at: indexForInsertionAtIndex(subRange.startIndex))
        for row in newElements{
            row.wasAddedToFormInSection(self)
        }
    }
    
    public func removeAll(keepCapacity keepCapacity: Bool = false) {
        // not doing anything with capacity
        for row in kvoWrapper._allRows{
            row.willBeRemovedFromForm()
        }
        kvoWrapper.rows.removeAllObjects()
        kvoWrapper._allRows.removeAll()
    }
    
    private func indexForInsertionAtIndex(index: Int) -> Int {
        guard index != 0 else { return 0 }
        
        let row = kvoWrapper.rows[index-1]
        if let i = kvoWrapper._allRows.indexOf(row as! BaseRow){
            return i + 1
        }
        return kvoWrapper._allRows.count
    }
}

/**
 Enumeration used to generate views for the header and footer of a section.
 
 - Class:              Will generate a view of the specified class.
 - Callback->ViewType: Will generate the view as a result of the given closure.
 - NibFile:            Will load the view from a nib file.
 */
public enum HeaderFooterProvider<ViewType: UIView> {
    
    /**
     * Will generate a view of the specified class.
     */
    case Class
    
    /**
     * Will generate the view as a result of the given closure.
     */
    case Callback(()->ViewType)
    
    /**
     * Will load the view from a nib file.
     */
    case NibFile(name: String, bundle: NSBundle?)
    
    internal func createView() -> ViewType {
        switch self {
            case .Class:
                return ViewType.init()
            case .Callback(let builder):
                return builder()
            case .NibFile(let nibName, let bundle):
                return (bundle ?? NSBundle(forClass: ViewType.self)).loadNibNamed(nibName, owner: nil, options: nil)[0] as! ViewType
        }
    }
}

/**
 * Represents headers and footers of sections
 */
public enum HeaderFooterType {
    case Header, Footer
}

/**
 *  Struct used to generate headers and footers either from a view or a String.
 */
public struct HeaderFooterView<ViewType: UIView> : StringLiteralConvertible, HeaderFooterViewRepresentable {
    
    /// Holds the title of the view if it was set up with a String.
    public var title: String?
    
    /// Generates the view.
    public var viewProvider: HeaderFooterProvider<ViewType>?
    
    /// Closure called when the view is created. Useful to customize its appearance.
    public var onSetupView: ((view: ViewType, section: Section, form: FormViewController) -> ())?
    
    /// A closure that returns the height for the header or footer view.
    public var height: (()->CGFloat)?

    lazy var staticView : ViewType? = {
        guard let view = self.viewProvider?.createView() else { return nil }
        return view
    }()
    
    /**
     This method can be called to get the view corresponding to the header or footer of a section in a specific controller.
     
     - parameter section:    The section from which to get the view.
     - parameter type:       Either header or footer.
     - parameter controller: The controller from which to get that view.
     
     - returns: The header or footer of the specified section.
     */
    public func viewForSection(section: Section, type: HeaderFooterType, controller: FormViewController) -> UIView? {
        var view: ViewType?
        if type == .Header {
            view = section.headerView as? ViewType
            if view == nil {
                view = viewProvider?.createView()
                section.headerView = view
            }
        }
        else {
            view = section.footerView as? ViewType
            if view == nil {
                view = viewProvider?.createView()
                section.footerView = view
            }
        }
        guard let v = view else { return nil }
        onSetupView?(view: v, section: section, form: controller)
        v.setNeedsUpdateConstraints()
        v.updateConstraintsIfNeeded()
        v.setNeedsLayout()
        return v
    }
    
    /**
     Initiates the view with a String as title
     */
    public init?(title: String?){
        guard let t = title else { return nil }
        self.init(stringLiteral: t)
    }
    
    /**
     Initiates the view with a view provider, ideal for customized headers or footers
     */
    public init(_ provider: HeaderFooterProvider<ViewType>){
        viewProvider = provider
    }
    
    /**
     Initiates the view with a String as title
     */
    public init(unicodeScalarLiteral value: String) {
        self.title  = value
    }

    /**
     Initiates the view with a String as title
     */
    public init(extendedGraphemeClusterLiteral value: String) {
        self.title = value
    }

    /**
     Initiates the view with a String as title
     */
    public init(stringLiteral value: String) {
        self.title = value
    }
}


extension Section {
    
    private class KVOWrapper : NSObject{
        
        dynamic var _rows = NSMutableArray()
        var rows : NSMutableArray {
            get {
                return mutableArrayValueForKey("_rows")
            }
        }
        private var _allRows = [BaseRow]()
        
        weak var section: Section?
        
        init(section: Section){
            self.section = section
            super.init()
            addObserver(self, forKeyPath: "_rows", options: NSKeyValueObservingOptions.New.union(.Old), context:nil)
        }
        
        deinit{
            removeObserver(self, forKeyPath: "_rows")
        }
        
        override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
            let newRows = change![NSKeyValueChangeNewKey] as? [BaseRow] ?? []
            let oldRows = change![NSKeyValueChangeOldKey] as? [BaseRow] ?? []
            guard let keyPathValue = keyPath, let changeType = change?[NSKeyValueChangeKindKey] else{ return }
            let delegateValue = section?.form?.delegate
            guard keyPathValue == "_rows" else { return }
            switch changeType.unsignedLongValue {
                case NSKeyValueChange.Setting.rawValue:
                    section?.rowsHaveBeenAdded(newRows, atIndexes:NSIndexSet(index: 0))
                    delegateValue?.rowsHaveBeenAdded(newRows, atIndexPaths:[NSIndexPath(index: 0)])
                case NSKeyValueChange.Insertion.rawValue:
                    let indexSet = change![NSKeyValueChangeIndexesKey] as! NSIndexSet
                    if let _index = section?.index {
                        section?.rowsHaveBeenAdded(newRows, atIndexes: indexSet)
                        delegateValue?.rowsHaveBeenAdded(newRows, atIndexPaths: indexSet.map { NSIndexPath(forRow: $0, inSection: _index ) } )
                    }
                case NSKeyValueChange.Removal.rawValue:
                    let indexSet = change![NSKeyValueChangeIndexesKey] as! NSIndexSet
                    if let _index = section?.index {
                      section?.rowsHaveBeenRemoved(oldRows, atIndexes: indexSet)
                      delegateValue?.rowsHaveBeenRemoved(oldRows, atIndexPaths: indexSet.map { NSIndexPath(forRow: $0, inSection: _index ) } )
                    }
                case NSKeyValueChange.Replacement.rawValue:
                    let indexSet = change![NSKeyValueChangeIndexesKey] as! NSIndexSet
                    if let _index = section?.index {
                      section?.rowsHaveBeenReplaced(oldRows: oldRows, newRows: newRows, atIndexes: indexSet)
                      delegateValue?.rowsHaveBeenReplaced(oldRows: oldRows, newRows: newRows, atIndexPaths: indexSet.map { NSIndexPath(forRow: $0, inSection: _index)})
                    }
                default:
                    assertionFailure()
            }
        }
    }
    
    /**
     *  If this section contains a row (hidden or not) with the passed parameter as tag then that row will be returned.
     *  If not, it returns nil.
     */
    public func rowByTag<Row: RowType>(tag: String) -> Row? {
        guard let index = kvoWrapper._allRows.indexOf({ $0.tag == tag }) else { return nil }
        return kvoWrapper._allRows[index] as? Row
    }
}

extension Section /* Condition */{
    
    //MARK: Hidden/Disable Engine
    
    /**
    Function that evaluates if the section should be hidden and updates it accordingly.
    */
    public func evaluateHidden(){
        if let h = hidden, let f = form {
            switch h {
                case .Function(_ , let callback):
                    hiddenCache = callback(f)
                case .Predicate(let predicate):
                    hiddenCache = predicate.evaluateWithObject(self, substitutionVariables: f.dictionaryValuesToEvaluatePredicate())
            }
            if hiddenCache {
                form?.hideSection(self)
            }
            else{
                form?.showSection(self)
            }
        }
    }
    
    /**
     Internal function called when this section was added to a form.
     */
    func wasAddedToForm(form: Form) {
        self.form = form
        addToRowObservers()
        evaluateHidden()
        for row in kvoWrapper._allRows {
            row.wasAddedToFormInSection(self)
        }
    }
    
    /**
     Internal function called to add this section to the observers of certain rows. Called when the hidden variable is set and depends on other rows.
     */
    func addToRowObservers(){
        guard let h = hidden else { return }
        switch h {
            case .Function(let tags, _):
                form?.addRowObservers(self, rowTags: tags, type: .Hidden)
            case .Predicate(let predicate):
                form?.addRowObservers(self, rowTags: predicate.predicateVars, type: .Hidden)
        }
    }
    
    /**
     Internal function called when this section was removed from a form.
     */
    func willBeRemovedFromForm(){
        for row in kvoWrapper._allRows {
            row.willBeRemovedFromForm()
        }
        removeFromRowObservers()
        self.form = nil
    }
    
    /**
     Internal function called to remove this section from the observers of certain rows. Called when the hidden variable is changed.
     */
    func removeFromRowObservers(){
        guard let h = hidden else { return }
        switch h {
            case .Function(let tags, _):
                form?.removeRowObservers(self, rows: tags, type: .Hidden)
            case .Predicate(let predicate):
                form?.removeRowObservers(self, rows: predicate.predicateVars, type: .Hidden)
        }
    }
    
    private func hideRow(row: BaseRow){
        row.baseCell.cellResignFirstResponder()
        (row as? BaseInlineRowType)?.collapseInlineRow()
        kvoWrapper.rows.removeObject(row)
    }
    
    private func showRow(row: BaseRow){
        guard !kvoWrapper.rows.containsObject(row) else { return }
        guard var index = kvoWrapper._allRows.indexOf(row) else { return }
        var formIndex = NSNotFound
        while (formIndex == NSNotFound && index > 0){
            index = index - 1
            let previous = kvoWrapper._allRows[index]
            formIndex = kvoWrapper.rows.indexOfObject(previous)
        }
        kvoWrapper.rows.insertObject(row, atIndex: formIndex == NSNotFound ? 0 : formIndex + 1)
    }
}

// MARK: Row

protocol Disableable : Taggable {
    func evaluateDisabled()
    var disabled : Condition? { get set }
    var isDisabled : Bool { get }
}

protocol Hidable: Taggable {
    func evaluateHidden()
    var hidden : Condition? { get set }
    var isHidden : Bool { get }
}

extension PresenterRowType {
    
    /**
     Sets a block to be executed when the row presents a view controller
     
     - parameter callback: the block
     
     - returns: this row
     */
    public func onPresent(callback: (FormViewController, ProviderType)->()) -> Self {
        onPresentCallback = callback
        return self
    }
}

extension RowType where Self: BaseRow, Cell : TypedCellType, Cell.Value == Value {
    
    /**
     Default initializer for a row
     */
    public init(_ tag: String? = nil, @noescape _ initializer: (Self -> ()) = { _ in }) {
        self.init(tag: tag)
        RowDefaults.rowInitialization["\(self.dynamicType)"]?(self)
        initializer(self)
    }
}

class RowDefaults {
    private static var cellUpdate = Dictionary<String, (BaseCell, BaseRow) -> Void>()
    private static var cellSetup = Dictionary<String, (BaseCell, BaseRow) -> Void>()
    private static var onCellHighlight = Dictionary<String, (BaseCell, BaseRow) -> Void>()
    private static var onCellUnHighlight = Dictionary<String, (BaseCell, BaseRow) -> Void>()
    private static var rowInitialization = Dictionary<String, BaseRow -> Void>()
    private static var rawCellUpdate = Dictionary<String, Any>()
    private static var rawCellSetup = Dictionary<String, Any>()
    private static var rawOnCellHighlight = Dictionary<String, Any>()
    private static var rawOnCellUnHighlight = Dictionary<String, Any>()
    private static var rawRowInitialization = Dictionary<String, Any>()
}

extension RowType where Self : BaseRow, Cell : TypedCellType, Cell.Value == Value {
    
    /// The default block executed when the cell is updated. Applies to every row of this type.
    public static var defaultCellUpdate:((Cell, Self) -> ())? {
        set {
            if let newValue = newValue {
                let wrapper : (BaseCell, BaseRow) -> Void = { (baseCell: BaseCell, baseRow: BaseRow) in
                    newValue(baseCell as! Cell, baseRow as! Self)
                }
                RowDefaults.cellUpdate["\(self)"] = wrapper
                RowDefaults.rawCellUpdate["\(self)"] = newValue
            }
            else {
                RowDefaults.cellUpdate["\(self)"] = nil
                RowDefaults.rawCellUpdate["\(self)"] = nil
            }
        }
        get{ return RowDefaults.rawCellUpdate["\(self)"] as? ((Cell, Self) -> ()) }
    }
    
    /// The default block executed when the cell is created. Applies to every row of this type.
    public static var defaultCellSetup:((Cell, Self) -> ())? {
        set {
            if let newValue = newValue {
                let wrapper : (BaseCell, BaseRow) -> Void = { (baseCell: BaseCell, baseRow: BaseRow) in
                    newValue(baseCell as! Cell, baseRow as! Self)
                }
                RowDefaults.cellSetup["\(self)"] = wrapper
                RowDefaults.rawCellSetup["\(self)"] = newValue
            }
            else {
                RowDefaults.cellSetup["\(self)"] = nil
                RowDefaults.rawCellSetup["\(self)"] = nil
            }
        }
        get{ return RowDefaults.rawCellSetup["\(self)"] as? ((Cell, Self) -> ()) }
    }
    
    /// The default block executed when the cell becomes first responder. Applies to every row of this type.
    public static var defaultOnCellHighlight:((Cell, Self) -> ())? {
        set {
            if let newValue = newValue {
                let wrapper : (BaseCell, BaseRow) -> Void = { (baseCell: BaseCell, baseRow: BaseRow) in
                    newValue(baseCell as! Cell, baseRow as! Self)
                }
                RowDefaults.onCellHighlight["\(self)"] = wrapper
                RowDefaults.rawOnCellHighlight["\(self)"] = newValue
            }
            else {
                RowDefaults.onCellHighlight["\(self)"] = nil
                RowDefaults.rawOnCellHighlight["\(self)"] = nil
            }
        }
        get{ return RowDefaults.rawOnCellHighlight["\(self)"] as? ((Cell, Self) -> ()) }
    }
    
    /// The default block executed when the cell resigns first responder. Applies to every row of this type.
    public static var defaultOnCellUnHighlight:((Cell, Self) -> ())? {
        set {
            if let newValue = newValue {
            let wrapper : (BaseCell, BaseRow) -> Void = { (baseCell: BaseCell, baseRow: BaseRow) in
                newValue(baseCell as! Cell, baseRow as! Self)
            }
                RowDefaults.onCellUnHighlight ["\(self)"] = wrapper
                RowDefaults.rawOnCellUnHighlight["\(self)"] = newValue
            }
            else {
                RowDefaults.onCellUnHighlight["\(self)"] = nil
                RowDefaults.rawOnCellUnHighlight["\(self)"] = nil
            }
        }
        get { return RowDefaults.rawOnCellUnHighlight["\(self)"] as? ((Cell, Self) -> ()) }
    }
    
    /// The default block executed to initialize a row. Applies to every row of this type.
    public static var defaultRowInitializer:(Self -> ())? {
        set {
            if let newValue = newValue {
                let wrapper : (BaseRow) -> Void = { (baseRow: BaseRow) in
                    newValue(baseRow as! Self)
                }
                RowDefaults.rowInitialization["\(self)"] = wrapper
                RowDefaults.rawRowInitialization["\(self)"] = newValue
            }
            else {
                RowDefaults.rowInitialization["\(self)"] = nil
                RowDefaults.rawRowInitialization["\(self)"] = nil
            }
        }
        get { return RowDefaults.rawRowInitialization["\(self)"] as? (Self -> ()) }
    }
    
    /**
     Sets a block to be called when the value of this row changes.
     
     - returns: this row
     */
    public func onChange(callback: Self -> ()) -> Self{
        callbackOnChange = { [unowned self] in callback(self) }
        return self
    }
    
    /**
     Sets a block to be called when the cell corresponding to this row is refreshed.
     
     - returns: this row
     */
    public func cellUpdate(callback: ((cell: Cell, row: Self) -> ())) -> Self{
        callbackCellUpdate = { [unowned self] in  callback(cell: self.cell, row: self) }
        return self
    }
    
    /**
     Sets a block to be called when the cell corresponding to this row is created.
     
     - returns: this row
     */
    public func cellSetup(callback: ((cell: Cell, row: Self) -> ())) -> Self{
        callbackCellSetup = { [unowned self] (cell:Cell) in  callback(cell: cell, row: self) }
        return self
    }
    
    /**
     Sets a block to be called when the cell corresponding to this row is selected.
     
     - returns: this row
     */
    public func onCellSelection(callback: ((cell: Cell, row: Self) -> ())) -> Self{
        callbackCellOnSelection = { [unowned self] in  callback(cell: self.cell, row: self) }
        return self
    }
    
    /**
     Sets a block to be called when the cell corresponding to this row becomes first responder.
     
     - returns: this row
     */
    public func onCellHighlight(callback: (cell: Cell, row: Self)->()) -> Self {
        callbackOnCellHighlight = { [unowned self] in  callback(cell: self.cell, row: self) }
        return self
    }
    
    /**
     Sets a block to be called when the cell corresponding to this row resigns first responder.
     
     - returns: this row
     */
    public func onCellUnHighlight(callback: (cell: Cell, row: Self)->()) -> Self {
        callbackOnCellUnHighlight = { [unowned self] in  callback(cell: self.cell, row: self) }
        return self
    }
}


public class BaseRow : BaseRowType {

    private var callbackOnChange: (()->Void)?
    private var callbackCellUpdate: (()->Void)?
    private var callbackCellSetup: Any?
    private var callbackCellOnSelection: (()->Void)?
    private var callbackOnCellHighlight: (()->Void)?
    private var callbackOnCellUnHighlight: (()->Void)?
    private var callbackOnExpandInlineRow: Any?
    private var callbackOnCollapseInlineRow: Any?
    private var _inlineRow: BaseRow?
    
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
    public func hightlightCell() {}
    
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
}

extension BaseRow: Equatable, Hidable, Disableable {}


extension BaseRow {
    
    public func reload(rowAnimation: UITableViewRowAnimation = .None) {
        guard let tableView = baseCell?.formViewController()?.tableView ?? (section?.form?.delegate as? FormViewController)?.tableView, indexPath = indexPath() else { return }
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: rowAnimation)
    }
    
    public func deselect(animated: Bool = true) {
        guard let indexPath = indexPath(), tableView = baseCell?.formViewController()?.tableView ?? (section?.form?.delegate as? FormViewController)?.tableView  else {
            return
        }
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
    
    private final func wasAddedToFormInSection(section: Section) {
        self.section = section
        if let t = tag {
            assert(section.form?.rowsByTag[t] == nil, "Duplicate tag \(t)")
            self.section?.form?.rowsByTag[t] = self
        }
        addToRowObservers()
        evaluateHidden()
        evaluateDisabled()
    }
    
    private final func addToHiddenRowObservers() {
        guard let h = hidden else { return }
        switch h {
            case .Function(let tags, _):
                section?.form?.addRowObservers(self, rowTags: tags, type: .Hidden)
            case .Predicate(let predicate):
                section?.form?.addRowObservers(self, rowTags: predicate.predicateVars, type: .Hidden)
        }
    }
    
    private final func addToDisabledRowObservers() {
        guard let d = disabled else { return }
        switch d {
            case .Function(let tags, _):
                section?.form?.addRowObservers(self, rowTags: tags, type: .Disabled)
            case .Predicate(let predicate):
                section?.form?.addRowObservers(self, rowTags: predicate.predicateVars, type: .Disabled)
        }
    }
    
    private final func addToRowObservers(){
        addToHiddenRowObservers()
        addToDisabledRowObservers()
    }
    
    private final func willBeRemovedFromForm(){
        (self as? BaseInlineRowType)?.collapseInlineRow()
        if let t = tag {
            section?.form?.rowsByTag[t] = nil
        }
        removeFromRowObservers()
    }
    
    
    private final func removeFromHiddenRowObservers() {
        guard let h = hidden else { return }
        switch h {
            case .Function(let tags, _):
                section?.form?.removeRowObservers(self, rows: tags, type: .Hidden)
            case .Predicate(let predicate):
                section?.form?.removeRowObservers(self, rows: predicate.predicateVars, type: .Hidden)
        }
    }
    
    private final func removeFromDisabledRowObservers() {
        guard let d = disabled else { return }
        switch d {
            case .Function(let tags, _):
                section?.form?.removeRowObservers(self, rows: tags, type: .Disabled)
            case .Predicate(let predicate):
                section?.form?.removeRowObservers(self, rows: predicate.predicateVars, type: .Disabled)
        }
    }
    
    
    private final func removeFromRowObservers(){
        removeFromHiddenRowObservers()
        removeFromDisabledRowObservers()
    }
}

public class RowOf<T: Equatable>: BaseRow {
    
    /// The typed value of this row.
    public var value : T?{
        didSet {
            guard value != oldValue else { return }
            guard let form = section?.form else { return }
            if let delegate = form.delegate {
                delegate.rowValueHasBeenChanged(self, oldValue: oldValue, newValue: value)
                callbackOnChange?()
            }
            guard let t = tag else { return }
            if let rowObservers = form.rowObservers[t]?[.Hidden]{
                for rowObserver in rowObservers {
                    (rowObserver as? Hidable)?.evaluateHidden()
                }
            }
            if let rowObservers = form.rowObservers[t]?[.Disabled]{
                for rowObserver in rowObservers {
                    (rowObserver as? Disableable)?.evaluateDisabled()
                }
            }
        }
    }
    
    /// The untyped value of this row.
    public override var baseValue: Any? {
        get { return value }
        set { value = newValue as? T }
    }
    
    /// Variable used in rows with options that serves to generate the options for that row.
    public var dataProvider: DataProvider<T>?
    
    /// Block variable used to get the String that should be displayed for the value of this row.
    public var displayValueFor : (T? -> String?)? = {
        if let t = $0 {
            return String(t)
        }
        return nil
    }
    
    public required init(tag: String?){
        super.init(tag: tag)
    }
}

/// Generic class that represents an Eureka row.
public class Row<T: Equatable, Cell: CellType where Cell: BaseCell, Cell.Value == T>: RowOf<T>,  TypedRowType {
    
    /// Responsible for creating the cell for this row.
    public var cellProvider = CellProvider<Cell>()
    
    /// The type of the cell associated to this row.
    public let cellType: Cell.Type! = Cell.self
    
    private var _cell: Cell! {
        didSet {
            RowDefaults.cellSetup["\(self.dynamicType)"]?(_cell, self)
            (callbackCellSetup as? (Cell -> ()))?(_cell)
        }
    }
    
    /// The cell associated to this row.
    public var cell : Cell! {
        guard _cell == nil else{
            return _cell
        }
        let result = cellProvider.createCell(self.cellStyle)
        result.row = self
        result.setup()
        _cell = result
        return _cell
    }
    
    /// The untyped cell associated to this row
    public override var baseCell: BaseCell { return cell }

    public required init(tag: String?) {
        super.init(tag: tag)
    }
    
    /**
     Method that reloads the cell
     */
    override public func updateCell() {
        super.updateCell()
        cell.update()
        customUpdateCell()
        RowDefaults.cellUpdate["\(self.dynamicType)"]?(cell, self)
        callbackCellUpdate?()
        cell.setNeedsLayout()
        cell.setNeedsUpdateConstraints()
    }
    
    /**
     Method called when the cell belonging to this row was selected. Must call the corresponding method in its cell.
     */
    public override func didSelect() {
        super.didSelect()
        if !isDisabled {
            cell?.didSelect()
        }
        customDidSelect()
        callbackCellOnSelection?()
    }
    
    /**
     Method that is responsible for highlighting the cell.
     */
    override public func hightlightCell() {
        super.hightlightCell()
        cell.highlight()
        RowDefaults.onCellHighlight["\(self.dynamicType)"]?(cell, self)
        callbackOnCellHighlight?()
    }
    
    /**
     Method that is responsible for unhighlighting the cell.
     */
    public override func unhighlightCell() {
        super.unhighlightCell()
        cell.unhighlight()
        RowDefaults.onCellUnHighlight["\(self.dynamicType)"]?(cell, self)
        callbackOnCellUnHighlight?()
    }
    
    /**
     Will be called inside `didSelect` method of the row. Can be used to customize row selection from the definition of the row.
     */
    public func customDidSelect(){}
    
    /**
     Will be called inside `updateCell` method of the row. Can be used to customize reloading a row from its definition.
     */
    public func customUpdateCell(){}
    
}

/// Generic row type where a user must select a value among several options.
public class SelectorRow<T: Equatable, VCType: TypedRowControllerType, Cell: CellType where VCType: UIViewController,  VCType.RowValue == T, Cell: BaseCell, Cell.Value == T >: OptionsRow<T, Cell>, PresenterRowType {
    
    /// Defines how the view controller will be presented, pushed, etc.
    public var presentationMode: PresentationMode<VCType>?
    
    /// Will be called before the presentation occurs.
    public var onPresentCallback : ((FormViewController, VCType)->())?
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
    
    public required convenience init(_ tag: String, @noescape _ initializer: (SelectorRow<T, VCType, Cell> -> ()) = { _ in }) {
        self.init(tag:tag)
        RowDefaults.rowInitialization["\(self.dynamicType)"]?(self)
        initializer(self)
    }
    
    /**
     Extends `didSelect` method
     */
    public override func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            if let presentationMode = presentationMode {
                if let controller = presentationMode.createController(){
                    controller.row = self
                    if let title = selectorTitle {
                        controller.title = title
                    }
                    onPresentCallback?(cell.formViewController()!, controller)
                    presentationMode.presentViewController(controller, row: self, presentingViewController: self.cell.formViewController()!)
                }
                else{
                    presentationMode.presentViewController(nil, row: self, presentingViewController: self.cell.formViewController()!)
                }
            }
        }
    }
    
    /**
     Prepares the pushed row setting its title and completion callback.
     */
    public override func prepareForSegue(segue: UIStoryboardSegue) {
        super.prepareForSegue(segue)
        guard let rowVC = segue.destinationViewController as? VCType else {
            return
        }
        if let title = selectorTitle {
            rowVC.title = title
        }
        if let callback = self.presentationMode?.completionHandler {
            rowVC.completionCallback = callback
        }
        onPresentCallback?(cell.formViewController()!, rowVC)
        rowVC.row = self
    }
}

/// Generic options selector row that allows multiple selection.
public class GenericMultipleSelectorRow<T: Hashable, VCType: TypedRowControllerType, Cell: CellType where VCType: UIViewController,  VCType.RowValue == Set<T>, Cell: BaseCell, Cell.Value == Set<T>>: Row<Set<T>, Cell>, PresenterRowType {
    
    /// Defines how the view controller will be presented, pushed, etc.
    public var presentationMode: PresentationMode<VCType>?
    
    /// Will be called before the presentation occurs.
    public var onPresentCallback : ((FormViewController, VCType)->())?
    
    /// Title to be displayed for the options
    public var selectorTitle: String?
    
    /// Options from which the user will choose
    public var options: [T] {
        get { return self.dataProvider?.arrayData?.map({ $0.first! }) ?? [] }
        set { self.dataProvider = DataProvider(arrayData: newValue.map({ Set<T>(arrayLiteral: $0) })) }
    }
    
    required public init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .Show(controllerProvider: ControllerProvider.Callback { return VCType() }, completionCallback: { vc in vc.navigationController?.popViewControllerAnimated(true) })
    }
    
    public required convenience init(_ tag: String, @noescape _ initializer: (GenericMultipleSelectorRow<T, VCType, Cell> -> ()) = { _ in }) {
        self.init(tag:tag)
        RowDefaults.rowInitialization["\(self.dynamicType)"]?(self)
        initializer(self)
    }
    
    /**
     Extends `didSelect` method
     */
    public override func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            if let presentationMode = presentationMode {
                if let controller = presentationMode.createController(){
                    controller.row = self
                    if let title = selectorTitle {
                        controller.title = title
                    }
                    onPresentCallback?(cell.formViewController()!, controller)
                    presentationMode.presentViewController(controller, row: self, presentingViewController: self.cell.formViewController()!)
                }
                else{
                    presentationMode.presentViewController(nil, row: self, presentingViewController: self.cell.formViewController()!)
                }
            }
        }
    }
    
    /**
     Prepares the pushed row setting its title and completion callback.
     */
    public override func prepareForSegue(segue: UIStoryboardSegue) {
        super.prepareForSegue(segue)
        guard let rowVC = segue.destinationViewController as? VCType else {
            return
        }
        if let title = selectorTitle {
            rowVC.title = title
        }
        if let callback = self.presentationMode?.completionHandler{
            rowVC.completionCallback = callback
        }
        onPresentCallback?(cell.formViewController()!, rowVC)
        rowVC.row = self
        
    }
}

// MARK: Operators

infix operator +++{ associativity left precedence 95 }

/**
 Appends a section to a form
 
 - parameter left:  the form
 - parameter right: the section to be appended
 
 - returns: the updated form
 */
public func +++(left: Form, right: Section) -> Form {
    left.append(right)
    return left
}

infix operator +++= { associativity left precedence 95 }

/**
 Appends a section to a form without return statement
 
 - parameter left:  the form
 - parameter right: the section to be appended
 */
public func +++=(inout left: Form, right: Section){
    left = left +++ right
}

/**
 Appends a row to the last section of a form
 
 - parameter left:  the form
 - parameter right: the row
 */
public func +++=(inout left: Form, right: BaseRow){
    left +++= Section() <<< right
}

/**
 Creates a form with two sections
 
 - parameter left:  the first section
 - parameter right: the second section
 
 - returns: the created form
 */
public func +++(left: Section, right: Section) -> Form {
    let form = Form()
    form +++ left +++ right
    return form
}

/**
 Creates a form with two sections, each containing one row.
 
 - parameter left:  The row for the first section
 - parameter right: The row for the second section
 
 - returns: the created form
 */
public func +++(left: BaseRow, right: BaseRow) -> Form {
    let form = Section() <<< left +++ Section() <<< right
    return form
}

infix operator <<<{ associativity left precedence 100 }

/**
 Appends a row to a section.
 
 - parameter left:  the section
 - parameter right: the row to be appended
 
 - returns: the section
 */
public func <<<(left: Section, right: BaseRow) -> Section {
    left.append(right)
    return left
}

/**
 Creates a section with two rows
 
 - parameter left:  The first row
 - parameter right: The second row
 
 - returns: the created section
 */
public func <<<(left: BaseRow, right: BaseRow) -> Section {
    let section = Section()
    section <<< left <<< right
    return section
}

/**
 Appends a collection of rows to a section
 
 - parameter lhs: the section
 - parameter rhs: the rows to be appended
 */
public func +=< C : CollectionType where C.Generator.Element == BaseRow>(inout lhs: Section, rhs: C){
    lhs.appendContentsOf(rhs)
}

/**
 Appends a collection of section to a form
 
 - parameter lhs: the form
 - parameter rhs: the sections to be appended
 */
public func +=< C : CollectionType where C.Generator.Element == Section>(inout lhs: Form, rhs: C){
    lhs.appendContentsOf(rhs)
}

// MARK: FormCells

/**
*  Protocol for cells that contain a UITextField
*/
public protocol TextFieldCell {
    var textField : UITextField { get }
}

/**
 *  Protocol for cells that contain a UITextView
 */
public protocol AreaCell {
    var textView: UITextView { get }
}

/**
*  Protocol for cells that contain a postal address
*/
public protocol PostalAddressCell {
	var streetTextField: UITextField { get }
	var stateTextField: UITextField { get }
	var postalCodeTextField: UITextField { get }
	var cityTextField: UITextField { get }
	var countryTextField: UITextField { get }
}

extension CellType where Self: UITableViewCell {
}

/// Base class for the Eureka cells
public class BaseCell : UITableViewCell, BaseCellType {
    
    /// Untyped row associated to this cell.
    public var baseRow: BaseRow! { return nil }
    
    /// Block that returns the height for this cell.
    public var height: (()->CGFloat)?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public required override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    /**
     Function that returns the FormViewController this cell belongs to.
     */
    public func formViewController () -> FormViewController? {
        var responder : AnyObject? = self
        while responder != nil {
            if responder! is FormViewController {
                return responder as? FormViewController
            }
            responder = responder?.nextResponder()
        }
        return nil
    }
    
    public func setup(){}
    public func update() {}
    
    public func didSelect() {}
    
    public func highlight() {}
    public func unhighlight() {}
    
    
    /**
     If the cell can become first responder. By default returns false
     */
    public func cellCanBecomeFirstResponder() -> Bool {
        return false
    }
    
    /**
     Called when the cell becomes first responder
     */
    public func cellBecomeFirstResponder(direction: Direction = .Down) -> Bool {
        return becomeFirstResponder()
    }
    
    /**
     Called when the cell resigns first responder
     */
    public func cellResignFirstResponder() -> Bool {
        return resignFirstResponder()
    }
}

/// Generic class that represents the Eureka cells.
public class Cell<T: Equatable> : BaseCell, TypedCellType {
    
    public typealias Value = T
    
    /// The row associated to this cell
    public weak var row : RowOf<T>!
    
    /// Returns the navigationAccessoryView if it is defined or calls super if not.
    override public var inputAccessoryView: UIView? {
        if let v = formViewController()?.inputAccessoryViewForRow(row){
            return v
        }
        return super.inputAccessoryView
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    /**
     Function responsible for setting up the cell at creation time.
     */
    public override func setup(){
        super.setup()
    }
        
    /**
     Function responsible for updating the cell each time it is reloaded.
     */
    public override func update(){
        super.update()
        textLabel?.text = row.title
        textLabel?.textColor = row.isDisabled ? .grayColor() : .blackColor()
        detailTextLabel?.text = row.displayValueFor?(row.value)
    }
    
    /**
     Called when the cell was selected.
     */
    public override func didSelect() {}
    
    public override func canBecomeFirstResponder() -> Bool {
        return false
    }
    
    public override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result {
            formViewController()?.beginEditing(self)
        }
        return result
    }
    
    public override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        if result {
            formViewController()?.endEditing(self)
        }
        return result
    }
    
    /// The untyped row associated to this cell.
    public override var baseRow : BaseRow! { return row }
}

public struct CellProvider<Cell: BaseCell where Cell: CellType> {
    
    /// Nibname of the cell that will be created.
    public private (set) var nibName: String?
    
    /// Bundle from which to get the nib file.
    public private (set) var bundle: NSBundle!

    
    public init(){}
    
    public init(nibName: String, bundle: NSBundle? = nil){
        self.nibName = nibName
        self.bundle = bundle ?? NSBundle(forClass: Cell.self)
    }
    
    /**
     Creates the cell with the specified style.
     
     - parameter cellStyle: The style with which the cell will be created.
     
     - returns: the cell
     */
    func createCell(cellStyle: UITableViewCellStyle) -> Cell {
        if let nibName = self.nibName {
            return bundle.loadNibNamed(nibName, owner: nil, options: nil).first as! Cell
        }
        return Cell.init(style: cellStyle, reuseIdentifier: nil)
    }
}

/**
 Enumeration that defines how a controller should be created.
 
 - Callback->VCType: Creates the controller inside the specified block
 - NibFile:          Loads a controller from a nib file in some bundle
 - StoryBoard:       Loads the controller from a Storyboard by its storyboard id
 */
public enum ControllerProvider<VCType: UIViewController>{
    
    /**
     *  Creates the controller inside the specified block
     */
    case Callback(builder: (() -> VCType))
    
    /**
     *  Loads a controller from a nib file in some bundle
     */
    case NibFile(name: String, bundle: NSBundle?)
    
    /**
     *  Loads the controller from a Storyboard by its storyboard id
     */
    case StoryBoard(storyboardId: String, storyboardName: String, bundle: NSBundle?)
    
    func createController() -> VCType {
        switch self {
            case .Callback(let builder):
                return builder()
            case .NibFile(let nibName, let bundle):
                return VCType.init(nibName: nibName, bundle:bundle ?? NSBundle(forClass: VCType.self))
            case .StoryBoard(let storyboardId, let storyboardName, let bundle):
                let sb = UIStoryboard(name: storyboardName, bundle: bundle ?? NSBundle(forClass: VCType.self))
                return sb.instantiateViewControllerWithIdentifier(storyboardId) as! VCType
        }
    }
}

/**
 *  Responsible for the options passed to a selector view controller
 */
public struct DataProvider<T: Equatable> {
    
    public let arrayData: [T]?
    
    public init(arrayData: [T]){
        self.arrayData = arrayData
    }
}

/**
 Defines how a controller should be presented.
 
 - Show?:           Shows the controller with `showViewController(...)`.
 - PresentModally?: Presents the controller modally.
 - SegueName?:      Performs the segue with the specified identifier (name).
 - SegueClass?:     Performs a segue from a segue class.
 */
public enum PresentationMode<VCType: UIViewController> {
    
    /**
     *  Shows the controller, created by the specified provider, with `showViewController(...)`.
     */
    case Show(controllerProvider: ControllerProvider<VCType>, completionCallback: (UIViewController->())?)
    
    /**
     *  Presents the controller, created by the specified provider, modally.
     */
    case PresentModally(controllerProvider: ControllerProvider<VCType>, completionCallback: (UIViewController->())?)
    
    /**
     *  Performs the segue with the specified identifier (name).
     */
    case SegueName(segueName: String, completionCallback: (UIViewController->())?)
    
    /**
     *  Performs a segue from a segue class.
     */
    case SegueClass(segueClass: UIStoryboardSegue.Type, completionCallback: (UIViewController->())?)
    
    
    case Popover(controllerProvider: ControllerProvider<VCType>, completionCallback: (UIViewController->())?)
    
    
    var completionHandler: (UIViewController ->())? {
        switch self{
            case .Show(_, let completionCallback):
                return completionCallback
            case .PresentModally(_, let completionCallback):
                return completionCallback
            case .SegueName(_, let completionCallback):
                return completionCallback
            case .SegueClass(_, let completionCallback):
                return completionCallback
            case .Popover(_, let completionCallback):
                return completionCallback
        }
    }
    
    
    /**
     Present the view controller provided by PresentationMode. Should only be used from custom row implementation.
     
     - parameter viewController:           viewController to present if it makes sense (normally provided by createController method)
     - parameter row:                      associated row
     - parameter presentingViewController: form view controller
     */
    public func presentViewController(viewController: VCType!, row: BaseRow, presentingViewController:FormViewController){
        switch self {
            case .Show(_, _):
                presentingViewController.showViewController(viewController, sender: row)
            case .PresentModally(_, _):
                presentingViewController.presentViewController(viewController, animated: true, completion: nil)
            case .SegueName(let segueName, _):
                presentingViewController.performSegueWithIdentifier(segueName, sender: row)
            case .SegueClass(let segueClass, _):
                let segue = segueClass.init(identifier: row.tag, source: presentingViewController, destination: viewController)
                presentingViewController.prepareForSegue(segue, sender: row)
                segue.perform()
            case .Popover(_, _):
                guard let porpoverController = viewController.popoverPresentationController else {
                    fatalError()
                }
                porpoverController.sourceView = porpoverController.sourceView ?? presentingViewController.tableView
                porpoverController.sourceRect = porpoverController.sourceRect ?? row.baseCell.frame
                presentingViewController.presentViewController(viewController, animated: true, completion: nil)
            }
        
    }
    
    /**
     Creates the view controller specified by presentation mode. Should only be used from custom row implementation.
     
     - returns: the created view controller or nil depending on the PresentationMode type.
     */
    public func createController() -> VCType? {
        switch self {
            case .Show(let controllerProvider, let completionCallback):
                let controller = controllerProvider.createController()
                let completionController = controller as? RowControllerType
                if let callback = completionCallback {
                    completionController?.completionCallback = callback
                }
                return controller
            case .PresentModally(let controllerProvider, let completionCallback):
                let controller = controllerProvider.createController()
                let completionController = controller as? RowControllerType
                if let callback = completionCallback {
                    completionController?.completionCallback = callback
                }
                return controller
            case .Popover(let controllerProvider, let completionCallback):
                let controller = controllerProvider.createController()
                controller.modalPresentationStyle = .Popover
                let completionController = controller as? RowControllerType
                if let callback = completionCallback {
                    completionController?.completionCallback = callback
                }
                return controller
            default:
                return nil
        }
    }
}

/**
 *  Protocol to be implemented by custom formatters.
 */
public protocol FormatterProtocol {
    func getNewPosition(forPosition forPosition: UITextPosition, inTextInput textInput: UITextInput, oldValue: String?, newValue: String?) -> UITextPosition
}

//MARK: Predicate Machine

enum ConditionType {
    case Hidden, Disabled
}

/**
 Enumeration that are used to specify the disbaled and hidden conditions of rows
 
 - Function:  A function that calculates the result
 - Predicate: A predicate that returns the result
 */
public enum Condition {
    /**
     *  Calculate the condition inside a block
     *
     *  @param            Array of tags of the rows this function depends on
     *  @param Form->Bool The block that calculates the result
     *
     *  @return If the condition is true or false
     */
    case Function([String], Form->Bool)
    
    /**
     *  Calculate the condition using a NSPredicate
     *
     *  @param NSPredicate The predicate that will be evaluated
     *
     *  @return If the condition is true or false
     */
    case Predicate(NSPredicate)
}

extension Condition : BooleanLiteralConvertible {
    
    /**
     Initialize a condition to return afixed boolean value always
     */
    public init(booleanLiteral value: Bool){
        self = Condition.Function([]) { _ in return value }
    }
}

extension Condition : StringLiteralConvertible {
    
    /**
     Initialize a Condition with a string that will be converted to a NSPredicate
     */
    public init(stringLiteral value: String){
        self = .Predicate(NSPredicate(format: value))
    }
    
    /**
     Initialize a Condition with a string that will be converted to a NSPredicate
     */
    public init(unicodeScalarLiteral value: String) {
        self = .Predicate(NSPredicate(format: value))
    }
    
    /**
     Initialize a Condition with a string that will be converted to a NSPredicate
     */
    public init(extendedGraphemeClusterLiteral value: String) {
        self = .Predicate(NSPredicate(format: value))
    }
}

//MARK: Errors

/**
Errors thrown by Eureka

- DuplicatedTag: When a section or row is inserted whose tag dows already exist
*/
public enum EurekaError : ErrorType {
    case DuplicatedTag(tag: String)
}

//Mark: FormViewController

/**
*  A protocol implemented by FormViewController
*/
public protocol FormViewControllerProtocol {
    func beginEditing<T:Equatable>(cell: Cell<T>)
    func endEditing<T:Equatable>(cell: Cell<T>)
    
    func insertAnimationForRows(rows: [BaseRow]) -> UITableViewRowAnimation
    func deleteAnimationForRows(rows: [BaseRow]) -> UITableViewRowAnimation
    func reloadAnimationOldRows(oldRows: [BaseRow], newRows: [BaseRow]) -> UITableViewRowAnimation
    func insertAnimationForSections(sections : [Section]) -> UITableViewRowAnimation
    func deleteAnimationForSections(sections : [Section]) -> UITableViewRowAnimation
    func reloadAnimationOldSections(oldSections: [Section], newSections:[Section]) -> UITableViewRowAnimation
}

/**
 *  Navigation options for a form view controller.
 */
public struct RowNavigationOptions : OptionSetType {
    
    private enum NavigationOptions : Int {
        case Disabled = 0, Enabled = 1, StopDisabledRow = 2, SkipCanNotBecomeFirstResponderRow = 4
    }
    public let rawValue: Int
    public  init(rawValue: Int){ self.rawValue = rawValue}
    private init(_ options:NavigationOptions ){ self.rawValue = options.rawValue }
    @available(*, unavailable, renamed="Disabled")
    
    /// No navigation.
    public static let None = RowNavigationOptions(.Disabled)
    
    /// No navigation.
    public static let Disabled = RowNavigationOptions(.Disabled)
    
    /// Full navigation.
    public static let Enabled = RowNavigationOptions(.Enabled)
    
    /// Break navigation when next row is disabled.
    public static let StopDisabledRow = RowNavigationOptions(.StopDisabledRow)
    
    /// Break navigation when next row cannot become first responder.
    public static let SkipCanNotBecomeFirstResponderRow = RowNavigationOptions(.SkipCanNotBecomeFirstResponderRow)
}

/**
 *  Defines the configuration for the keyboardType of FieldRows.
 */
public struct KeyboardReturnTypeConfiguration {
    /// Used when the next row is available.
    public var nextKeyboardType = UIReturnKeyType.Next
    
    /// Used if next row is not available.
    public var defaultKeyboardType = UIReturnKeyType.Default
}

/**
 *  Options that define when an inline row should collapse.
 */
public struct InlineRowHideOptions : OptionSetType {
    
    private enum _InlineRowHideOptions : Int {
        case Never = 0, AnotherInlineRowIsShown = 1, FirstResponderChanges = 2
    }
    public let rawValue: Int
    public init(rawValue: Int){ self.rawValue = rawValue}
    private init(_ options:_InlineRowHideOptions ){ self.rawValue = options.rawValue }
    
    /// Never collapse automatically. Only when user taps inline row.
    public static let Never = InlineRowHideOptions(.Never)
    
    /// Collapse qhen another inline row expands. Just one inline row will be expanded at a time.
    public static let AnotherInlineRowIsShown = InlineRowHideOptions(.AnotherInlineRowIsShown)
    
    /// Collapse when first responder changes.
    public static let FirstResponderChanges = InlineRowHideOptions(.FirstResponderChanges)
}

/// View controller that shows a form.
public class FormViewController : UIViewController, FormViewControllerProtocol {
    
    @IBOutlet public var tableView: UITableView?
    
    private lazy var _form : Form = { [weak self] in
        let form = Form()
        form.delegate = self
        return form
        }()
    
    public var form : Form {
        get { return _form }
        set {
            _form.delegate = nil
            tableView?.endEditing(false)
            _form = newValue
            _form.delegate = self
            if isViewLoaded() && tableView?.window != nil {
                tableView?.reloadData()
            }
        }
    }
    
    /// Accessory view that is responsible for the navigation between rows
    lazy public var navigationAccessoryView : NavigationAccessoryView = {
        [unowned self] in
        let naview = NavigationAccessoryView(frame: CGRectMake(0, 0, self.view.frame.width, 44.0))
        naview.tintColor = self.view.tintColor
        return naview
        }()
    
    /// Defines the behaviour of the navigation between rows
    public var navigationOptions : RowNavigationOptions?
    private var tableViewStyle: UITableViewStyle = .Grouped
    
    public init(style: UITableViewStyle) {
        super.init(nibName: nil, bundle: nil)
        tableViewStyle = style
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if tableView == nil {
            tableView = UITableView(frame: view.bounds, style: tableViewStyle)
            tableView?.autoresizingMask = UIViewAutoresizing.FlexibleWidth.union(.FlexibleHeight)
            if #available(iOS 9.0, *){
                tableView?.cellLayoutMarginsFollowReadableWidth = false
            }
        }
        if tableView?.superview == nil {
            view.addSubview(tableView!)
        }
        if tableView?.delegate == nil {
            tableView?.delegate = self
        }
        if tableView?.dataSource == nil {
            tableView?.dataSource = self
        }
        tableView?.estimatedRowHeight = BaseRow.estimatedRowHeight
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView?.indexPathForSelectedRow {
            tableView?.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
            tableView?.selectRowAtIndexPath(selectedIndexPath, animated: false, scrollPosition: .None)
            tableView?.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        let baseRow = sender as? BaseRow
        baseRow?.prepareForSegue(segue)
    }
    
    //MARK: FormDelegate
    
    public func rowValueHasBeenChanged(row: BaseRow, oldValue: Any?, newValue: Any?) {}
    
    //MARK: FormViewControllerProtocol
    
    /**
    Called when a cell becomes first responder
    */
    public final func beginEditing<T:Equatable>(cell: Cell<T>) {
        cell.row.hightlightCell()
        guard let _ = tableView where (form.inlineRowHideOptions ?? Form.defaultInlineRowHideOptions).contains(.FirstResponderChanges) else { return }
        let row = cell.baseRow
        let inlineRow = row._inlineRow
        for row in form.allRows.filter({ $0 !== row && $0 !== inlineRow && $0._inlineRow != nil }) {
            if let inlineRow = row as? BaseInlineRowType {
                inlineRow.collapseInlineRow()
            }
        }
    }
    
    /**
     Called when a cell resigns first responder
     */
    public final func endEditing<T:Equatable>(cell: Cell<T>) {
        cell.row.unhighlightCell()
    }
    
    /**
     Returns the animation for the insertion of the given rows.
     */
    public func insertAnimationForRows(rows: [BaseRow]) -> UITableViewRowAnimation {
        return .Fade
    }
    
    /**
     Returns the animation for the deletion of the given rows.
     */
    public func deleteAnimationForRows(rows: [BaseRow]) -> UITableViewRowAnimation {
        return .Fade
    }
    
    /**
     Returns the animation for the reloading of the given rows.
     */
    public func reloadAnimationOldRows(oldRows: [BaseRow], newRows: [BaseRow]) -> UITableViewRowAnimation {
        return .Automatic
    }
    
    /**
     Returns the animation for the insertion of the given sections.
     */
    public func insertAnimationForSections(sections: [Section]) -> UITableViewRowAnimation {
        return .Automatic
    }
    
    /**
     Returns the animation for the deletion of the given sections.
     */
    public func deleteAnimationForSections(sections: [Section]) -> UITableViewRowAnimation {
        return .Automatic
    }
    
    /**
     Returns the animation for the reloading of the given sections.
     */
    public func reloadAnimationOldSections(oldSections: [Section], newSections: [Section]) -> UITableViewRowAnimation {
        return .Automatic
    }
    
    //MARK: TextField and TextView Delegate
    
    public func textInputShouldBeginEditing<T>(textInput: UITextInput, cell: Cell<T>) -> Bool {
        return true
    }
    
    public func textInputDidBeginEditing<T>(textInput: UITextInput, cell: Cell<T>) {
        if let row = cell.row as? KeyboardReturnHandler {
            let nextRow = nextRowForRow(cell.row, withDirection: .Down)
            if let textField = textInput as? UITextField {
                textField.returnKeyType = nextRow != nil ? (row.keyboardReturnType?.nextKeyboardType ?? (form.keyboardReturnType?.nextKeyboardType ?? Form.defaultKeyboardReturnType.nextKeyboardType )) : (row.keyboardReturnType?.defaultKeyboardType ?? (form.keyboardReturnType?.defaultKeyboardType ?? Form.defaultKeyboardReturnType.defaultKeyboardType))
            }
            else if let textView = textInput as? UITextView {
                textView.returnKeyType = nextRow != nil ? (row.keyboardReturnType?.nextKeyboardType ?? (form.keyboardReturnType?.nextKeyboardType ?? Form.defaultKeyboardReturnType.nextKeyboardType )) : (row.keyboardReturnType?.defaultKeyboardType ?? (form.keyboardReturnType?.defaultKeyboardType ?? Form.defaultKeyboardReturnType.defaultKeyboardType))
            }
        }
    }
    
    public func textInputShouldEndEditing<T>(textInput: UITextInput, cell: Cell<T>) -> Bool {
        return true
    }
    
    public func textInputDidEndEditing<T>(textInput: UITextInput, cell: Cell<T>) {
        
    }
    
    public func textInput<T>(textInput: UITextInput, shouldChangeCharactersInRange range: NSRange, replacementString string: String, cell: Cell<T>) -> Bool {
        return true
    }
    
    public func textInputShouldClear<T>(textInput: UITextInput, cell: Cell<T>) -> Bool {
        return true
    }

    public func textInputShouldReturn<T>(textInput: UITextInput, cell: Cell<T>) -> Bool {
        if let nextRow = nextRowForRow(cell.row, withDirection: .Down){
            if nextRow.baseCell.cellCanBecomeFirstResponder(){
                nextRow.baseCell.cellBecomeFirstResponder()
                return true
            }
        }
        tableView?.endEditing(true)
        return true
    }
    
    //MARK: Private
    
    private var oldBottomInset : CGFloat?
}

extension FormViewController : UITableViewDelegate {
    
    //MARK: UITableViewDelegate
    
    public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard tableView == self.tableView else { return }
        form[indexPath].updateCell()
    }
    
    public func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return indexPath
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard tableView == self.tableView else { return }
        let row = form[indexPath]
        // row.baseCell.cellBecomeFirstResponder() may be cause InlineRow collapsed then section count will be changed. Use orignal indexPath will out of  section's bounds.
        if !row.baseCell.cellCanBecomeFirstResponder() || !row.baseCell.cellBecomeFirstResponder() {
            self.tableView?.endEditing(true)
        }
        row.didSelect()
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard tableView == self.tableView else { return tableView.rowHeight }
        let row = form[indexPath.section][indexPath.row]
        return row.baseCell.height?() ?? tableView.rowHeight
    }
    
    public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard tableView == self.tableView else { return tableView.rowHeight }
        let row = form[indexPath.section][indexPath.row]
        return row.baseCell.height?() ?? tableView.estimatedRowHeight
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return form[section].header?.viewForSection(form[section], type: .Header, controller: self)
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return form[section].footer?.viewForSection(form[section], type:.Footer, controller: self)
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let height = form[section].header?.height {
            return height()
        }
        guard let view = form[section].header?.viewForSection(form[section], type: .Header, controller: self) else{
            return UITableViewAutomaticDimension
        }
        guard view.bounds.height != 0 else {
            return UITableViewAutomaticDimension
        }
        return view.bounds.height
    }
    
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let height = form[section].footer?.height {
            return height()
        }
        guard let view = form[section].footer?.viewForSection(form[section], type: .Footer, controller: self) else{
            return UITableViewAutomaticDimension
        }
        guard view.bounds.height != 0 else {
            return UITableViewAutomaticDimension
        }
        return view.bounds.height
    }
}

extension FormViewController : UITableViewDataSource {
    
    //MARK: UITableViewDataSource
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return form.count
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return form[section].count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return form[indexPath].baseCell
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return form[section].header?.title
    }
    
    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return form[section].footer?.title
    }
}

extension FormViewController : FormDelegate {
    
    //MARK: FormDelegate
    
    public func sectionsHaveBeenAdded(sections: [Section], atIndexes: NSIndexSet){
        tableView?.beginUpdates()
        tableView?.insertSections(atIndexes, withRowAnimation: insertAnimationForSections(sections))
        tableView?.endUpdates()
    }
    
    public func sectionsHaveBeenRemoved(sections: [Section], atIndexes: NSIndexSet){
        tableView?.beginUpdates()
        tableView?.deleteSections(atIndexes, withRowAnimation: deleteAnimationForSections(sections))
        tableView?.endUpdates()
    }
    
    public func sectionsHaveBeenReplaced(oldSections oldSections:[Section], newSections: [Section], atIndexes: NSIndexSet){
        tableView?.beginUpdates()
        tableView?.reloadSections(atIndexes, withRowAnimation: reloadAnimationOldSections(oldSections, newSections: newSections))
        tableView?.endUpdates()
    }
    
    public func rowsHaveBeenAdded(rows: [BaseRow], atIndexPaths: [NSIndexPath]) {
        tableView?.beginUpdates()
        tableView?.insertRowsAtIndexPaths(atIndexPaths, withRowAnimation: insertAnimationForRows(rows))
        tableView?.endUpdates()
    }
    
    public func rowsHaveBeenRemoved(rows: [BaseRow], atIndexPaths: [NSIndexPath]) {
        tableView?.beginUpdates()
        tableView?.deleteRowsAtIndexPaths(atIndexPaths, withRowAnimation: deleteAnimationForRows(rows))
        tableView?.endUpdates()
    }

    public func rowsHaveBeenReplaced(oldRows oldRows:[BaseRow], newRows: [BaseRow], atIndexPaths: [NSIndexPath]){
        tableView?.beginUpdates()
        tableView?.reloadRowsAtIndexPaths(atIndexPaths, withRowAnimation: reloadAnimationOldRows(oldRows, newRows: newRows))
        tableView?.endUpdates()
    }
}

extension FormViewController : UIScrollViewDelegate {
    
    //MARK: UIScrollViewDelegate
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        tableView?.endEditing(true)
    }
}

extension FormViewController {
    
    //MARK: KeyBoard Notifications
    
    /**
    Called when the keyboard will appear. Adjusts insets of the tableView and scrolls it if necessary.
    */
    public func keyboardWillShow(notification: NSNotification){
        guard let table = tableView, let cell = table.findFirstResponder()?.formCell() else { return }
        let keyBoardInfo = notification.userInfo!
        let keyBoardFrame = table.window!.convertRect((keyBoardInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue)!, toView: table.superview)
        let newBottomInset = table.frame.origin.y + table.frame.size.height - keyBoardFrame.origin.y
        var tableInsets = table.contentInset
        var scrollIndicatorInsets = table.scrollIndicatorInsets
        oldBottomInset = oldBottomInset ?? tableInsets.bottom
        if newBottomInset > oldBottomInset {
            tableInsets.bottom = newBottomInset
            scrollIndicatorInsets.bottom = tableInsets.bottom
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(keyBoardInfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue)
            UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: keyBoardInfo[UIKeyboardAnimationCurveUserInfoKey]!.integerValue)!)
            table.contentInset = tableInsets
            table.scrollIndicatorInsets = scrollIndicatorInsets
            if let selectedRow = table.indexPathForCell(cell) {
                table.scrollToRowAtIndexPath(selectedRow, atScrollPosition: .None, animated: false)
            }
            UIView.commitAnimations()
        }
    }
    
    /**
     Called when the keyboard will disappear. Adjusts insets of the tableView.
     */
    public func keyboardWillHide(notification: NSNotification){
        guard let table = tableView,  let oldBottom = oldBottomInset else  { return }
        let keyBoardInfo = notification.userInfo!
        var tableInsets = table.contentInset
        var scrollIndicatorInsets = table.scrollIndicatorInsets
        tableInsets.bottom = oldBottom
        scrollIndicatorInsets.bottom = tableInsets.bottom
        oldBottomInset = nil
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(keyBoardInfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue)
        UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: keyBoardInfo[UIKeyboardAnimationCurveUserInfoKey]!.integerValue)!)
        table.contentInset = tableInsets
        table.scrollIndicatorInsets = scrollIndicatorInsets
        UIView.commitAnimations()
    }
}

public enum Direction { case Up, Down }

extension FormViewController {
    
    //MARK: Navigation Methods
    
    func navigationDone(sender: UIBarButtonItem) {
        tableView?.endEditing(true)
    }
    
    func navigationAction(sender: UIBarButtonItem) {
        navigateToDirection(sender == navigationAccessoryView.previousButton ? .Up : .Down)
    }
    
    private func navigateToDirection(direction: Direction){
        guard let currentCell = tableView?.findFirstResponder()?.formCell() else { return }
        guard let currentIndexPath = tableView?.indexPathForCell(currentCell) else { assertionFailure(); return }
        guard let nextRow = nextRowForRow(form[currentIndexPath], withDirection: direction) else { return }
        if nextRow.baseCell.cellCanBecomeFirstResponder(){
            tableView?.scrollToRowAtIndexPath(nextRow.indexPath()!, atScrollPosition: .None, animated: false)
            nextRow.baseCell.cellBecomeFirstResponder(direction)
        }
    }
    
    private func nextRowForRow(currentRow: BaseRow, withDirection direction: Direction) -> BaseRow? {
        
        let options = navigationOptions ?? Form.defaultNavigationOptions
        guard options.contains(.Enabled) else { return nil }
        guard let nextRow = direction == .Down ? form.nextRowForRow(currentRow) : form.previousRowForRow(currentRow) else { return nil }
        if nextRow.isDisabled && options.contains(.StopDisabledRow) {
            return nil
        }
        if !nextRow.baseCell.cellCanBecomeFirstResponder() && !nextRow.isDisabled && !options.contains(.SkipCanNotBecomeFirstResponderRow){
            return nil
        }
        if (!nextRow.isDisabled && nextRow.baseCell.cellCanBecomeFirstResponder()){
            return nextRow
        }
        return nextRowForRow(nextRow, withDirection:direction)
    }
    
    /**
     Returns the navigation accessory view if it is enabled. Returns nil otherwise.
     */
    public func inputAccessoryViewForRow(row: BaseRow) -> UIView? {
        let options = navigationOptions ?? Form.defaultNavigationOptions
        guard options.contains(.Enabled) else { return nil }
        guard row.baseCell.cellCanBecomeFirstResponder() else { return nil}
        navigationAccessoryView.previousButton.enabled = nextRowForRow(row, withDirection: .Up) != nil
        navigationAccessoryView.doneButton.target = self
        navigationAccessoryView.doneButton.action = "navigationDone:"
        navigationAccessoryView.previousButton.target = self
        navigationAccessoryView.previousButton.action = "navigationAction:"
        navigationAccessoryView.nextButton.target = self
        navigationAccessoryView.nextButton.action = "navigationAction:"
        navigationAccessoryView.nextButton.enabled = nextRowForRow(row, withDirection: .Down) != nil
        return navigationAccessoryView
    }
}

/// Class for the navigation accessory view used in FormViewController
public class NavigationAccessoryView : UIToolbar {
    
    public var previousButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem(rawValue: 105)!, target: nil, action: nil)
    public var nextButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem(rawValue: 106)!, target: nil, action: nil)
    public var doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: nil, action: nil)
    private var fixedSpace = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
    private var flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
    
    public override init(frame: CGRect) {
        super.init(frame: CGRectMake(0, 0, frame.size.width, 44.0))
        autoresizingMask = .FlexibleWidth
        fixedSpace.width = 22.0
        setItems([previousButton, fixedSpace, nextButton, flexibleSpace, doneButton], animated: false)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {}
}

// MARK: SelectableSection

/**
Defines how the selection works in a SelectableSection

- MultipleSelection: Multiple options can be selected at once
- SingleSelection:   Only one selection at a time. Can additionally specify if deselection is enabled or not.
*/
public enum SelectionType {
    
    /**
     * Multiple options can be selected at once
     */
    case MultipleSelection
    
    /**
     * Only one selection at a time. Can additionally specify if deselection is enabled or not.
     */
    case SingleSelection(enableDeselection: Bool)
}

/**
 *  Protocol to be implemented by selectable sections types. Enables easier customization
 */
public protocol SelectableSectionType: CollectionType {
    typealias SelectableRow: BaseRow, SelectableRowType
    
    /// Defines how the selection works (single / multiple selection)
    var selectionType : SelectionType { get set }
    
    /// A closure called when a row of this section is selected.
    var onSelectSelectableRow: ((SelectableRow.Cell, SelectableRow) -> Void)? { get set }
    
    func selectedRow() -> SelectableRow?
    func selectedRows() -> [SelectableRow]
}

extension SelectableSectionType where Self: Section, SelectableRow.Value == SelectableRow.Cell.Value {
    
    /**
     Returns the selected row of this section. Should be used if selectionType is SingleSelection
     */
    public func selectedRow() -> SelectableRow? {
        return selectedRows().first
    }
    
    /**
     Returns the selected rows of this section. Should be used if selectionType is MultipleSelection
     */
    public func selectedRows() -> [SelectableRow] {
        return filter({ (row: BaseRow) -> Bool in
            row is SelectableRow && row.baseValue != nil
        }).map({ $0 as! SelectableRow})
    }
    
    /**
     Internal function used to set up a collection of rows before they are added to the section
     */
    func prepareSelectableRows(rows: [BaseRow]){
        for row in rows {
            if let row = row as? SelectableRow {
                row.onCellSelection { [weak self] cell, row in
                    guard let s = self else { return }
                    switch s.selectionType {
                    case .MultipleSelection:
                        row.value = row.value == nil ? row.selectableValue : nil
                        row.updateCell()
                    case .SingleSelection(let enableDeselection):
                        s.filter { $0.baseValue != nil && $0 != row }.forEach {
                            $0.baseValue = nil
                            $0.updateCell()
                        }
                        row.value = !enableDeselection || row.value == nil ? row.selectableValue : nil
                        row.updateCell()
                    }
                    s.onSelectSelectableRow?(cell, row)
                }
            }
        }
    }
    
}

/// A subclass of Section that serves to create a section with a list of selectable options.
public class SelectableSection<Row, T where Row: BaseRow, Row: SelectableRowType, Row.Value == T, T == Row.Cell.Value> : Section, SelectableSectionType  {
    
    public typealias SelectableRow = Row
    
    /// Defines how the selection works (single / multiple selection)
    public var selectionType = SelectionType.SingleSelection(enableDeselection: true)
    
    /// A closure called when a row of this section is selected.
    public var onSelectSelectableRow: ((Row.Cell, Row) -> Void)?
    
    public required init(@noescape _ initializer: Section -> ()) {
        super.init(initializer)
    }
    
    public init(_ header: String, selectionType: SelectionType, @noescape _ initializer: Section -> () = { _ in }) {
        self.selectionType = selectionType
        super.init(header, initializer)
    }
    
    public override func rowsHaveBeenAdded(rows: [BaseRow], atIndexes: NSIndexSet) {
        prepareSelectableRows(rows)
    }
}


/**
*  Protocol to be implemented by PostalAddress types.
*/
public protocol PostalAddressType: Equatable {
	var street: String? { get set }
	var state: String? { get set }
	var postalCode: String? { get set }
	var city: String? { get set }
	var country: String? { get set }
}

public func == <T: PostalAddressType>(lhs: T, rhs: T) -> Bool {
	return lhs.street == rhs.street && lhs.state == rhs.state && lhs.postalCode == rhs.postalCode && lhs.city == rhs.city && lhs.country == rhs.country
}

public struct PostalAddress: PostalAddressType {
	public var street: String?
	public var state: String?
	public var postalCode: String?
	public var city: String?
	public var country: String?
	
	public init(){}
	
	public init(street: String?, state: String?, postalCode: String?, city: String?, country: String?) {
		self.street = street
		self.state = state
		self.postalCode = postalCode
		self.city = city
		self.country = country
	}
}