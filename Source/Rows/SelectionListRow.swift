//
//  TableRow.swift
//  Eureka
//
//  Created by Anton Kovtun on 10/26/17.
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

import UIKit

private class IntrinsicSizeTableView: UITableView {
    var rowCount = 0
    
    override var intrinsicContentSize: CGSize {
        let headerHeight = tableHeaderView?.bounds.height ?? 0
        return CGSize(width: -1, height: headerHeight + CGFloat(rowCount) * rowHeight)
    }
}

open class SelectionListCell<T> : Cell<T>, CellType, UITableViewDelegate, UITableViewDataSource where T: Equatable {
    
    private let tableView = IntrinsicSizeTableView()
    private lazy var tableHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[picker]-0-|", options: [], metrics: nil, views: ["picker": tableView])
    
    private var listRow: SelectionListRow<T>? {
        return row as? SelectionListRow<T>
    }
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraints(tableHorizontalConstraints)
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[picker]-0-|", options: [], metrics: nil, views: ["picker": tableView]))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func setup() {
        super.setup()
        accessoryType = .none
        editingAccessoryType = .none
        height = { UITableViewAutomaticDimension }
        tableView.rowHeight = 44
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellIdentifier")
        if let inset = listRow?.horizontalContentInset {
            tableHorizontalConstraints.forEach { $0.constant = inset }
        }
        tableView.tableHeaderView = headerView(with: listRow?.title)
    }
    
    private func headerView(with text: String?) -> UIView? {
        guard let text = text else { return nil }
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: -1, height: tableView.rowHeight))
        label.text = text
        label.textAlignment = .center
        label.textColor = .darkGray
        label.backgroundColor = UIColor(white: 0.9, alpha: 1)
        return label
    }
    
    override open func update() {
        super.update()
        textLabel?.text = nil
        detailTextLabel?.text = nil
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableView.rowCount = listRow?.options.count ?? 0
        return self.tableView.rowCount
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        listRow?.configure(cell: cell, row: indexPath.row)
        return cell
    }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let selectedValue = listRow?.value, listRow?.options.index(of: selectedValue) == indexPath.row {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedValue = listRow?.value, let index = listRow?.options.index(of: selectedValue) {
            tableView.cellForRow(at: IndexPath(row: index, section: 0))?.accessoryType = .none
        }
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        listRow?.select(at: indexPath.row)
    }
}

public final class SelectionListRow<T>: Row<SelectionListCell<T>>, RowType where T: Equatable {
    open var options = [T]()
    
    private var configurationCallback: ((UITableViewCell, T, Int) -> Void)?
    private var selectionCallback: ((T) -> Void)?
    
    /// Sets textLabel color
    open var textColor = UIColor.gray
    /// Sets horizontal insets
    open var horizontalContentInset: CGFloat = 0
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
    
    fileprivate func select(at index: Int) {
        value = options[index]
        selectionCallback?(options[index])
    }
    
    /// This block gets called on option selection
    @discardableResult
    open func onDidSelect(_ callback: @escaping (T) -> Void) -> SelectionListRow {
        selectionCallback = callback
        return self
    }
    
    /// The block used to configure cells
    @discardableResult
    open func configureCell(_ configurator: @escaping (UITableViewCell, T, Int) -> Void) -> SelectionListRow {
        configurationCallback = configurator
        return self
    }
    
    fileprivate func configure(cell: UITableViewCell, row: Int) {
        cell.textLabel?.text = displayValueFor?(options[row])
        cell.textLabel?.textColor = textColor
        configurationCallback?(cell, options[row], row)
    }
}
