//
//  Form.swift
//  Eureka
//
//  Created by Martin Barreto on 2/23/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation


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
    var tagToValues = [String: AnyObject]()
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
    
    class KVOWrapper : NSObject {
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
        return tagToValues
    }
    
    func addRowObservers(taggable: Taggable, rowTags: [String], type: ConditionType) {
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
    
    func removeRowObservers(taggable: Taggable, rows: [String], type: ConditionType) {
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
    
    func hideSection(section: Section){
        kvoWrapper.sections.removeObject(section)
    }
    
    func showSection(section: Section){
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