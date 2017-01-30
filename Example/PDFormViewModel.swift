//
// Created by pual on 07.12.16.
// Copyright (c) 2016 Jommi. All rights reserved.
//

import Foundation
import Eureka
// import CocoaLumberjackSwift

open class PDTableViewController: UIViewController {

    public var tableViewContentInsets: UIEdgeInsets = UIEdgeInsets.zero

    public var tableView: UITableView?

    open override func loadView() {
        super.loadView()
        let _tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
        _tableView.separatorStyle       = .none
        view.addSubview(_tableView)
        _tableView.frame = view.bounds
//        _tableView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
        _tableView.setContentOffset(CGPoint(x: 0,y: -tableViewContentInsets.top), animated: false)

        tableView = _tableView
    }

    var didSetupInsetsOnce: Bool = false

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView?.contentInset          = tableViewContentInsets
        tableView?.scrollIndicatorInsets = tableViewContentInsets

        if (!didSetupInsetsOnce) {
            tableView?.setContentOffset(CGPoint(x: 0,y: -tableViewContentInsets.top), animated: false)
            didSetupInsetsOnce = true
        }

    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let selectedIndexPath = tableView?.indexPathForSelectedRow {
            tableView?.deselectRow(at: selectedIndexPath, animated: true)
        }
        
    }
    
}

extension UIViewController {

    func configureFormViewController(insets: UIEdgeInsets = UIEdgeInsets.zero) -> PDFormViewController {

        let childViewController = PDFormViewController()
        childViewController.tableViewContentInsets = insets

        addChildViewController(childViewController)
        childViewController.didMove(toParentViewController: self)
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        childViewController.view.frame = view.bounds
        view.addSubview(childViewController.view)
//        childViewController.view.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
        return childViewController

    }

}

open class PDFormViewController: PDTableViewController {
    var viewModel: PDFormViewModel? {
        didSet {
            viewModel?.linkedViewController = self
            tableView?.dataSource   = viewModel
            tableView?.delegate     = viewModel
        }
    }
}

open class PDFormViewModel : NSObject {

    weak var linkedViewController: PDFormViewController?

    private lazy var _tableContent : Form = { [weak self] in
        let form = Form()
        form.delegate = self
        return form
        }()

    public var tableContent : Form {
        get { return _tableContent }
        set {
            guard tableContent !== newValue else { return }
            _tableContent.delegate = nil
            tableView?.endEditing(false)
            _tableContent = newValue
            _tableContent.delegate = self
        }
    }

}

extension PDFormViewModel : UITableViewDataSource {

    //MARK: UITableViewDataSource

    open func numberOfSections(in tableView: UITableView) -> Int {
        return tableContent.count
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableContent[section].count
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableContent[indexPath.section][indexPath.row].updateCell()
        return tableContent[indexPath.section][indexPath.row].baseCell
    }

    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableContent[section].header?.title
    }

    open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return tableContent[section].footer?.title
    }

}

extension PDFormViewModel : UITableViewDelegate {

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        guard tableView == self.tableView else { DDLogError(""); return }
        let row = tableContent[indexPath.section][indexPath.row]
        // row.baseCell.cellBecomeFirstResponder() may be cause InlineRow collapsed then section count will be changed. Use orignal indexPath will out of  section's bounds.
        if !row.baseCell.cellCanBecomeFirstResponder() || !row.baseCell.cellBecomeFirstResponder() {
            self.tableView?.endEditing(true)
        }
        row.didSelect()
    }

    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //        guard tableView == self.tableView else { DDLogError(""); return tableView.rowHeight }
        let row = tableContent[indexPath.section][indexPath.row]
        return row.baseCell.height?() ?? tableView.rowHeight
    }

    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        //        guard tableView == self.tableView else { DDLogError(""); return tableView.rowHeight }
        let row = tableContent[indexPath.section][indexPath.row]
        return row.baseCell.height?() ?? tableView.estimatedRowHeight
    }

    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableContent[section].header?.viewForSection(tableContent[section], type: .header)
    }

    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return tableContent[section].footer?.viewForSection(tableContent[section], type:.footer)
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let height = tableContent[section].header?.height {
            return height()
        }
        guard let view = tableContent[section].header?.viewForSection(tableContent[section], type: .header) else{
            return UITableViewAutomaticDimension
        }
        guard view.bounds.height != 0 else {
            return UITableViewAutomaticDimension
        }
        return view.bounds.height
    }

    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let height = tableContent[section].footer?.height {
            return height()
        }
        guard let view = tableContent[section].footer?.viewForSection(tableContent[section], type: .footer) else{
            return UITableViewAutomaticDimension
        }
        guard view.bounds.height != 0 else {
            return UITableViewAutomaticDimension
        }
        return view.bounds.height
    }

}


extension PDFormViewModel: FormDelegate {

    //MARK: FormDelegate

    open func sectionsHaveBeenAdded(_ sections: [Section], at indexes: IndexSet){
        tableView?.beginUpdates()
        tableView?.insertSections(indexes, with: insertAnimation(forSections: sections))
        tableView?.endUpdates()
    }

    open func sectionsHaveBeenRemoved(_ sections: [Section], at indexes: IndexSet){
        tableView?.beginUpdates()
        tableView?.deleteSections(indexes, with: deleteAnimation(forSections: sections))
        tableView?.endUpdates()
    }

    open func sectionsHaveBeenReplaced(oldSections:[Section], newSections: [Section], at indexes: IndexSet){
        tableView?.beginUpdates()
        tableView?.reloadSections(indexes, with: reloadAnimation(oldSections: oldSections, newSections: newSections))
        tableView?.endUpdates()
    }


    open func rowsHaveBeenAdded(_ rows: [BaseRow], at indexes: [IndexPath]) {
        tableView?.beginUpdates()
        tableView?.insertRows(at: indexes, with: insertAnimation(forRows: rows))
        tableView?.endUpdates()
    }

    open func rowsHaveBeenRemoved(_ rows: [BaseRow], at indexes: [IndexPath]) {
        tableView?.beginUpdates()
        tableView?.deleteRows(at: indexes, with: deleteAnimation(forRows: rows))
        tableView?.endUpdates()
    }

    open func rowsHaveBeenReplaced(oldRows:[BaseRow], newRows: [BaseRow], at indexes: [IndexPath]){
        tableView?.beginUpdates()
        tableView?.reloadRows(at: indexes, with: reloadAnimation(oldRows: oldRows, newRows: newRows))
        tableView?.endUpdates()
    }

    open func valueHasBeenChanged(for: BaseRow, oldValue: Any?, newValue: Any?) {
        print("oldValue: \(oldValue), newValue: \(newValue)")
    }

}

extension PDFormViewModel : FormViewControllerProtocol {


    open func inputAccessoryView(for row: BaseRow) -> UIView? { return nil }
    open func textInputShouldBeginEditing<T>(_ textInput: UITextInput, cell: Cell<T>) -> Bool { return false }
    open func textInputDidBeginEditing<T>(_ textInput: UITextInput, cell: Cell<T>) { }
    open func textInputShouldEndEditing<T>(_ textInput: UITextInput, cell: Cell<T>) -> Bool { return false }
    open func textInputDidEndEditing<T>(_ textInput: UITextInput, cell: Cell<T>) { return }
    open func textInput<T>(_ textInput: UITextInput, shouldChangeCharactersInRange range: NSRange, replacementString string: String, cell: Cell<T>) -> Bool { return false }
    open func textInputShouldClear<T>(_ textInput: UITextInput, cell: Cell<T>) -> Bool { return false }
    open func textInputShouldReturn<T>(_ textInput: UITextInput, cell: Cell<T>) -> Bool { return false }

    //MARK: FormViewControllerProtocol

    public var tableView: UITableView? {
        let result = linkedViewController?.tableView
        if result == nil {
            print("is nil")
        }
        return result
    }

    /**
     Called when a cell becomes first responder
     */
    public final func beginEditing<T:Equatable>(of cell: Cell<T>) {
        cell.row.isHighlighted = true
        cell.row.updateCell()
        //        RowDefaults.onCellHighlightChanged["\(type(of: cell.row!))"]?(cell, cell.row)
        //        cell.row.callbackOnCellHighlightChanged?()
        //        guard let _ = tableView, (tableContent.inlineRowHideOptions ?? tableContent.defaultInlineRowHideOptions).contains(.FirstResponderChanges) else { return }
        //        let row = cell.baseRow
        //        let inlineRow = row?._inlineRow
        //        for row in tableContent.allRows.filter({ $0 !== row && $0 !== inlineRow && $0._inlineRow != nil }) {
        //            if let inlineRow = row as? BaseInlineRowType {
        //                inlineRow.collapseInlineRow()
        //            }
        //        }
    }

    /**
     Called when a cell resigns first responder
     */
    public final func endEditing<T:Equatable>(of cell: Cell<T>) {
        print("")
        cell.row.isHighlighted = false
        //        cell.row.wasBlurred = true
        //        RowDefaults.onCellHighlightChanged["\(type(of: self))"]?(cell, cell.row)
        //        cell.row.callbackOnCellHighlightChanged?()
        if cell.row.validationOptions.contains(.validatesOnBlur) ||  cell.row.validationOptions.contains(.validatesOnChangeAfterBlurred) {
            cell.row.validate()
        }
        cell.row.updateCell()
    }

    /**
     Returns the animation for the insertion of the given rows.
     */
    open func insertAnimation(forRows rows: [BaseRow]) -> UITableViewRowAnimation {
        return .fade
    }

    /**
     Returns the animation for the deletion of the given rows.
     */
    open func deleteAnimation(forRows rows: [BaseRow]) -> UITableViewRowAnimation {
        return .fade
    }

    /**
     Returns the animation for the reloading of the given rows.
     */
    open func reloadAnimation(oldRows: [BaseRow], newRows: [BaseRow]) -> UITableViewRowAnimation {
        return .automatic
    }

    /**
     Returns the animation for the insertion of the given sections.
     */
    open func insertAnimation(forSections sections: [Section]) -> UITableViewRowAnimation {
        return .automatic
    }

    /**
     Returns the animation for the deletion of the given sections.
     */
    open func deleteAnimation(forSections sections: [Section]) -> UITableViewRowAnimation {
        return .automatic
    }
    
    /**
     Returns the animation for the reloading of the given sections.
     */
    open func reloadAnimation(oldSections: [Section], newSections: [Section]) -> UITableViewRowAnimation {
        return .automatic
    }
    
}
