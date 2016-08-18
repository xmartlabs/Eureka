//  Section.swift
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

/// The delegate of the Eureka sections.
public protocol SectionDelegate: class {
    func rowsHaveBeenAdded(_ rows: [BaseRow], atIndexes:IndexSet)
    func rowsHaveBeenRemoved(_ rows: [BaseRow], atIndexes:IndexSet)
    func rowsHaveBeenReplaced(oldRows:[BaseRow], newRows: [BaseRow], atIndexes: IndexSet)
}

// MARK: Section

extension Section : Equatable {}

public func ==(lhs: Section, rhs: Section) -> Bool{
    return lhs === rhs
}

extension Section : Hidable, SectionDelegate {}

extension Section {
    
    public func reload(_ rowAnimation: UITableViewRowAnimation = .none) {
        guard let tableView = (form?.delegate as? FormViewController)?.tableView, let index = index else { return }
        tableView.reloadSections(IndexSet(integer: index), with: rowAnimation)
    }
}



extension Section {
    
    internal class KVOWrapper : NSObject{
        
        dynamic var _rows = NSMutableArray()
        var rows : NSMutableArray {
            get {
                return mutableArrayValue(forKey: "_rows")
            }
        }
        var _allRows = [BaseRow]()
        
        weak var section: Section?
        
        init(section: Section){
            self.section = section
            super.init()
            addObserver(self, forKeyPath: "_rows", options: NSKeyValueObservingOptions.new.union(.old), context:nil)
        }
        
        deinit{
            removeObserver(self, forKeyPath: "_rows")
        }
        
        //
        // TODO: Fix this
        //
        func observeValue(forKeyPath keyPath: String?, of object: AnyObject?, change: [NSKeyValueChangeKey : AnyObject]?, context: UnsafeMutablePointer<Void>?) {
            let newRows = change![NSKeyValueChangeKey.newKey] as? [BaseRow] ?? []
            let oldRows = change![NSKeyValueChangeKey.oldKey] as? [BaseRow] ?? []
            guard let keyPathValue = keyPath, let changeType = change?[NSKeyValueChangeKey.kindKey] else{ return }
            let delegateValue = section?.form?.delegate
            guard keyPathValue == "_rows" else { return }
            switch changeType.uintValue {
            case NSKeyValueChange.setting.rawValue:
                section?.rowsHaveBeenAdded(newRows, atIndexes:IndexSet(integer: 0))
                delegateValue?.rowsHaveBeenAdded(newRows, atIndexPaths:[IndexPath(index: 0)])
            case NSKeyValueChange.insertion.rawValue:
                let indexSet = change![NSKeyValueChangeKey.indexesKey] as! IndexSet
                section?.rowsHaveBeenAdded(newRows, atIndexes: indexSet)
                if let _index = section?.index {
                    delegateValue?.rowsHaveBeenAdded(newRows, atIndexPaths: indexSet.map { IndexPath(row: $0, section: _index ) } )
                }
            case NSKeyValueChange.removal.rawValue:
                let indexSet = change![NSKeyValueChangeKey.indexesKey] as! IndexSet
                section?.rowsHaveBeenRemoved(oldRows, atIndexes: indexSet)
                if let _index = section?.index {
                    delegateValue?.rowsHaveBeenRemoved(oldRows, atIndexPaths: indexSet.map { IndexPath(row: $0, section: _index ) } )
                }
            case NSKeyValueChange.replacement.rawValue:
                let indexSet = change![NSKeyValueChangeKey.indexesKey] as! IndexSet
                section?.rowsHaveBeenReplaced(oldRows: oldRows, newRows: newRows, atIndexes: indexSet)
                if let _index = section?.index {
                    delegateValue?.rowsHaveBeenReplaced(oldRows: oldRows, newRows: newRows, atIndexPaths: indexSet.map { IndexPath(row: $0, section: _index)})
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
    public func rowByTag<Row: RowType>(_ tag: String) -> Row? {
        guard let index = kvoWrapper._allRows.index(where: { $0.tag == tag }) else { return nil }
        return kvoWrapper._allRows[index] as? Row
    }
}


/// The class representing the sections in a Eureka form.
public class Section {
    
    /// The tag is used to uniquely identify a Section. Must be unique among sections and rows.
    public var tag: String?
    
    /// The form that contains this section
    public internal(set) weak var form: Form?
    
    /// The header of this section.
    public var header: HeaderFooterViewRepresentable? {
        willSet {
            headerView = nil
        }
    }
    
    /// The footer of this section
    public var footer: HeaderFooterViewRepresentable? {
        willSet {
            footerView = nil
        }
    }
    
    /// Index of this section in the form it belongs to.
    public var index: Int? { return form?.index(of: self) }
    
    /// Condition that determines if the section should be hidden or not.
    public var hidden : Condition? {
        willSet { removeFromRowObservers() }
        didSet { addToRowObservers() }
    }
    
    /// Returns if the section is currently hidden or not
    public var isHidden : Bool { return hiddenCache }
    
    public required init(){}
    
    public required init( _ initializer: (Section) -> ()){
        initializer(self)
    }
    
    public init(_ header: String, _ initializer: (Section) -> () = { _ in }){
        self.header = HeaderFooterView(stringLiteral: header)
        initializer(self)
    }
    
    public init(header: String, footer: String, _ initializer: (Section) -> () = { _ in }){
        self.header = HeaderFooterView(stringLiteral: header)
        self.footer = HeaderFooterView(stringLiteral: footer)
        initializer(self)
    }
    
    public init(footer: String, _ initializer: (Section) -> () = { _ in }){
        self.footer = HeaderFooterView(stringLiteral: footer)
        initializer(self)
    }
    
    //MARK: SectionDelegate
    
    /**
     *  Delegate method called by the framework when one or more rows have been added to the section.
     */
    public func rowsHaveBeenAdded(_ rows: [BaseRow], atIndexes:IndexSet) {}
    
    /**
     *  Delegate method called by the framework when one or more rows have been removed from the section.
     */
    public func rowsHaveBeenRemoved(_ rows: [BaseRow], atIndexes:IndexSet) {}
    
    /**
     *  Delegate method called by the framework when one or more rows have been replaced in the section.
     */
    public func rowsHaveBeenReplaced(oldRows:[BaseRow], newRows: [BaseRow], atIndexes: IndexSet) {}
    
    //MARK: Private
    lazy var kvoWrapper: KVOWrapper = { [unowned self] in return KVOWrapper(section: self) }()
    var headerView: UIView?
    var footerView: UIView?
    var hiddenCache = false
}


extension Section : MutableCollection, BidirectionalCollection {
    
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

    public subscript (range: Range<Int>) -> [BaseRow] {
        get { return kvoWrapper.rows.objects(at: NSIndexSet(indexesIn: NSRange(range)) as IndexSet) as! [BaseRow] }
        set { kvoWrapper.rows.replaceObjects(in: NSRange(range), withObjectsFrom: newValue) }
    }

    public func index(after i: Int) -> Int {return i + 1}
    public func index(before i: Int) -> Int {return i - 1}

}

extension Section : RangeReplaceableCollection {
    
    // MARK: RangeReplaceableCollectionType
    
    public func append(_ formRow: BaseRow){
        kvoWrapper.rows.insert(formRow, at: kvoWrapper.rows.count)
        kvoWrapper._allRows.append(formRow)
        formRow.wasAddedToFormInSection(self)
    }
    
    public func append<S : Sequence where S.Iterator.Element == BaseRow>(contentsOf newElements: S) {
        kvoWrapper.rows.addObjects(from: newElements.map { $0 })
        kvoWrapper._allRows.append(contentsOf: newElements)
        for row in newElements{
            row.wasAddedToFormInSection(self)
        }
    }
    
    public func reserveCapacity(_ n: Int){}
    
    public func replaceSubrange<C : Collection where C.Iterator.Element == BaseRow>(_ subRange: Range<Int>, with newElements: C) {
        for i in subRange.lowerBound..<subRange.upperBound {
            if let row = kvoWrapper.rows.object(at: i) as? BaseRow {
                row.willBeRemovedFromForm()
                kvoWrapper._allRows.remove(at: kvoWrapper._allRows.index(of: row)!)
            }
        }
        kvoWrapper.rows.replaceObjects(in: NSMakeRange(subRange.lowerBound, subRange.upperBound - subRange.lowerBound), withObjectsFrom: newElements.map { $0 })
        
        kvoWrapper._allRows.insert(contentsOf: newElements, at: indexForInsertionAtIndex(subRange.lowerBound))
        for row in newElements{
            row.wasAddedToFormInSection(self)
        }
    }
    
    public func removeAll(keepingCapacity keepCapacity: Bool = false) {
        // not doing anything with capacity
        for row in kvoWrapper._allRows{
            row.willBeRemovedFromForm()
        }
        kvoWrapper.rows.removeAllObjects()
        kvoWrapper._allRows.removeAll()
    }
    
    private func indexForInsertionAtIndex(_ index: Int) -> Int {
        guard index != 0 else { return 0 }
        
        let row = kvoWrapper.rows[index-1]
        if let i = kvoWrapper._allRows.index(of: row as! BaseRow){
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
            case .function(_ , let callback):
                hiddenCache = callback(f)
            case .predicate(let predicate):
                hiddenCache = predicate.evaluate(with: self, substitutionVariables: f.dictionaryValuesToEvaluatePredicate())
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
    func wasAddedToForm(_ form: Form) {
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
        case .function(let tags, _):
            form?.addRowObservers(self, rowTags: tags, type: .hidden)
        case .predicate(let predicate):
            form?.addRowObservers(self, rowTags: predicate.predicateVars, type: .hidden)
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
        case .function(let tags, _):
            form?.removeRowObservers(self, rows: tags, type: .hidden)
        case .predicate(let predicate):
            form?.removeRowObservers(self, rows: predicate.predicateVars, type: .hidden)
        }
    }
    
    func hideRow(_ row: BaseRow){
        row.baseCell.cellResignFirstResponder()
        (row as? BaseInlineRowType)?.collapseInlineRow()
        kvoWrapper.rows.remove(row)
    }
    
    func showRow(_ row: BaseRow){
        guard !kvoWrapper.rows.contains(row) else { return }
        guard var index = kvoWrapper._allRows.index(of: row) else { return }
        var formIndex = NSNotFound
        while (formIndex == NSNotFound && index > 0){
            index = index - 1
            let previous = kvoWrapper._allRows[index]
            formIndex = kvoWrapper.rows.index(of: previous)
        }
        kvoWrapper.rows.insert(row, at: formIndex == NSNotFound ? 0 : formIndex + 1)
    }
}

