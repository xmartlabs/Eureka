//  Core.swift
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

// MARK: Row

internal class RowDefaults {
    static var cellUpdate = [String: (BaseCell, BaseRow) -> Void]()
    static var cellSetup = [String: (BaseCell, BaseRow) -> Void]()
    static var onCellHighlightChanged = [String: (BaseCell, BaseRow) -> Void]()
    static var rowInitialization = [String: (BaseRow) -> Void]()
    static var onRowValidationChanged = [String: (BaseCell, BaseRow) -> Void]()
    static var rawCellUpdate = [String: Any]()
    static var rawCellSetup = [String: Any]()
    static var rawOnCellHighlightChanged = [String: Any]()
    static var rawRowInitialization = [String: Any]()
    static var rawOnRowValidationChanged = [String: Any]()
}

// MARK: FormCells

public struct CellProvider<Cell: BaseCell> where Cell: CellType {

    /// Nibname of the cell that will be created.
    public private (set) var nibName: String?

    /// Bundle from which to get the nib file.
    public private (set) var bundle: Bundle!

    public init() {}

    public init(nibName: String, bundle: Bundle? = nil) {
        self.nibName = nibName
        self.bundle = bundle ?? Bundle(for: Cell.self)
    }

    /**
     Creates the cell with the specified style.

     - parameter cellStyle: The style with which the cell will be created.

     - returns: the cell
     */
    func makeCell(style: UITableViewCell.CellStyle) -> Cell {
        if let nibName = self.nibName {
            return bundle.loadNibNamed(nibName, owner: nil, options: nil)!.first as! Cell
        }
        return Cell.init(style: style, reuseIdentifier: nil)
    }
}

/**
 Enumeration that defines how a controller should be created.

 - Callback->VCType: Creates the controller inside the specified block
 - NibFile:          Loads a controller from a nib file in some bundle
 - StoryBoard:       Loads the controller from a Storyboard by its storyboard id
 */
public enum ControllerProvider<VCType: UIViewController> {

    /**
     *  Creates the controller inside the specified block
     */
    case callback(builder: (() -> VCType))

    /**
     *  Loads a controller from a nib file in some bundle
     */
    case nibFile(name: String, bundle: Bundle?)

    /**
     *  Loads the controller from a Storyboard by its storyboard id
     */
    case storyBoard(storyboardId: String, storyboardName: String, bundle: Bundle?)

    func makeController() -> VCType {
        switch self {
            case .callback(let builder):
                return builder()
            case .nibFile(let nibName, let bundle):
                return VCType.init(nibName: nibName, bundle:bundle ?? Bundle(for: VCType.self))
            case .storyBoard(let storyboardId, let storyboardName, let bundle):
                let sb = UIStoryboard(name: storyboardName, bundle: bundle ?? Bundle(for: VCType.self))
                return sb.instantiateViewController(withIdentifier: storyboardId) as! VCType
        }
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
    case show(controllerProvider: ControllerProvider<VCType>, onDismiss: ((UIViewController) -> Void)?)

    /**
     *  Presents the controller, created by the specified provider, modally.
     */
    case presentModally(controllerProvider: ControllerProvider<VCType>, onDismiss: ((UIViewController) -> Void)?)

    /**
     *  Performs the segue with the specified identifier (name).
     */
    case segueName(segueName: String, onDismiss: ((UIViewController) -> Void)?)

    /**
     *  Performs a segue from a segue class.
     */
    case segueClass(segueClass: UIStoryboardSegue.Type, onDismiss: ((UIViewController) -> Void)?)

    case popover(controllerProvider: ControllerProvider<VCType>, onDismiss: ((UIViewController) -> Void)?)

    public var onDismissCallback: ((UIViewController) -> Void)? {
        switch self {
            case .show(_, let completion):
                return completion
            case .presentModally(_, let completion):
                return completion
            case .segueName(_, let completion):
                return completion
            case .segueClass(_, let completion):
                return completion
            case .popover(_, let completion):
                return completion
        }
    }

    /**
     Present the view controller provided by PresentationMode. Should only be used from custom row implementation.

     - parameter viewController:           viewController to present if it makes sense (normally provided by makeController method)
     - parameter row:                      associated row
     - parameter presentingViewController: form view controller
     */
    public func present(_ viewController: VCType!, row: BaseRow, presentingController: FormViewController) {
        switch self {
            case .show(_, _):
                presentingController.show(viewController, sender: row)
            case .presentModally(_, _):
                presentingController.present(viewController, animated: true)
            case .segueName(let segueName, _):
                presentingController.performSegue(withIdentifier: segueName, sender: row)
            case .segueClass(let segueClass, _):
                let segue = segueClass.init(identifier: row.tag, source: presentingController, destination: viewController)
                presentingController.prepare(for: segue, sender: row)
                segue.perform()
            case .popover(_, _):
                guard let porpoverController = viewController.popoverPresentationController else {
                    fatalError()
                }
                porpoverController.sourceView = porpoverController.sourceView ?? presentingController.tableView
                presentingController.present(viewController, animated: true)
            }

    }

    /**
     Creates the view controller specified by presentation mode. Should only be used from custom row implementation.

     - returns: the created view controller or nil depending on the PresentationMode type.
     */
    public func makeController() -> VCType? {
        switch self {
            case .show(let controllerProvider, let completionCallback):
                let controller = controllerProvider.makeController()
                let completionController = controller as? RowControllerType
                if let callback = completionCallback {
                    completionController?.onDismissCallback = callback
                }
                return controller
            case .presentModally(let controllerProvider, let completionCallback):
                let controller = controllerProvider.makeController()
                let completionController = controller as? RowControllerType
                if let callback = completionCallback {
                    completionController?.onDismissCallback = callback
                }
                return controller
            case .popover(let controllerProvider, let completionCallback):
                let controller = controllerProvider.makeController()
                controller.modalPresentationStyle = .popover
                let completionController = controller as? RowControllerType
                if let callback = completionCallback {
                    completionController?.onDismissCallback = callback
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
    func getNewPosition(forPosition: UITextPosition, inTextInput textInput: UITextInput, oldValue: String?, newValue: String?) -> UITextPosition
}

// MARK: Predicate Machine

enum ConditionType {
    case hidden, disabled
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
    case function([String], (Form)->Bool)

    /**
     *  Calculate the condition using a NSPredicate
     *
     *  @param NSPredicate The predicate that will be evaluated
     *
     *  @return If the condition is true or false
     */
    case predicate(NSPredicate)
}

extension Condition : ExpressibleByBooleanLiteral {

    /**
     Initialize a condition to return afixed boolean value always
     */
    public init(booleanLiteral value: Bool) {
        self = Condition.function([]) { _ in return value }
    }
}

extension Condition : ExpressibleByStringLiteral {

    /**
     Initialize a Condition with a string that will be converted to a NSPredicate
     */
    public init(stringLiteral value: String) {
        self = .predicate(NSPredicate(format: value))
    }

    /**
     Initialize a Condition with a string that will be converted to a NSPredicate
     */
    public init(unicodeScalarLiteral value: String) {
        self = .predicate(NSPredicate(format: value))
    }

    /**
     Initialize a Condition with a string that will be converted to a NSPredicate
     */
    public init(extendedGraphemeClusterLiteral value: String) {
        self = .predicate(NSPredicate(format: value))
    }
}

// MARK: Errors

/**
Errors thrown by Eureka

 - duplicatedTag: When a section or row is inserted whose tag dows already exist
 - rowNotInSection: When a row was expected to be in a Section, but is not.
*/
public enum EurekaError: Error {
    case duplicatedTag(tag: String)
    case rowNotInSection(row: BaseRow)
}

//Mark: FormViewController

/**
*  A protocol implemented by FormViewController
*/
public protocol FormViewControllerProtocol {
    var tableView: UITableView! { get }

    func beginEditing<T>(of: Cell<T>)
    func endEditing<T>(of: Cell<T>)

    func insertAnimation(forRows rows: [BaseRow]) -> UITableView.RowAnimation
    func deleteAnimation(forRows rows: [BaseRow]) -> UITableView.RowAnimation
    func reloadAnimation(oldRows: [BaseRow], newRows: [BaseRow]) -> UITableView.RowAnimation
    func insertAnimation(forSections sections: [Section]) -> UITableView.RowAnimation
    func deleteAnimation(forSections sections: [Section]) -> UITableView.RowAnimation
    func reloadAnimation(oldSections: [Section], newSections: [Section]) -> UITableView.RowAnimation
}

/**
 *  Navigation options for a form view controller.
 */
public struct RowNavigationOptions: OptionSet {

    private enum NavigationOptions: Int {
        case disabled = 0, enabled = 1, stopDisabledRow = 2, skipCanNotBecomeFirstResponderRow = 4
    }
    public let rawValue: Int
    public  init(rawValue: Int) { self.rawValue = rawValue}
    private init(_ options: NavigationOptions ) { self.rawValue = options.rawValue }

    /// No navigation.
    public static let Disabled = RowNavigationOptions(.disabled)

    /// Full navigation.
    public static let Enabled = RowNavigationOptions(.enabled)

    /// Break navigation when next row is disabled.
    public static let StopDisabledRow = RowNavigationOptions(.stopDisabledRow)

    /// Break navigation when next row cannot become first responder.
    public static let SkipCanNotBecomeFirstResponderRow = RowNavigationOptions(.skipCanNotBecomeFirstResponderRow)
}

/**
 *  Defines the configuration for the keyboardType of FieldRows.
 */
public struct KeyboardReturnTypeConfiguration {
    /// Used when the next row is available.
    public var nextKeyboardType = UIReturnKeyType.next

    /// Used if next row is not available.
    public var defaultKeyboardType = UIReturnKeyType.default

    public init() {}

    public init(nextKeyboardType: UIReturnKeyType, defaultKeyboardType: UIReturnKeyType) {
        self.nextKeyboardType = nextKeyboardType
        self.defaultKeyboardType = defaultKeyboardType
    }
}

/**
 *  Options that define when an inline row should collapse.
 */
public struct InlineRowHideOptions: OptionSet {

    private enum _InlineRowHideOptions: Int {
        case never = 0, anotherInlineRowIsShown = 1, firstResponderChanges = 2
    }
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue}
    private init(_ options: _InlineRowHideOptions ) { self.rawValue = options.rawValue }

    /// Never collapse automatically. Only when user taps inline row.
    public static let Never = InlineRowHideOptions(.never)

    /// Collapse qhen another inline row expands. Just one inline row will be expanded at a time.
    public static let AnotherInlineRowIsShown = InlineRowHideOptions(.anotherInlineRowIsShown)

    /// Collapse when first responder changes.
    public static let FirstResponderChanges = InlineRowHideOptions(.firstResponderChanges)
}

/// View controller that shows a form.
open class FormViewController: UIViewController, FormViewControllerProtocol, FormDelegate {

    @IBOutlet public var tableView: UITableView!

    private lazy var _form: Form = { [weak self] in
        let form = Form()
        form.delegate = self
        return form
        }()

    public var form: Form {
        get { return _form }
        set {
            guard form !== newValue else { return }
            _form.delegate = nil
            tableView?.endEditing(false)
            _form = newValue
            _form.delegate = self
            if isViewLoaded {
                tableView?.reloadData()
            }
        }
    }

    /// Extra space to leave between between the row in focus and the keyboard
    open var rowKeyboardSpacing: CGFloat = 0

    /// Enables animated scrolling on row navigation
    open var animateScroll = false

    /// Accessory view that is responsible for the navigation between rows
    private var navigationAccessoryView: (UIView & NavigationAccessory)!

    /// Custom Accesory View to be used as a replacement
    open var customNavigationAccessoryView: (UIView & NavigationAccessory)? {
        return nil
    }

    /// Defines the behaviour of the navigation between rows
    public var navigationOptions: RowNavigationOptions?
    private var tableViewStyle: UITableView.Style = .grouped

    public init(style: UITableView.Style) {
        super.init(nibName: nil, bundle: nil)
        tableViewStyle = style
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        navigationAccessoryView = customNavigationAccessoryView ?? NavigationAccessoryView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44.0))
        navigationAccessoryView.autoresizingMask = .flexibleWidth

        if tableView == nil {
            tableView = UITableView(frame: view.bounds, style: tableViewStyle)
            tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            if #available(iOS 9.0, *) {
                tableView.cellLayoutMarginsFollowReadableWidth = false
            }
        }
        if tableView.superview == nil {
            view.addSubview(tableView)
        }
        if tableView.delegate == nil {
            tableView.delegate = self
        }
        if tableView.dataSource == nil {
            tableView.dataSource = self
        }
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = BaseRow.estimatedRowHeight
        tableView.allowsSelectionDuringEditing = true
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateTableView = true
        let selectedIndexPaths = tableView.indexPathsForSelectedRows ?? []
        if !selectedIndexPaths.isEmpty {
            tableView.reloadRows(at: selectedIndexPaths, with: .none)
        }
        selectedIndexPaths.forEach {
            tableView.selectRow(at: $0, animated: false, scrollPosition: .none)
        }

        let deselectionAnimation = { [weak self] (context: UIViewControllerTransitionCoordinatorContext) in
            selectedIndexPaths.forEach {
                self?.tableView.deselectRow(at: $0, animated: context.isAnimated)
            }
        }

        let reselection = { [weak self] (context: UIViewControllerTransitionCoordinatorContext) in
            if context.isCancelled {
                selectedIndexPaths.forEach {
                    self?.tableView.selectRow(at: $0, animated: false, scrollPosition: .none)
                }
            }
        }

        if let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: deselectionAnimation, completion: reselection)
        } else {
            selectedIndexPaths.forEach {
                tableView.deselectRow(at: $0, animated: false)
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(FormViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FormViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        if form.containsMultivaluedSection && (isBeingPresented || isMovingToParent) {
            tableView.setEditing(true, animated: false)
        }
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let baseRow = sender as? BaseRow
        baseRow?.prepare(for: segue)
    }

    /**
     Returns the navigation accessory view if it is enabled. Returns nil otherwise.
     */
    open func inputAccessoryView(for row: BaseRow) -> UIView? {
        let options = navigationOptions ?? Form.defaultNavigationOptions
        guard options.contains(.Enabled) else { return nil }
        guard row.baseCell.cellCanBecomeFirstResponder() else { return nil}
        navigationAccessoryView.previousEnabled = nextRow(for: row, withDirection: .up) != nil
        navigationAccessoryView.doneClosure = { [weak self] in
            self?.navigationDone()
        }
        navigationAccessoryView.previousClosure = { [weak self] in
            self?.navigationPrevious()
        }
        navigationAccessoryView.nextClosure = { [weak self] in
            self?.navigationNext()
        }
        navigationAccessoryView.nextEnabled = nextRow(for: row, withDirection: .down) != nil
        return navigationAccessoryView
    }

    // MARK: FormViewControllerProtocol

    /**
    Called when a cell becomes first responder
    */
    public final func beginEditing<T>(of cell: Cell<T>) {
        cell.row.isHighlighted = true
        cell.row.updateCell()
        RowDefaults.onCellHighlightChanged["\(type(of: cell.row!))"]?(cell, cell.row)
        cell.row.callbackOnCellHighlightChanged?()
        guard let _ = tableView, (form.inlineRowHideOptions ?? Form.defaultInlineRowHideOptions).contains(.FirstResponderChanges) else { return }
        let row = cell.baseRow
        let inlineRow = row?._inlineRow
        for row in form.allRows.filter({ $0 !== row && $0 !== inlineRow && $0._inlineRow != nil }) {
            if let inlineRow = row as? BaseInlineRowType {
                inlineRow.collapseInlineRow()
            }
        }
    }

    /**
     Called when a cell resigns first responder
     */
    public final func endEditing<T>(of cell: Cell<T>) {
        cell.row.isHighlighted = false
        cell.row.wasBlurred = true
        RowDefaults.onCellHighlightChanged["\(type(of: cell.row!))"]?(cell, cell.row)
        cell.row.callbackOnCellHighlightChanged?()
        if cell.row.validationOptions.contains(.validatesOnBlur) || (cell.row.wasChanged && cell.row.validationOptions.contains(.validatesOnChangeAfterBlurred)) {
            cell.row.validate()
        }
        cell.row.updateCell()
    }

    /**
     Returns the animation for the insertion of the given rows.
     */
    open func insertAnimation(forRows rows: [BaseRow]) -> UITableView.RowAnimation {
        return .fade
    }

    /**
     Returns the animation for the deletion of the given rows.
     */
    open func deleteAnimation(forRows rows: [BaseRow]) -> UITableView.RowAnimation {
        return .fade
    }

    /**
     Returns the animation for the reloading of the given rows.
     */
    open func reloadAnimation(oldRows: [BaseRow], newRows: [BaseRow]) -> UITableView.RowAnimation {
        return .automatic
    }

    /**
     Returns the animation for the insertion of the given sections.
     */
    open func insertAnimation(forSections sections: [Section]) -> UITableView.RowAnimation {
        return .automatic
    }

    /**
     Returns the animation for the deletion of the given sections.
     */
    open func deleteAnimation(forSections sections: [Section]) -> UITableView.RowAnimation {
        return .automatic
    }

    /**
     Returns the animation for the reloading of the given sections.
     */
    open func reloadAnimation(oldSections: [Section], newSections: [Section]) -> UITableView.RowAnimation {
        return .automatic
    }

    // MARK: TextField and TextView Delegate

    open func textInputShouldBeginEditing<T>(_ textInput: UITextInput, cell: Cell<T>) -> Bool {
        return true
    }

    open func textInputDidBeginEditing<T>(_ textInput: UITextInput, cell: Cell<T>) {
        if let row = cell.row as? KeyboardReturnHandler {
            let next = nextRow(for: cell.row, withDirection: .down)
            if let textField = textInput as? UITextField {
                textField.returnKeyType = next != nil ? (row.keyboardReturnType?.nextKeyboardType ??
                    (form.keyboardReturnType?.nextKeyboardType ?? Form.defaultKeyboardReturnType.nextKeyboardType )) :
                    (row.keyboardReturnType?.defaultKeyboardType ?? (form.keyboardReturnType?.defaultKeyboardType ??
                        Form.defaultKeyboardReturnType.defaultKeyboardType))
            } else if let textView = textInput as? UITextView {
                textView.returnKeyType = next != nil ? (row.keyboardReturnType?.nextKeyboardType ??
                    (form.keyboardReturnType?.nextKeyboardType ?? Form.defaultKeyboardReturnType.nextKeyboardType )) :
                    (row.keyboardReturnType?.defaultKeyboardType ?? (form.keyboardReturnType?.defaultKeyboardType ??
                        Form.defaultKeyboardReturnType.defaultKeyboardType))
            }
        }
    }

    open func textInputShouldEndEditing<T>(_ textInput: UITextInput, cell: Cell<T>) -> Bool {
        return true
    }

    open func textInputDidEndEditing<T>(_ textInput: UITextInput, cell: Cell<T>) {

    }

    open func textInput<T>(_ textInput: UITextInput, shouldChangeCharactersInRange range: NSRange, replacementString string: String, cell: Cell<T>) -> Bool {
        return true
    }

    open func textInputShouldClear<T>(_ textInput: UITextInput, cell: Cell<T>) -> Bool {
        return true
    }

    open func textInputShouldReturn<T>(_ textInput: UITextInput, cell: Cell<T>) -> Bool {
        if let nextRow = nextRow(for: cell.row, withDirection: .down) {
            if nextRow.baseCell.cellCanBecomeFirstResponder() {
                nextRow.baseCell.cellBecomeFirstResponder()
                return true
            }
        }
        tableView?.endEditing(true)
        return true
    }

    // MARK: FormDelegate

    open func valueHasBeenChanged(for: BaseRow, oldValue: Any?, newValue: Any?) {}

    // MARK: UITableViewDelegate

    @objc open func tableView(_ tableView: UITableView, willBeginReorderingRowAtIndexPath indexPath: IndexPath) {
        // end editing if inline cell is first responder
        let row = form[indexPath]
        if let inlineRow = row as? BaseInlineRowType, row._inlineRow != nil {
            inlineRow.collapseInlineRow()
        }
    }

    // MARK: FormDelegate

    open func sectionsHaveBeenAdded(_ sections: [Section], at indexes: IndexSet) {
        guard animateTableView else { return }
        tableView?.beginUpdates()
        tableView?.insertSections(indexes, with: insertAnimation(forSections: sections))
        tableView?.endUpdates()
    }

    open func sectionsHaveBeenRemoved(_ sections: [Section], at indexes: IndexSet) {
        guard animateTableView else { return }
        tableView?.beginUpdates()
        tableView?.deleteSections(indexes, with: deleteAnimation(forSections: sections))
        tableView?.endUpdates()
    }

    open func sectionsHaveBeenReplaced(oldSections: [Section], newSections: [Section], at indexes: IndexSet) {
        guard animateTableView else { return }
        tableView?.beginUpdates()
        tableView?.reloadSections(indexes, with: reloadAnimation(oldSections: oldSections, newSections: newSections))
        tableView?.endUpdates()
    }

    open func rowsHaveBeenAdded(_ rows: [BaseRow], at indexes: [IndexPath]) {
        guard animateTableView else { return }
        tableView?.beginUpdates()
        tableView?.insertRows(at: indexes, with: insertAnimation(forRows: rows))
        tableView?.endUpdates()
    }

    open func rowsHaveBeenRemoved(_ rows: [BaseRow], at indexes: [IndexPath]) {
        guard animateTableView else { return }
        tableView?.beginUpdates()
        tableView?.deleteRows(at: indexes, with: deleteAnimation(forRows: rows))
        tableView?.endUpdates()
    }

    open func rowsHaveBeenReplaced(oldRows: [BaseRow], newRows: [BaseRow], at indexes: [IndexPath]) {
        guard animateTableView else { return }
        tableView?.beginUpdates()
        tableView?.reloadRows(at: indexes, with: reloadAnimation(oldRows: oldRows, newRows: newRows))
        tableView?.endUpdates()
    }

    // MARK: Private

    var oldBottomInset: CGFloat?
    var animateTableView = false

    /** Calculates the height needed for a header or footer. */
    fileprivate func height(specifiedHeight: (() -> CGFloat)?, sectionView: UIView?, sectionTitle: String?) -> CGFloat {
        if let height = specifiedHeight {
            return height()
        }

        if let sectionView = sectionView {
            let height = sectionView.bounds.height

            if height == 0 {
                return UITableView.automaticDimension
            }

            return height
        }

        if let sectionTitle = sectionTitle,
            sectionTitle != "" {
            return UITableView.automaticDimension
        }

        // Fix for iOS 11+. By returning 0, we ensure that no section header or
        // footer is shown when self-sizing is enabled (i.e. when
        // tableView.estimatedSectionHeaderHeight or tableView.estimatedSectionFooterHeight
        // == UITableView.automaticDimension).
        if tableView.style == .plain {
            return 0
        }

        return UITableView.automaticDimension
    }
}

extension FormViewController : UITableViewDelegate {

    // MARK: UITableViewDelegate

    open func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView == self.tableView else { return }
        let row = form[indexPath]
        // row.baseCell.cellBecomeFirstResponder() may be cause InlineRow collapsed then section count will be changed. Use orignal indexPath will out of  section's bounds.
        if !row.baseCell.cellCanBecomeFirstResponder() || !row.baseCell.cellBecomeFirstResponder() {
            self.tableView?.endEditing(true)
        }
        row.didSelect()
    }

    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard tableView == self.tableView else { return tableView.rowHeight }
        let row = form[indexPath.section][indexPath.row]
        return row.baseCell.height?() ?? tableView.rowHeight
    }

    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard tableView == self.tableView else { return tableView.estimatedRowHeight }
        let row = form[indexPath.section][indexPath.row]
        return row.baseCell.height?() ?? tableView.estimatedRowHeight
    }

    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return form[section].header?.viewForSection(form[section], type: .header)
    }

    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return form[section].footer?.viewForSection(form[section], type:.footer)
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return height(specifiedHeight: form[section].header?.height,
                      sectionView: self.tableView(tableView, viewForHeaderInSection: section),
                      sectionTitle: self.tableView(tableView, titleForHeaderInSection: section))
    }

    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return height(specifiedHeight: form[section].footer?.height,
                      sectionView: self.tableView(tableView, viewForFooterInSection: section),
                      sectionTitle: self.tableView(tableView, titleForFooterInSection: section))
    }

    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		let row = form[indexPath]
        guard !row.isDisabled else { return false }
		if row.trailingSwipe.actions.count > 0 { return true }
		if #available(iOS 11,*), row.leadingSwipe.actions.count > 0 { return true }
		guard let section = form[indexPath.section] as? MultivaluedSection else { return false }
        guard !(indexPath.row == section.count - 1 && section.multivaluedOptions.contains(.Insert) && section.showInsertIconInAddButton) else {
            return true
        }
        if indexPath.row > 0 && section[indexPath.row - 1] is BaseInlineRowType && section[indexPath.row - 1]._inlineRow != nil {
            return false
        }
        return true
    }

    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let row = form[indexPath]
            let section = row.section!
            if let _ = row.baseCell.findFirstResponder() {
                tableView.endEditing(true)
            }
            section.remove(at: indexPath.row)
        } else if editingStyle == .insert {
            guard var section = form[indexPath.section] as? MultivaluedSection else { return }
            guard let multivaluedRowToInsertAt = section.multivaluedRowToInsertAt else {
                fatalError("Multivalued section multivaluedRowToInsertAt property must be set up")
            }
            let newRow = multivaluedRowToInsertAt(max(0, section.count - 1))
            section.insert(newRow, at: max(0, section.count - 1))
            DispatchQueue.main.async {
                tableView.isEditing = !tableView.isEditing
                tableView.isEditing = !tableView.isEditing
            }
            tableView.scrollToRow(at: IndexPath(row: section.count - 1, section: indexPath.section), at: .bottom, animated: true)
            if newRow.baseCell.cellCanBecomeFirstResponder() {
                newRow.baseCell.cellBecomeFirstResponder()
            } else if let inlineRow = newRow as? BaseInlineRowType {
                inlineRow.expandInlineRow()
            }
        }
    }

    open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        guard let section = form[indexPath.section] as? MultivaluedSection, section.multivaluedOptions.contains(.Reorder) && section.count > 1 else {
            return false
        }
        if section.multivaluedOptions.contains(.Insert) && (section.count <= 2 || indexPath.row == (section.count - 1)) {
            return false
        }
        if indexPath.row > 0 && section[indexPath.row - 1] is BaseInlineRowType && section[indexPath.row - 1]._inlineRow != nil {
            return false
        }
        return true
    }

    open func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        guard let section = form[sourceIndexPath.section] as? MultivaluedSection else { return sourceIndexPath }
        guard sourceIndexPath.section == proposedDestinationIndexPath.section else { return sourceIndexPath }

        let destRow = form[proposedDestinationIndexPath]
        if destRow is BaseInlineRowType && destRow._inlineRow != nil {
            return IndexPath(row: proposedDestinationIndexPath.row + (sourceIndexPath.row < proposedDestinationIndexPath.row ? 1 : -1), section:sourceIndexPath.section)
        }

        if proposedDestinationIndexPath.row > 0 {
            let previousRow = form[IndexPath(row: proposedDestinationIndexPath.row - 1, section: proposedDestinationIndexPath.section)]
            if previousRow is BaseInlineRowType && previousRow._inlineRow != nil {
                return IndexPath(row: proposedDestinationIndexPath.row + (sourceIndexPath.row < proposedDestinationIndexPath.row ? 1 : -1), section:sourceIndexPath.section)
            }
        }
        if section.multivaluedOptions.contains(.Insert) && proposedDestinationIndexPath.row == section.count - 1 {
            return IndexPath(row: section.count - 2, section: sourceIndexPath.section)
        }
        return proposedDestinationIndexPath
    }

    open func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        guard var section = form[sourceIndexPath.section] as? MultivaluedSection else { return }
        if sourceIndexPath.row < section.count && destinationIndexPath.row < section.count && sourceIndexPath.row != destinationIndexPath.row {

            let sourceRow = form[sourceIndexPath]
            animateTableView = false
            section.remove(at: sourceIndexPath.row)
            section.insert(sourceRow, at: destinationIndexPath.row)
            animateTableView = true
            // update the accessory view
            let _ = inputAccessoryView(for: sourceRow)
        }
    }

    open func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        guard let section = form[indexPath.section] as? MultivaluedSection else {
			if form[indexPath].trailingSwipe.actions.count > 0 {
				return .delete
			}
            return .none
        }
        if section.multivaluedOptions.contains(.Insert) && indexPath.row == section.count - 1 {
            return section.showInsertIconInAddButton ? .insert : .none
        }
        if section.multivaluedOptions.contains(.Delete) {
            return .delete
        }
        return .none
    }

    open func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return self.tableView(tableView, editingStyleForRowAt: indexPath) != .none
    }

	@available(iOS 11,*)
	open func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !form[indexPath].leadingSwipe.actions.isEmpty else {
            return nil
        }
		return form[indexPath].leadingSwipe.contextualConfiguration
	}

	@available(iOS 11,*)
	open func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !form[indexPath].trailingSwipe.actions.isEmpty else {
            return nil
        }
		return form[indexPath].trailingSwipe.contextualConfiguration
	}

	open func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?{
        guard let actions = form[indexPath].trailingSwipe.contextualActions as? [UITableViewRowAction], !actions.isEmpty else {
            return nil
        }
        return actions
	}
}

extension FormViewController : UITableViewDataSource {

    // MARK: UITableViewDataSource

    open func numberOfSections(in tableView: UITableView) -> Int {
        return form.count
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return form[section].count
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    	form[indexPath].updateCell()
        return form[indexPath].baseCell
    }

    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return form[section].header?.title
    }

    open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return form[section].footer?.title
    }


    open func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return nil
    }

    open func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return 0
    }
}


extension FormViewController : UIScrollViewDelegate {

    // MARK: UIScrollViewDelegate

    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let tableView = tableView, scrollView === tableView else { return }
        tableView.endEditing(true)
    }
}

extension FormViewController {

    // MARK: KeyBoard Notifications

    /**
     Called when the keyboard will appear. Adjusts insets of the tableView and scrolls it if necessary.
     */
    @objc open func keyboardWillShow(_ notification: Notification) {
        guard let table = tableView, let cell = table.findFirstResponder()?.formCell() else { return }
        let keyBoardInfo = notification.userInfo!
        let endFrame = keyBoardInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue

        let keyBoardFrame = table.window!.convert(endFrame.cgRectValue, to: table.superview)
        let newBottomInset = table.frame.origin.y + table.frame.size.height - keyBoardFrame.origin.y + rowKeyboardSpacing
        var tableInsets = table.contentInset
        var scrollIndicatorInsets = table.scrollIndicatorInsets
        oldBottomInset = oldBottomInset ?? tableInsets.bottom
        if newBottomInset > oldBottomInset! {
            tableInsets.bottom = newBottomInset
            scrollIndicatorInsets.bottom = tableInsets.bottom
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration((keyBoardInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double))
            UIView.setAnimationCurve(UIView.AnimationCurve(rawValue: (keyBoardInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! Int))!)
            table.contentInset = tableInsets
            table.scrollIndicatorInsets = scrollIndicatorInsets
            if let selectedRow = table.indexPath(for: cell) {
                if ProcessInfo.processInfo.operatingSystemVersion.majorVersion == 11 {
                    let rect = table.rectForRow(at: selectedRow)
                    table.scrollRectToVisible(rect, animated: animateScroll)
                } else {
                    table.scrollToRow(at: selectedRow, at: .none, animated: animateScroll)
                }
            }
            UIView.commitAnimations()
        }
    }

    /**
     Called when the keyboard will disappear. Adjusts insets of the tableView.
     */
    @objc open func keyboardWillHide(_ notification: Notification) {
        guard let table = tableView, let oldBottom = oldBottomInset else { return }
        let keyBoardInfo = notification.userInfo!
        var tableInsets = table.contentInset
        var scrollIndicatorInsets = table.scrollIndicatorInsets
        tableInsets.bottom = oldBottom
        scrollIndicatorInsets.bottom = tableInsets.bottom
        oldBottomInset = nil
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration((keyBoardInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double))
        UIView.setAnimationCurve(UIView.AnimationCurve(rawValue: (keyBoardInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! Int))!)
        table.contentInset = tableInsets
        table.scrollIndicatorInsets = scrollIndicatorInsets
        UIView.commitAnimations()
    }
}

public enum Direction { case up, down }

extension FormViewController {

    // MARK: Navigation Methods

    @objc func navigationDone() {
        tableView?.endEditing(true)
    }

    @objc func navigationPrevious() {
        navigateTo(direction: .up)
    }

    @objc func navigationNext() {
        navigateTo(direction: .down)
    }

    public func navigateTo(direction: Direction) {
        guard let currentCell = tableView?.findFirstResponder()?.formCell() else { return }
        guard let currentIndexPath = tableView?.indexPath(for: currentCell) else { assertionFailure(); return }
        guard let nextRow = nextRow(for: form[currentIndexPath], withDirection: direction) else { return }
        if nextRow.baseCell.cellCanBecomeFirstResponder() {
            tableView?.scrollToRow(at: nextRow.indexPath!, at: .none, animated: animateScroll)
            nextRow.baseCell.cellBecomeFirstResponder(withDirection: direction)
        }
    }

    func nextRow(for currentRow: BaseRow, withDirection direction: Direction) -> BaseRow? {

        let options = navigationOptions ?? Form.defaultNavigationOptions
        guard options.contains(.Enabled) else { return nil }
        guard let next = direction == .down ? form.nextRow(for: currentRow) : form.previousRow(for: currentRow) else { return nil }
        if next.isDisabled && options.contains(.StopDisabledRow) {
            return nil
        }
        if !next.baseCell.cellCanBecomeFirstResponder() && !next.isDisabled && !options.contains(.SkipCanNotBecomeFirstResponderRow) {
            return nil
        }
        if !next.isDisabled && next.baseCell.cellCanBecomeFirstResponder() {
            return next
        }
        return nextRow(for: next, withDirection:direction)
    }
}

extension FormViewControllerProtocol {

    // MARK: Helpers

    func makeRowVisible(_ row: BaseRow, destinationScrollPosition: UITableView.ScrollPosition = .bottom) {
        guard let cell = row.baseCell, let indexPath = row.indexPath, let tableView = tableView else { return }
        if cell.window == nil || (tableView.contentOffset.y + tableView.frame.size.height <= cell.frame.origin.y + cell.frame.size.height) {
            tableView.scrollToRow(at: indexPath, at: destinationScrollPosition, animated: true)
        }
    }
}
