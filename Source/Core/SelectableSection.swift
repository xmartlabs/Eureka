//  SelectableSection.swift
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
    case multipleSelection

    /**
     * Only one selection at a time. Can additionally specify if deselection is enabled or not.
     */
    case singleSelection(enableDeselection: Bool)
}

/**
 *  Protocol to be implemented by selectable sections types. Enables easier customization
 */
public protocol SelectableSectionType: Collection {
    associatedtype SelectableRow: BaseRow, SelectableRowType

    /// Defines how the selection works (single / multiple selection)
    var selectionType: SelectionType { get set }

    /// A closure called when a row of this section is selected.
    var onSelectSelectableRow: ((SelectableRow.Cell, SelectableRow) -> Void)? { get set }

    func selectedRow() -> SelectableRow?
    func selectedRows() -> [SelectableRow]
}

extension SelectableSectionType where Self: Section {
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
        let selectedRows: [BaseRow] = self.filter { $0 is SelectableRow && $0.baseValue != nil }
        return selectedRows.map { $0 as! SelectableRow }
    }

    /**
     Internal function used to set up a collection of rows before they are added to the section
     */
    func prepare(selectableRows rows: [BaseRow]) {
        for row in rows {
            if let row = row as? SelectableRow {
                row.onCellSelection { [weak self] cell, row in
                    guard let s = self, !row.isDisabled else { return }
                    switch s.selectionType {
                    case .multipleSelection:
                        row.value = row.value == nil ? row.selectableValue : nil
                    case let .singleSelection(enableDeselection):
                        s.forEach {
                            guard $0.baseValue != nil && $0 != row && $0 is SelectableRow else { return }
                            $0.baseValue = nil
                            $0.updateCell()
                        }
                        // Check if row is not already selected
                        if row.value == nil {
                            row.value = row.selectableValue
                        } else if enableDeselection {
                            row.value = nil
                        }
                    }
                    row.updateCell()
                    s.onSelectSelectableRow?(cell, row)
                }
            }
        }
    }

}

/// A subclass of Section that serves to create a section with a list of selectable options.
open class SelectableSection<Row>: Section, SelectableSectionType where Row: SelectableRowType, Row: BaseRow {

    public typealias SelectableRow = Row

    /// Defines how the selection works (single / multiple selection)
    public var selectionType = SelectionType.singleSelection(enableDeselection: true)

    /// A closure called when a row of this section is selected.
    public var onSelectSelectableRow: ((Row.Cell, Row) -> Void)?

    public override init(_ initializer: @escaping (SelectableSection<Row>) -> Void) {
        super.init({ _ in })
        initializer(self)
    }

    public init(_ header: String, selectionType: SelectionType, _ initializer: @escaping (SelectableSection<Row>) -> Void = { _ in }) {
        self.selectionType = selectionType
        super.init(header, { _ in })
        initializer(self)
    }

    public init(header: String, footer: String, selectionType: SelectionType, _ initializer: @escaping (SelectableSection<Row>) -> Void = { _ in }) {
        self.selectionType = selectionType
        super.init(header: header, footer: footer, { _ in })
        initializer(self)
    }

    public required init() {
        super.init()
    }

    #if swift(>=4.1)
    public required init<S>(_ elements: S) where S : Sequence, S.Element == BaseRow {
        super.init(elements)
    }
    #endif

    open override func rowsHaveBeenAdded(_ rows: [BaseRow], at: IndexSet) {
        prepare(selectableRows: rows)
    }
}
