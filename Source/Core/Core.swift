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

// MARK: Row

internal class RowDefaults {
    static var cellUpdate = Dictionary<String, (BaseCell, BaseRow) -> Void>()
    static var cellSetup = Dictionary<String, (BaseCell, BaseRow) -> Void>()
    static var onCellHighlight = Dictionary<String, (BaseCell, BaseRow) -> Void>()
    static var onCellUnHighlight = Dictionary<String, (BaseCell, BaseRow) -> Void>()
    static var rowInitialization = Dictionary<String, BaseRow -> Void>()
    static var rawCellUpdate = Dictionary<String, Any>()
    static var rawCellSetup = Dictionary<String, Any>()
    static var rawOnCellHighlight = Dictionary<String, Any>()
    static var rawOnCellUnHighlight = Dictionary<String, Any>()
    static var rawRowInitialization = Dictionary<String, Any>()
}


// MARK: FormCells

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
    
    public init(){}
    
    public init(nextKeyboardType: UIReturnKeyType, defaultKeyboardType: UIReturnKeyType){
        self.nextKeyboardType = nextKeyboardType
        self.defaultKeyboardType = defaultKeyboardType
    }
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FormViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FormViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
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

extension FormViewController: FormDelegate {
    
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
        navigationAccessoryView.doneButton.action = #selector(FormViewController.navigationDone(_:))
        navigationAccessoryView.previousButton.target = self
        navigationAccessoryView.previousButton.action = #selector(FormViewController.navigationAction(_:))
        navigationAccessoryView.nextButton.target = self
        navigationAccessoryView.nextButton.action = #selector(FormViewController.navigationAction(_:))
        navigationAccessoryView.nextButton.enabled = nextRowForRow(row, withDirection: .Down) != nil
        return navigationAccessoryView
    }
}
