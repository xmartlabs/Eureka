//
//  Section.swift
//  Eureka
//
//  Created by Martin Barreto on 2/23/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

/// The delegate of the Eureka sections.
public protocol SectionDelegate: class {
    func rowsHaveBeenAdded(rows: [BaseRow], atIndexes:NSIndexSet)
    func rowsHaveBeenRemoved(rows: [BaseRow], atIndexes:NSIndexSet)
    func rowsHaveBeenReplaced(oldRows oldRows:[BaseRow], newRows: [BaseRow], atIndexes: NSIndexSet)
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



extension Section {
    
    internal class KVOWrapper : NSObject{
        
        dynamic var _rows = NSMutableArray()
        var rows : NSMutableArray {
            get {
                return mutableArrayValueForKey("_rows")
            }
        }
        var _allRows = [BaseRow]()
        
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
                section?.rowsHaveBeenAdded(newRows, atIndexes: indexSet)
                if let _index = section?.index {
                    delegateValue?.rowsHaveBeenAdded(newRows, atIndexPaths: indexSet.map { NSIndexPath(forRow: $0, inSection: _index ) } )
                }
            case NSKeyValueChange.Removal.rawValue:
                let indexSet = change![NSKeyValueChangeIndexesKey] as! NSIndexSet
                section?.rowsHaveBeenRemoved(oldRows, atIndexes: indexSet)
                if let _index = section?.index {
                    delegateValue?.rowsHaveBeenRemoved(oldRows, atIndexPaths: indexSet.map { NSIndexPath(forRow: $0, inSection: _index ) } )
                }
            case NSKeyValueChange.Replacement.rawValue:
                let indexSet = change![NSKeyValueChangeIndexesKey] as! NSIndexSet
                section?.rowsHaveBeenReplaced(oldRows: oldRows, newRows: newRows, atIndexes: indexSet)
                if let _index = section?.index {
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
    lazy var kvoWrapper: KVOWrapper = { [unowned self] in return KVOWrapper(section: self) }()
    var headerView: UIView?
    var footerView: UIView?
    var hiddenCache = false
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
    
    func hideRow(row: BaseRow){
        row.baseCell.cellResignFirstResponder()
        (row as? BaseInlineRowType)?.collapseInlineRow()
        kvoWrapper.rows.removeObject(row)
    }
    
    func showRow(row: BaseRow){
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

