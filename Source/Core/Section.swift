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
import UIKit

/// The delegate of the Eureka sections.
public protocol SectionDelegate: class {
    func rowsHaveBeenAdded(_ rows: [BaseRow], at: IndexSet)
    func rowsHaveBeenRemoved(_ rows: [BaseRow], at: IndexSet)
    func rowsHaveBeenReplaced(oldRows: [BaseRow], newRows: [BaseRow], at: IndexSet)
}

// MARK: Section

extension Section : Equatable {}

public func == (lhs: Section, rhs: Section) -> Bool {
    return lhs === rhs
}

extension Section : Hidable, SectionDelegate {}

extension Section {

    public func reload(with rowAnimation: UITableView.RowAnimation = .none) {
        guard let tableView = (form?.delegate as? FormViewController)?.tableView, let index = index, index < tableView.numberOfSections else { return }
        tableView.reloadSections(IndexSet(integer: index), with: rowAnimation)
    }
}

extension Section {

    internal class KVOWrapper: NSObject {

        @objc dynamic private var _rows = NSMutableArray()
        var rows: NSMutableArray {
            return mutableArrayValue(forKey: "_rows")
        }
        var _allRows = [BaseRow]()

        private weak var section: Section?

        init(section: Section) {
            self.section = section
            super.init()
            addObserver(self, forKeyPath: "_rows", options: [.new, .old], context:nil)
        }

        deinit {
            removeObserver(self, forKeyPath: "_rows")
            _rows.removeAllObjects()
            _allRows.removeAll()
        }

        public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            let newRows = change![NSKeyValueChangeKey.newKey] as? [BaseRow] ?? []
            let oldRows = change![NSKeyValueChangeKey.oldKey] as? [BaseRow] ?? []
            guard let keyPathValue = keyPath, let changeType = change?[NSKeyValueChangeKey.kindKey] else { return }
            let delegateValue = section?.form?.delegate
            guard keyPathValue == "_rows" else { return }
            switch (changeType as! NSNumber).uintValue {
            case NSKeyValueChange.setting.rawValue:
                section?.rowsHaveBeenAdded(newRows, at: IndexSet(integer: 0))
                delegateValue?.rowsHaveBeenAdded(newRows, at:[IndexPath(index: 0)])
            case NSKeyValueChange.insertion.rawValue:
                let indexSet = change![NSKeyValueChangeKey.indexesKey] as! IndexSet
                section?.rowsHaveBeenAdded(newRows, at: indexSet)
                if let _index = section?.index {
                    delegateValue?.rowsHaveBeenAdded(newRows, at: indexSet.map { IndexPath(row: $0, section: _index ) })
                }
            case NSKeyValueChange.removal.rawValue:
                let indexSet = change![NSKeyValueChangeKey.indexesKey] as! IndexSet
                section?.rowsHaveBeenRemoved(oldRows, at: indexSet)
                if let _index = section?.index {
                    delegateValue?.rowsHaveBeenRemoved(oldRows, at: indexSet.map { IndexPath(row: $0, section: _index ) })
                }
            case NSKeyValueChange.replacement.rawValue:
                let indexSet = change![NSKeyValueChangeKey.indexesKey] as! IndexSet
                section?.rowsHaveBeenReplaced(oldRows: oldRows, newRows: newRows, at: indexSet)
                if let _index = section?.index {
                    delegateValue?.rowsHaveBeenReplaced(oldRows: oldRows, newRows: newRows, at: indexSet.map { IndexPath(row: $0, section: _index)})
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
    public func rowBy<Row: RowType>(tag: String) -> Row? {
        guard let index = kvoWrapper._allRows.index(where: { $0.tag == tag }) else { return nil }
        return kvoWrapper._allRows[index] as? Row
    }
}

/// The class representing the sections in a Eureka form.
open class Section {

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
    public var hidden: Condition? {
        willSet { removeFromRowObservers() }
        didSet { addToRowObservers() }
    }

    /// Returns if the section is currently hidden or not.
    public var isHidden: Bool { return hiddenCache }

    /// Returns all the rows in this section, including hidden rows.
    public var allRows: [BaseRow] {
        return kvoWrapper._allRows
    }

    public required init() {}

    #if swift(>=4.1)
    public required init<S>(_ elements: S) where S: Sequence, S.Element == BaseRow {
        self.append(contentsOf: elements)
    }
    #endif

    public init(_ initializer: @escaping (Section) -> Void) {
        initializer(self)
    }

    public init(_ header: String, _ initializer: @escaping (Section) -> Void = { _ in }) {
        self.header = HeaderFooterView(stringLiteral: header)
        initializer(self)
    }

    public init(header: String, footer: String, _ initializer: (Section) -> Void = { _ in }) {
        self.header = HeaderFooterView(stringLiteral: header)
        self.footer = HeaderFooterView(stringLiteral: footer)
        initializer(self)
    }

    public init(footer: String, _ initializer: (Section) -> Void = { _ in }) {
        self.footer = HeaderFooterView(stringLiteral: footer)
        initializer(self)
    }

    // MARK: SectionDelegate

    /**
     *  Delegate method called by the framework when one or more rows have been added to the section.
     */
    open func rowsHaveBeenAdded(_ rows: [BaseRow], at: IndexSet) {}

    /**
     *  Delegate method called by the framework when one or more rows have been removed from the section.
     */
    open func rowsHaveBeenRemoved(_ rows: [BaseRow], at: IndexSet) {}

    /**
     *  Delegate method called by the framework when one or more rows have been replaced in the section.
     */
    open func rowsHaveBeenReplaced(oldRows: [BaseRow], newRows: [BaseRow], at: IndexSet) {}

    // MARK: Private
    lazy var kvoWrapper: KVOWrapper = { [unowned self] in return KVOWrapper(section: self) }()

    var headerView: UIView?
    var footerView: UIView?
    var hiddenCache = false
}

extension Section: MutableCollection, BidirectionalCollection {

    // MARK: MutableCollectionType

    public var startIndex: Int { return 0 }
    public var endIndex: Int { return kvoWrapper.rows.count }
    public subscript (position: Int) -> BaseRow {
        get {
            if position >= kvoWrapper.rows.count {
                assertionFailure("Section: Index out of bounds")
            }
            return kvoWrapper.rows[position] as! BaseRow
        }
        set {
            if position > kvoWrapper.rows.count {
                assertionFailure("Section: Index out of bounds")
            }

            if position < kvoWrapper.rows.count {
                let oldRow = kvoWrapper.rows[position]
                let oldRowIndex = kvoWrapper._allRows.index(of: oldRow as! BaseRow)!
                // Remove the previous row from the form
                kvoWrapper._allRows[oldRowIndex].willBeRemovedFromSection()
                kvoWrapper._allRows[oldRowIndex] = newValue
            } else {
                kvoWrapper._allRows.append(newValue)
            }

            kvoWrapper.rows[position] = newValue
            newValue.wasAddedTo(section: self)
        }
    }

    public subscript (range: Range<Int>) -> ArraySlice<BaseRow> {
        get { return kvoWrapper.rows.map { $0 as! BaseRow }[range] }
        set { replaceSubrange(range, with: newValue) }
    }

    public func index(after i: Int) -> Int { return i + 1 }
    public func index(before i: Int) -> Int { return i - 1 }

}

extension Section: RangeReplaceableCollection {

    // MARK: RangeReplaceableCollectionType

    public func append(_ formRow: BaseRow) {
        kvoWrapper.rows.insert(formRow, at: kvoWrapper.rows.count)
        kvoWrapper._allRows.append(formRow)
        formRow.wasAddedTo(section: self)
    }

    public func append<S: Sequence>(contentsOf newElements: S) where S.Iterator.Element == BaseRow {
        kvoWrapper.rows.addObjects(from: newElements.map { $0 })
        kvoWrapper._allRows.append(contentsOf: newElements)
        for row in newElements {
            row.wasAddedTo(section: self)
        }
    }

    public func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, C.Element == BaseRow {
        for i in subrange.lowerBound..<subrange.upperBound {
            if let row = kvoWrapper.rows.object(at: i) as? BaseRow {
                row.willBeRemovedFromSection()
                kvoWrapper._allRows.remove(at: kvoWrapper._allRows.index(of: row)!)
            }
        }

        kvoWrapper.rows.replaceObjects(in: NSRange(location: subrange.lowerBound, length: subrange.upperBound - subrange.lowerBound),
                                       withObjectsFrom: newElements.map { $0 })

        kvoWrapper._allRows.insert(contentsOf: newElements, at: indexForInsertion(at: subrange.lowerBound))
        for row in newElements {
            row.wasAddedTo(section: self)
        }
    }

    public func removeAll(keepingCapacity keepCapacity: Bool = false) {
        // not doing anything with capacity
        for row in kvoWrapper._allRows {
            row.willBeRemovedFromSection()
        }
        kvoWrapper.rows.removeAllObjects()
        kvoWrapper._allRows.removeAll()
    }

    @discardableResult
    public func remove(at position: Int) -> BaseRow {
        let row = kvoWrapper.rows.object(at: position) as! BaseRow
        row.willBeRemovedFromSection()
        kvoWrapper.rows.removeObject(at: position)
        if let index = kvoWrapper._allRows.index(of: row) {
            kvoWrapper._allRows.remove(at: index)
        }

        return row
    }

    private func indexForInsertion(at index: Int) -> Int {
        guard index != 0 else { return 0 }

        let row = kvoWrapper.rows[index-1]
        if let i = kvoWrapper._allRows.index(of: row as! BaseRow) {
            return i + 1
        }
        return kvoWrapper._allRows.count
    }

}

extension Section /* Condition */ {

    // MARK: Hidden/Disable Engine

    /**
     Function that evaluates if the section should be hidden and updates it accordingly.
     */
    public final func evaluateHidden() {
        if let h = hidden, let f = form {
            switch h {
            case .function(_, let callback):
                hiddenCache = callback(f)
            case .predicate(let predicate):
                hiddenCache = predicate.evaluate(with: self, substitutionVariables: f.dictionaryValuesToEvaluatePredicate())
            }
            if hiddenCache {
                form?.hideSection(self)
            } else {
                form?.showSection(self)
            }
        }
    }

    /**
     Internal function called when this section was added to a form.
     */
    func wasAddedTo(form: Form) {
        self.form = form
        addToRowObservers()
        evaluateHidden()
        for row in kvoWrapper._allRows {
            row.wasAddedTo(section: self)
        }
    }

    /**
     Internal function called to add this section to the observers of certain rows. Called when the hidden variable is set and depends on other rows.
     */
    func addToRowObservers() {
        guard let h = hidden else { return }
        switch h {
        case .function(let tags, _):
            form?.addRowObservers(to: self, rowTags: tags, type: .hidden)
        case .predicate(let predicate):
            form?.addRowObservers(to: self, rowTags: predicate.predicateVars, type: .hidden)
        }
    }

    /**
     Internal function called when this section was removed from a form.
     */
    func willBeRemovedFromForm() {
        for row in kvoWrapper._allRows {
            row.willBeRemovedFromForm()
        }
        removeFromRowObservers()
        self.form = nil
    }

    /**
     Internal function called to remove this section from the observers of certain rows. Called when the hidden variable is changed.
     */
    func removeFromRowObservers() {
        guard let h = hidden else { return }
        switch h {
        case .function(let tags, _):
            form?.removeRowObservers(from: self, rowTags: tags, type: .hidden)
        case .predicate(let predicate):
            form?.removeRowObservers(from: self, rowTags: predicate.predicateVars, type: .hidden)
        }
    }

    func hide(row: BaseRow) {
        row.baseCell.cellResignFirstResponder()
        (row as? BaseInlineRowType)?.collapseInlineRow()
        kvoWrapper.rows.remove(row)
    }

    func show(row: BaseRow) {
        guard !kvoWrapper.rows.contains(row) else { return }
        guard var index = kvoWrapper._allRows.index(of: row) else { return }
        var formIndex = NSNotFound
        while formIndex == NSNotFound && index > 0 {
            index = index - 1
            let previous = kvoWrapper._allRows[index]
            formIndex = kvoWrapper.rows.index(of: previous)
        }
        kvoWrapper.rows.insert(row, at: formIndex == NSNotFound ? 0 : formIndex + 1)
    }
}

extension Section /* Helpers */ {

    /**
     *  This method inserts a row after another row.
     *  It is useful if you want to insert a row after a row that is currently hidden. Otherwise use `insert(at: Int)`.
     *  It throws an error if the old row is not in this section.
     */
    public func insert(row newRow: BaseRow, after previousRow: BaseRow) throws {
        guard let rowIndex = (kvoWrapper._allRows as [BaseRow]).index(of: previousRow) else {
            throw EurekaError.rowNotInSection(row: previousRow)
        }
        kvoWrapper._allRows.insert(newRow, at: index(after: rowIndex))
        show(row: newRow)
        newRow.wasAddedTo(section: self)
    }

}

/**
 *  Navigation options for a form view controller.
 */
public struct MultivaluedOptions: OptionSet {

    private enum Options: Int {
        case none = 0, insert = 1, delete = 2, reorder = 4
    }
    public let rawValue: Int
    public  init(rawValue: Int) { self.rawValue = rawValue}
    private init(_ options: Options) { self.rawValue = options.rawValue }

    /// No multivalued.
    public static let None = MultivaluedOptions(.none)

    /// Allows user to insert rows.
    public static let Insert = MultivaluedOptions(.insert)

    /// Allows user to delete rows.
    public static let Delete = MultivaluedOptions(.delete)

    /// Allows user to reorder rows
    public static let Reorder = MultivaluedOptions(.reorder)
}

/**
 *  Multivalued sections allows us to easily create insertable, deletable and reorderable sections. By using a multivalued section we can add multiple values for a certain field, such as telephone numbers in a contact.
 */
open class MultivaluedSection: Section {

    public var multivaluedOptions: MultivaluedOptions
    public var showInsertIconInAddButton = true
    public var addButtonProvider: ((MultivaluedSection) -> ButtonRow) = { _ in
        return ButtonRow {
            $0.title = "Add"
            $0.cellStyle = .value1
        }.cellUpdate { cell, _ in
            cell.textLabel?.textAlignment = .left
        }
    }

    public var multivaluedRowToInsertAt: ((Int) -> BaseRow)?

    public required init(multivaluedOptions: MultivaluedOptions = MultivaluedOptions.Insert.union(.Delete),
                header: String = "",
                footer: String = "",
                _ initializer: (MultivaluedSection) -> Void = { _ in }) {
        self.multivaluedOptions = multivaluedOptions
        super.init(header: header, footer: footer, {section in initializer(section as! MultivaluedSection) })
        guard multivaluedOptions.contains(.Insert) else { return }
        initialize()
    }

    public required init() {
        self.multivaluedOptions = MultivaluedOptions.Insert.union(.Delete)
        super.init()
        initialize()
    }

    #if swift(>=4.1)
    public required init<S>(_ elements: S) where S : Sequence, S.Element == BaseRow {
        self.multivaluedOptions = MultivaluedOptions.Insert.union(.Delete)
        super.init(elements)
        initialize()
    }
    #endif

    func initialize() {
        let addRow = addButtonProvider(self)
        addRow.onCellSelection { cell, row in
            guard !row.isDisabled else { return }
            guard let tableView = cell.formViewController()?.tableView, let indexPath = row.indexPath else { return }
            cell.formViewController()?.tableView(tableView, commit: .insert, forRowAt: indexPath)
        }
        self <<< addRow
    }
    /**
     Method used to get all the values of the section.

     - returns: An Array mapping the row values. [value]
     */
    public func values() -> [Any?] {
        return kvoWrapper._allRows.filter({ $0.baseValue != nil }).map({ $0.baseValue })
    }
}
