//  Rows.swift
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

import UIKit
import Foundation

protocol FieldRowConformance : FormatterConformance {
    var textFieldPercentage : CGFloat? { get set }
    var placeholder : String? { get set }
    var placeholderColor : UIColor? { get set }
}

protocol TextAreaConformance : FormatterConformance {
    var placeholder : String? { get set }
}

public protocol PostalAddressRowConformance: PostalAddressFormatterConformance {
	var postalAddressPercentage : CGFloat? { get set }
	var placeholderColor : UIColor? { get set }
	var streetPlaceholder : String? { get set }
	var statePlaceholder : String? { get set }
	var postalCodePlaceholder : String? { get set }
	var cityPlaceholder : String? { get set }
	var countryPlaceholder : String? { get set }
}

public protocol FormatterConformance: class {
    var formatter: NSFormatter? { get set }
    var useFormatterDuringInput: Bool { get set }
}

public protocol PostalAddressFormatterConformance: class {
	var streetUseFormatterDuringInput: Bool { get set }
	var streetFormatter: NSFormatter? { get set }
	
	var stateUseFormatterDuringInput: Bool { get set }
	var stateFormatter: NSFormatter? { get set }
	
	var postalCodeUseFormatterDuringInput: Bool { get set }
	var postalCodeFormatter: NSFormatter? { get set }
	
	var cityUseFormatterDuringInput: Bool { get set }
	var cityFormatter: NSFormatter? { get set }
	
	var countryUseFormatterDuringInput: Bool { get set }
	var countryFormatter: NSFormatter? { get set }
}

public class FieldRow<T: Any, Cell: CellType where Cell: BaseCell, Cell: TextFieldCell, Cell.Value == T>: Row<T, Cell>, FieldRowConformance, KeyboardReturnHandler {
    
    /// Configuration for the keyboardReturnType of this row
    public var keyboardReturnType : KeyboardReturnTypeConfiguration?
    
    /// The percentage of the cell that should be occupied by the textField
    public var textFieldPercentage : CGFloat?
    
    /// The placeholder for the textField
    public var placeholder : String?
    
    /// The textColor for the textField's placeholder
    public var placeholderColor : UIColor?
    
    /// A formatter to be used to format the user's input
    public var formatter: NSFormatter?
    
    /// If the formatter should be used while the user is editing the text.
    public var useFormatterDuringInput: Bool
    
    public required init(tag: String?) {
        useFormatterDuringInput = false
        super.init(tag: tag)
        self.displayValueFor = { [unowned self] value in
            guard let v = value else {
                return nil
            }
            if let formatter = self.formatter {
                if self.cell.textField.isFirstResponder() {
                    if self.useFormatterDuringInput {
                        return formatter.editingStringForObjectValue(v as! AnyObject)
                    }
                    else {
                        return String(v)
                    }
                }
                return formatter.stringForObjectValue(v as! AnyObject)
            }
            else{
                return String(v)
            }
        }
    }
}

public class _PostalAddressRow<T: Equatable, Cell: CellType where Cell: BaseCell, Cell: PostalAddressCell, Cell.Value == T>: Row<T, Cell>, PostalAddressRowConformance, KeyboardReturnHandler {
	
	/// Configuration for the keyboardReturnType of this row
	public var keyboardReturnType : KeyboardReturnTypeConfiguration?
	
	/// The percentage of the cell that should be occupied by the postal address
	public var postalAddressPercentage: CGFloat?
	
	/// The textColor for the textField's placeholder
	public var placeholderColor : UIColor?
	
	/// The placeholder for the street textField
	public var streetPlaceholder : String?
	
	/// The placeholder for the state textField
	public var statePlaceholder : String?
	
	/// The placeholder for the zip textField
	public var postalCodePlaceholder : String?
	
	/// The placeholder for the city textField
	public var cityPlaceholder : String?
	
	/// The placeholder for the country textField
	public var countryPlaceholder : String?
	
	/// A formatter to be used to format the user's input for street
	public var streetFormatter: NSFormatter?
	
	/// A formatter to be used to format the user's input for state
	public var stateFormatter: NSFormatter?
	
	/// A formatter to be used to format the user's input for zip
	public var postalCodeFormatter: NSFormatter?
	
	/// A formatter to be used to format the user's input for city
	public var cityFormatter: NSFormatter?
	
	/// A formatter to be used to format the user's input for country
	public var countryFormatter: NSFormatter?
	
	/// If the formatter should be used while the user is editing the street.
	public var streetUseFormatterDuringInput: Bool
	
	/// If the formatter should be used while the user is editing the state.
	public var stateUseFormatterDuringInput: Bool
	
	/// If the formatter should be used while the user is editing the zip.
	public var postalCodeUseFormatterDuringInput: Bool
	
	/// If the formatter should be used while the user is editing the city.
	public var cityUseFormatterDuringInput: Bool
	
	/// If the formatter should be used while the user is editing the country.
	public var countryUseFormatterDuringInput: Bool
	
	public required init(tag: String?) {
		streetUseFormatterDuringInput = false
		stateUseFormatterDuringInput = false
		postalCodeUseFormatterDuringInput = false
		cityUseFormatterDuringInput = false
		countryUseFormatterDuringInput = false
		
		super.init(tag: tag)
	}
}

public protocol _DatePickerRowProtocol {
    var minimumDate : NSDate? { get set }
    var maximumDate : NSDate? { get set }
    var minuteInterval : Int? { get set }
}

public class _DateFieldRow: Row<NSDate, DateCell>, _DatePickerRowProtocol {
    
    /// The minimum value for this row's UIDatePicker
    public var minimumDate : NSDate?
    
    /// The maximum value for this row's UIDatePicker
    public var maximumDate : NSDate?
    
    /// The interval between options for this row's UIDatePicker
    public var minuteInterval : Int?
    
    /// The formatter for the date picked by the user
    public var dateFormatter: NSDateFormatter?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = { [unowned self] value in
            guard let val = value, let formatter = self.dateFormatter else { return nil }
            return formatter.stringFromDate(val)
        }
    }
}

public class _DateInlineFieldRow: Row<NSDate, DateInlineCell>, _DatePickerRowProtocol {
    
    /// The minimum value for this row's UIDatePicker
    public var minimumDate : NSDate?
    
    /// The maximum value for this row's UIDatePicker
    public var maximumDate : NSDate?
    
    /// The interval between options for this row's UIDatePicker
    public var minuteInterval : Int?
    
    /// The formatter for the date picked by the user
    public var dateFormatter: NSDateFormatter?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = { [unowned self] value in
            guard let val = value, let formatter = self.dateFormatter else { return nil }
            return formatter.stringFromDate(val)
        }
    }
}

public class _DateInlineRow: _DateInlineFieldRow {
    
    public typealias InlineRow = DatePickerRow
    
    public required init(tag: String?) {
        super.init(tag: tag)
        dateFormatter = NSDateFormatter()
        dateFormatter?.timeStyle = .NoStyle
        dateFormatter?.dateStyle = .MediumStyle
        dateFormatter?.locale = .currentLocale()
    }
    
    public func setupInlineRow(inlineRow: DatePickerRow) {
        inlineRow.minimumDate = minimumDate
        inlineRow.maximumDate = maximumDate
        inlineRow.minuteInterval = minuteInterval
    }
}

public class _DateTimeInlineRow: _DateInlineFieldRow {

    public typealias InlineRow = DateTimePickerRow
    
    public required init(tag: String?) {
        super.init(tag: tag)
        dateFormatter = NSDateFormatter()
        dateFormatter?.timeStyle = .ShortStyle
        dateFormatter?.dateStyle = .ShortStyle
        dateFormatter?.locale = .currentLocale()
    }
    
    public func setupInlineRow(inlineRow: DateTimePickerRow) {
        inlineRow.minimumDate = minimumDate
        inlineRow.maximumDate = maximumDate
        inlineRow.minuteInterval = minuteInterval
    }
}

public class _TimeInlineRow: _DateInlineFieldRow {
    
    public typealias InlineRow = TimePickerRow
    
    public required init(tag: String?) {
        super.init(tag: tag)
        dateFormatter = NSDateFormatter()
        dateFormatter?.timeStyle = .ShortStyle
        dateFormatter?.dateStyle = .NoStyle
        dateFormatter?.locale = .currentLocale()
    }
    
    public func setupInlineRow(inlineRow: TimePickerRow) {
        inlineRow.minimumDate = minimumDate
        inlineRow.maximumDate = maximumDate
        inlineRow.minuteInterval = minuteInterval
    }
}

public class _CountDownInlineRow: _DateInlineFieldRow {
    
    public typealias InlineRow = CountDownPickerRow
    
    public required init(tag: String?) {
        super.init(tag: tag)
        displayValueFor =  {
            guard let date = $0 else {
                return nil
            }
            let hour = NSCalendar.currentCalendar().component(.Hour, fromDate: date)
            let min = NSCalendar.currentCalendar().component(.Minute, fromDate: date)
            if hour == 1{
                return "\(hour) hour \(min) min"
            }
            return "\(hour) hours \(min) min"
        }
    }
    
    public func setupInlineRow(inlineRow: CountDownPickerRow) {
        inlineRow.minimumDate = minimumDate
        inlineRow.maximumDate = maximumDate
        inlineRow.minuteInterval = minuteInterval
    }
}

public class _TextRow: FieldRow<String, TextCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

public class _IntRow: FieldRow<Int, IntCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
        let numberFormatter = NSNumberFormatter()
        numberFormatter.locale = .currentLocale()
        numberFormatter.numberStyle = .DecimalStyle
        numberFormatter.minimumFractionDigits = 0
        formatter = numberFormatter
    }
}

public class _PhoneRow: FieldRow<String, PhoneCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

public class _NameRow: FieldRow<String, NameCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

public class _EmailRow: FieldRow<String, EmailCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

public class _PasswordRow: FieldRow<String, PasswordCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

public class DecimalFormatter : NSNumberFormatter, FormatterProtocol {
    
    public override init() {
        super.init()
        locale = .currentLocale()
        numberStyle = .DecimalStyle
        minimumFractionDigits = 2
        maximumFractionDigits = 2
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func getObjectValue(obj: AutoreleasingUnsafeMutablePointer<AnyObject?>, forString string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>) -> Bool {
        guard obj != nil else { return false }
        let str = string.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("")
        obj.memory = NSNumber(double: (Double(str) ?? 0.0)/Double(pow(10.0, Double(minimumFractionDigits))))
        return true
    }
    
    public func getNewPosition(forPosition position: UITextPosition, inTextInput textInput: UITextInput, oldValue: String?, newValue: String?) -> UITextPosition {
        return textInput.positionFromPosition(position, offset:((newValue?.characters.count ?? 0) - (oldValue?.characters.count ?? 0))) ?? position
    }
}

public class _DecimalRow: FieldRow<Double, DecimalCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
        let numberFormatter = NSNumberFormatter()
        numberFormatter.locale = .currentLocale()
        numberFormatter.numberStyle = .DecimalStyle
        numberFormatter.minimumFractionDigits = 2
        formatter = numberFormatter
    }
}

public class _URLRow: FieldRow<NSURL, URLCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

public class _TwitterRow: FieldRow<String, TwitterCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

public class _AccountRow: FieldRow<String, AccountCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

public class _ZipCodeRow: FieldRow<String, ZipCodeCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

public class _TimeRow: _DateFieldRow {
    required public init(tag: String?) {
        super.init(tag: tag)
        dateFormatter = NSDateFormatter()
        dateFormatter?.timeStyle = .ShortStyle
        dateFormatter?.dateStyle = .NoStyle
        dateFormatter?.locale = NSLocale.currentLocale()
    }
}

public class _DateRow: _DateFieldRow {
    required public init(tag: String?) {
        super.init(tag: tag)
        dateFormatter = NSDateFormatter()
        dateFormatter?.timeStyle = .NoStyle
        dateFormatter?.dateStyle = .MediumStyle
        dateFormatter?.locale = NSLocale.currentLocale()
    }
}

public class _DateTimeRow: _DateFieldRow {
    required public init(tag: String?) {
        super.init(tag: tag)
        dateFormatter = NSDateFormatter()
        dateFormatter?.timeStyle = .ShortStyle
        dateFormatter?.dateStyle = .ShortStyle
        dateFormatter?.locale = NSLocale.currentLocale()
    }
}

public class _CountDownRow: _DateFieldRow {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = { [unowned self] value in
            guard let val = value else {
                return nil
            }
            if let formatter = self.dateFormatter {
                return formatter.stringFromDate(val)
            }
            let components = NSCalendar.currentCalendar().components(NSCalendarUnit.Minute.union(NSCalendarUnit.Hour), fromDate: val)
            var hourString = "hour"
            if components.hour != 1{
                hourString += "s"
            }
            return  "\(components.hour) \(hourString) \(components.minute) min"
        }
    }
}

public class _DatePickerRow : Row<NSDate, DatePickerCell>, _DatePickerRowProtocol {
    
    public var minimumDate : NSDate?
    public var maximumDate : NSDate?
    public var minuteInterval : Int?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
}

public class _PickerRow<T where T: Equatable> : Row<T, PickerCell<T>>{
    
    public var options = [T]()
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

public class _PickerInlineRow<T where T: Equatable> : Row<T, LabelCellOf<T>>{
    
    public typealias InlineRow = PickerRow<T>
    public var options = [T]()

    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

public class _TextAreaRow: AreaRow<String, TextAreaCell> {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

public class _LabelRow: Row<String, LabelCell> {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

public class _CheckRow: Row<Bool, CheckCell> {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
}

public final class ListCheckRow<T: Equatable>: Row<T, ListCheckCell<T>>, SelectableRowType, RowType {
    public var selectableValue: T?
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
}

public class _SwitchRow: Row<Bool, SwitchCell> {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
}

public class _PushRow<T: Equatable, Cell: CellType where Cell: BaseCell, Cell.Value == T> : SelectorRow<T, SelectorViewController<T>, Cell> {
    
    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .Show(controllerProvider: ControllerProvider.Callback { return SelectorViewController<T>(){ _ in } }, completionCallback: { vc in vc.navigationController?.popViewControllerAnimated(true) })
    }
}

public class _PopoverSelectorRow<T: Equatable, Cell: CellType where Cell: BaseCell, Cell.Value == T> : SelectorRow<T, SelectorViewController<T>, Cell> {
    
    public required init(tag: String?) {
        super.init(tag: tag)
        onPresentCallback = { [weak self] (_, viewController) -> Void in
            guard let porpoverController = viewController.popoverPresentationController, tableView = self?.baseCell.formViewController()?.tableView, cell = self?.cell else {
                fatalError()
            }
            porpoverController.sourceView = tableView
            porpoverController.sourceRect = tableView.convertRect(cell.detailTextLabel?.frame ?? cell.textLabel?.frame ?? cell.contentView.frame, fromView: cell)
        }
        presentationMode = .Popover(controllerProvider: ControllerProvider.Callback { return SelectorViewController<T>(){ _ in } }, completionCallback: { [weak self] in
            $0.dismissViewControllerAnimated(true, completion: nil)
            self?.reload()
            })
    }
    
    public override func didSelect() {
        deselect()
        super.didSelect()
    }
}

public class AreaRow<T: Equatable, Cell: CellType where Cell: BaseCell, Cell: AreaCell, Cell.Value == T>: Row<T, Cell>, TextAreaConformance {
    
    public var placeholder : String?
    public var formatter: NSFormatter?
    public var useFormatterDuringInput: Bool
    
    public required init(tag: String?) {
        useFormatterDuringInput = false
        super.init(tag: tag)
        self.displayValueFor = { [unowned self] value in
            guard let v = value else {
                return nil
            }
            if let formatter = self.formatter {
                if self.cell.textView.isFirstResponder() {
                    if self.useFormatterDuringInput {
                        return formatter.editingStringForObjectValue(v as! AnyObject)
                    }
                    else {
                        return String(v)
                    }
                }
                return formatter.stringForObjectValue(v as! AnyObject)
            }
            else{
                return String(v)
            }
        }
    }
}

public class OptionsRow<T: Equatable, Cell: CellType where Cell: BaseCell, Cell.Value == T> : Row<T, Cell> {
    
    public var options: [T] {
        get { return dataProvider?.arrayData ?? [] }
        set { dataProvider = DataProvider(arrayData: newValue) }
    }
    
    public var selectorTitle: String?
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

public class _ActionSheetRow<T: Equatable, Cell: CellType where Cell: BaseCell, Cell.Value == T>: OptionsRow<T, Cell>, PresenterRowType {
    
    public var onPresentCallback : ((FormViewController, SelectorAlertController<T>)->())?
    lazy public var presentationMode: PresentationMode<SelectorAlertController<T>>? = {
        return .PresentModally(controllerProvider: ControllerProvider.Callback { [weak self] in
            let vc = SelectorAlertController<T>(title: self?.selectorTitle, message: nil, preferredStyle: .ActionSheet)
			if let popView = vc.popoverPresentationController {
                guard let cell = self?.cell, tableView = cell.formViewController()?.tableView else { fatalError() }
				popView.sourceView = tableView
                popView.sourceRect = tableView.convertRect(cell.detailTextLabel?.frame ?? cell.textLabel?.frame ?? cell.contentView.frame, fromView: cell)
			}
			vc.row = self
            return vc
            },
            completionCallback: { [weak self] in
                $0.dismissViewControllerAnimated(true, completion: nil)
                self?.cell?.formViewController()?.tableView?.reloadData()
            })
        }()
    
    public required init(tag: String?) {
        super.init(tag: tag)
    }
    
    public override func customDidSelect() {
        super.customDidSelect()
        if let presentationMode = presentationMode where !isDisabled {
            if let controller = presentationMode.createController(){
                controller.row = self
                onPresentCallback?(cell.formViewController()!, controller)
                presentationMode.presentViewController(controller, row: self, presentingViewController: cell.formViewController()!)
            }
            else{
                presentationMode.presentViewController(nil, row: self, presentingViewController: cell.formViewController()!)
            }
        }
    }
}

public class _AlertRow<T: Equatable, Cell: CellType where Cell: BaseCell, Cell.Value == T>: OptionsRow<T, Cell>, PresenterRowType {
    
    public var onPresentCallback : ((FormViewController, SelectorAlertController<T>)->())?
    lazy public var presentationMode: PresentationMode<SelectorAlertController<T>>? = {
        return .PresentModally(controllerProvider: ControllerProvider.Callback { [weak self] in
            let vc = SelectorAlertController<T>(title: self?.selectorTitle, message: nil, preferredStyle: .Alert)
            vc.row = self
            return vc
            }, completionCallback: { [weak self] in
                $0.dismissViewControllerAnimated(true, completion: nil)
                self?.cell?.formViewController()?.tableView?.reloadData()
            }
        )
        }()
        
    public required init(tag: String?) {
        super.init(tag: tag)
    }
    
    public override func customDidSelect() {
        super.customDidSelect()
        if let presentationMode = presentationMode where !isDisabled  {
            if let controller = presentationMode.createController(){
                controller.row = self
                onPresentCallback?(cell.formViewController()!, controller)
                presentationMode.presentViewController(controller, row: self, presentingViewController: cell.formViewController()!)
            }
            else{
                presentationMode.presentViewController(nil, row: self, presentingViewController: cell.formViewController()!)
            }
        }
    }
}

public struct ImageRowSourceTypes : OptionSetType {
    
    public let rawValue: Int
    public var imagePickerControllerSourceTypeRawValue: Int { return self.rawValue >> 1 }
    
    public init(rawValue: Int) { self.rawValue = rawValue }
    private init(_ sourceType: UIImagePickerControllerSourceType) { self.init(rawValue: 1 << sourceType.rawValue) }
    
    public static let PhotoLibrary  = ImageRowSourceTypes(.PhotoLibrary)
    public static let Camera  = ImageRowSourceTypes(.Camera)
    public static let SavedPhotosAlbum = ImageRowSourceTypes(.SavedPhotosAlbum)
    public static let All: ImageRowSourceTypes = [Camera, PhotoLibrary, SavedPhotosAlbum]
}

public enum ImageClearAction {
    case No
    case Yes(style: UIAlertActionStyle)
}

public class _ImageRow<Cell: CellType where Cell: BaseCell, Cell.Value == UIImage> : SelectorRow<UIImage, ImagePickerController, Cell> {
    
    public var sourceTypes: ImageRowSourceTypes
    public internal(set) var imageURL: NSURL?
	public var clearAction = ImageClearAction.Yes(style: .Destructive)
    
	private var _sourceType: UIImagePickerControllerSourceType = .Camera
    
    public required init(tag: String?) {
        sourceTypes = .All
        super.init(tag: tag)
        presentationMode = .PresentModally(controllerProvider: ControllerProvider.Callback { return ImagePickerController() }, completionCallback: { [weak self] vc in
                self?.select()
                vc.dismissViewControllerAnimated(true, completion: nil)
            })
        self.displayValueFor = nil

    }
    
    // copy over the existing logic from the SelectorRow
    private func displayImagePickerController(sourceType: UIImagePickerControllerSourceType) {
        if let presentationMode = presentationMode where !isDisabled {
            if let controller = presentationMode.createController(){
                controller.row = self
                controller.sourceType = sourceType
                onPresentCallback?(cell.formViewController()!, controller)
                presentationMode.presentViewController(controller, row: self, presentingViewController: cell.formViewController()!)
            }
            else{
                _sourceType = sourceType
                presentationMode.presentViewController(nil, row: self, presentingViewController: cell.formViewController()!)
            }
        }
    }
    
    public override func customDidSelect() {
        guard !isDisabled else {
            super.customDidSelect()
            return
        }
        deselect()
        
        var availableSources: ImageRowSourceTypes = []
        
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            availableSources.insert(.PhotoLibrary)
        }
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            availableSources.insert(.Camera)
        }
        if UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum) {
            availableSources.insert(.SavedPhotosAlbum)
        }
        
        sourceTypes.intersectInPlace(availableSources)
        
        
        if sourceTypes.isEmpty {
            super.customDidSelect()
            return
        }
        
        // now that we know the number of actions aren't empty
        let sourceActionSheet = UIAlertController(title: nil, message: selectorTitle, preferredStyle: .ActionSheet)
        guard let tableView = cell.formViewController()?.tableView  else { fatalError() }
		if let popView = sourceActionSheet.popoverPresentationController {
			popView.sourceView = tableView
			popView.sourceRect = tableView.convertRect(cell.accessoryView?.frame ?? cell.contentView.frame, fromView: cell)
		}
        
		if sourceTypes.contains(.Camera) {
            let cameraOption = UIAlertAction(title: NSLocalizedString("Take Photo", comment: ""), style: .Default, handler: { [weak self] _ in
                self?.displayImagePickerController(.Camera)
            })
            sourceActionSheet.addAction(cameraOption)
        }
        if sourceTypes.contains(.PhotoLibrary) {
            let photoLibraryOption = UIAlertAction(title: NSLocalizedString("Photo Library", comment: ""), style: .Default, handler: { [weak self] _ in
                self?.displayImagePickerController(.PhotoLibrary)
            })
            sourceActionSheet.addAction(photoLibraryOption)
        }
        if sourceTypes.contains(.SavedPhotosAlbum) {
            let savedPhotosOption = UIAlertAction(title: NSLocalizedString("Saved Photos", comment: ""), style: .Default, handler: { [weak self] _ in
                self?.displayImagePickerController(.SavedPhotosAlbum)
            })
            sourceActionSheet.addAction(savedPhotosOption)
        }
        
        switch clearAction {
        case .Yes(let style):
            if let _ = value {
                let clearPhotoOption = UIAlertAction(title: NSLocalizedString("Clear Photo", comment: ""), style: style, handler: { [weak self] _ in
                    self?.value = nil
                    self?.updateCell()
                    })
                sourceActionSheet.addAction(clearPhotoOption)
            }
        case .No:
            break
        }
        
        // check if we have only one source type given
        if sourceActionSheet.actions.count == 1 {
            if let imagePickerSourceType = UIImagePickerControllerSourceType(rawValue: sourceTypes.imagePickerControllerSourceTypeRawValue) {
                displayImagePickerController(imagePickerSourceType)
            }
        } else {
            let cancelOption = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler:nil)
            sourceActionSheet.addAction(cancelOption)
            
            if let presentingViewController = cell.formViewController() {
                presentingViewController.presentViewController(sourceActionSheet, animated: true, completion:nil)
            }
        }
    }
    
    public override func prepareForSegue(segue: UIStoryboardSegue) {
        super.prepareForSegue(segue)
        guard let rowVC = segue.destinationViewController as? ImagePickerController else {
            return
        }
        rowVC.sourceType = _sourceType
    }

    public override func customUpdateCell() {
        super.customUpdateCell()
        cell.accessoryType = .None
        if let image = self.value {
            let imageView = UIImageView(frame: CGRectMake(0, 0, 44, 44))
            imageView.contentMode = .ScaleAspectFill
            imageView.image = image
            imageView.clipsToBounds = true
            cell.accessoryView = imageView
        }
        else{
            cell.accessoryView = nil
        }
    }
}

public class _MultipleSelectorRow<T: Hashable, Cell: CellType where Cell: BaseCell, Cell.Value == Set<T>> : GenericMultipleSelectorRow<T, MultipleSelectorViewController<T>, Cell> {
    public required init(tag: String?) {
        super.init(tag: tag)
        self.displayValueFor = {
            if let t = $0 {
                return t.map({ String($0) }).joinWithSeparator(", ")
            }
            return nil
        }
    }
}

public class _ButtonRowOf<T: Equatable> : Row<T, ButtonCellOf<T>> {
    public var presentationMode: PresentationMode<UIViewController>?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellStyle = .Default
    }
    
    public override func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            if let presentationMode = presentationMode {
                if let controller = presentationMode.createController(){
                    presentationMode.presentViewController(controller, row: self, presentingViewController: self.cell.formViewController()!)
                }
                else{
                    presentationMode.presentViewController(nil, row: self, presentingViewController: self.cell.formViewController()!)
                }
            }
        }
    }
    
    public override func customUpdateCell() {
        super.customUpdateCell()
        let leftAligmnment = presentationMode != nil
        cell.textLabel?.textAlignment = leftAligmnment ? .Left : .Center
        cell.accessoryType = !leftAligmnment || isDisabled ? .None : .DisclosureIndicator
        cell.editingAccessoryType = cell.accessoryType
        if (!leftAligmnment){
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            cell.tintColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            cell.textLabel?.textColor  = UIColor(red: red, green: green, blue: blue, alpha:isDisabled ? 0.3 : 1.0)
        }
        else{
            cell.textLabel?.textColor = nil
        }
    }
    
    public override func prepareForSegue(segue: UIStoryboardSegue) {
        super.prepareForSegue(segue)
        let rowVC = segue.destinationViewController as? RowControllerType
        rowVC?.completionCallback = self.presentationMode?.completionHandler
    }
}

public class _ButtonRowWithPresent<T: Equatable, VCType: TypedRowControllerType where VCType: UIViewController, VCType.RowValue == T>: Row<T, ButtonCellOf<T>>, PresenterRowType {
    
    public var presentationMode: PresentationMode<VCType>?
    public var onPresentCallback : ((FormViewController, VCType)->())?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellStyle = .Default
    }
    
    public override func customUpdateCell() {
        super.customUpdateCell()
        let leftAligmnment = presentationMode != nil
        cell.textLabel?.textAlignment = leftAligmnment ? .Left : .Center
        cell.accessoryType = !leftAligmnment || isDisabled ? .None : .DisclosureIndicator
        cell.editingAccessoryType = cell.accessoryType
        if (!leftAligmnment){
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            cell.tintColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            cell.textLabel?.textColor  = UIColor(red: red, green: green, blue: blue, alpha:isDisabled ? 0.3 : 1.0)
        }
        else{
            cell.textLabel?.textColor = nil
        }
    }
    
    public override func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            if let presentationMode = presentationMode {
                if let controller = presentationMode.createController(){
                    controller.row = self
                    onPresentCallback?(cell.formViewController()!, controller)
                    presentationMode.presentViewController(controller, row: self, presentingViewController: self.cell.formViewController()!)
                }
                else{
                    presentationMode.presentViewController(nil, row: self, presentingViewController: self.cell.formViewController()!)
                }
            }
        }
    }
    
    public override func prepareForSegue(segue: UIStoryboardSegue) {
        super.prepareForSegue(segue)
        guard let rowVC = segue.destinationViewController as? VCType else {
            return
        }
        if let callback = self.presentationMode?.completionHandler{
            rowVC.completionCallback = callback
        }
        onPresentCallback?(cell.formViewController()!, rowVC)
        rowVC.row = self
    }
    
}


//MARK: Rows

/// Boolean row that has a checkmark as accessoryType
public final class CheckRow: _CheckRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

/// Boolean row that has a UISwitch as accessoryType
public final class SwitchRow: _SwitchRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

/// Simple row that can show title and value but is not editable by user.
public final class LabelRow: _LabelRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A row with an NSDate as value where the user can select a date from a picker view.
public final class DateRow: _DateRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        onCellHighlight { cell, row in
            let color = cell.detailTextLabel?.textColor
            row.onCellUnHighlight { cell, _ in
                cell.detailTextLabel?.textColor = color
            }
            cell.detailTextLabel?.textColor = cell.tintColor
        }
    }
}

/// A row with an NSDate as value where the user can select a time from a picker view.
public final class TimeRow: _TimeRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        onCellHighlight { cell, row in
            let color = cell.detailTextLabel?.textColor
            row.onCellUnHighlight { cell, _ in
                cell.detailTextLabel?.textColor = color
            }
            cell.detailTextLabel?.textColor = cell.tintColor
        }
    }
}

/// A row with an NSDate as value where the user can select date and time from a picker view.
public final class DateTimeRow: _DateTimeRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        onCellHighlight { cell, row in
            let color = cell.detailTextLabel?.textColor
            row.onCellUnHighlight { cell, _ in
                cell.detailTextLabel?.textColor = color
            }
            cell.detailTextLabel?.textColor = cell.tintColor
        }
    }
}

/// A row with an NSDate as value where the user can select hour and minute as a countdown timer in a picker view.
public final class CountDownRow: _CountDownRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        onCellHighlight { cell, row in
            let color = cell.detailTextLabel?.textColor
            row.onCellUnHighlight { cell, _ in
                cell.detailTextLabel?.textColor = color
            }
            cell.detailTextLabel?.textColor = cell.tintColor
        }
    }
}

/// A row with an NSDate as value where the user can select a date from an inline picker view.
public final class DateInlineRow: _DateInlineRow, RowType, InlineRowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        onExpandInlineRow { cell, row, _ in
            let color = cell.detailTextLabel?.textColor
            row.onCollapseInlineRow { cell, _, _ in
                cell.detailTextLabel?.textColor = color
            }
            cell.detailTextLabel?.textColor = cell.tintColor
        }
    }
    
    public override func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            toggleInlineRow()
        }
    }
}

/// A row with an NSDate as value where the user can select a time from an inline picker view.
public final class TimeInlineRow: _TimeInlineRow, RowType, InlineRowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        onExpandInlineRow { cell, row, _ in
            let color = cell.detailTextLabel?.textColor
            row.onCollapseInlineRow { cell, _, _ in
                cell.detailTextLabel?.textColor = color
            }
            cell.detailTextLabel?.textColor = cell.tintColor
        }
    }
    
    public override func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            toggleInlineRow()
        }
    }
}

/// A row with an NSDate as value where the user can select date and time from an inline picker view.
public final class DateTimeInlineRow: _DateTimeInlineRow, RowType, InlineRowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        onExpandInlineRow { cell, row, _ in
            let color = cell.detailTextLabel?.textColor
            row.onCollapseInlineRow { cell, _, _ in
                cell.detailTextLabel?.textColor = color
            }
            cell.detailTextLabel?.textColor = cell.tintColor
        }
    }
    
    public override func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            toggleInlineRow()
        }
    }
}

/// A row with an NSDate as value where the user can select hour and minute as a countdown timer in an inline picker view.
public final class CountDownInlineRow: _CountDownInlineRow, RowType, InlineRowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        onExpandInlineRow { cell, row, _ in
            let color = cell.detailTextLabel?.textColor
            row.onCollapseInlineRow { cell, _, _ in
                cell.detailTextLabel?.textColor = color
            }
            cell.detailTextLabel?.textColor = cell.tintColor
        }
    }
    
    public override func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            toggleInlineRow()
        }
    }
}

/// A row with an NSDate as value where the user can select a date directly.
public final class DatePickerRow : _DatePickerRow, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A row with an NSDate as value where the user can select a time directly.
public final class TimePickerRow : _DatePickerRow, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A row with an NSDate as value where the user can select date and time directly.
public final class DateTimePickerRow : _DatePickerRow, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A row with an NSDate as value where the user can select hour and minute as a countdown timer.
public final class CountDownPickerRow : _DatePickerRow, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A String valued row where the user can enter arbitrary text.
public final class TextRow: _TextRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        onCellHighlight { cell, row  in
            let color = cell.textLabel?.textColor
            row.onCellUnHighlight { cell, _ in
                cell.textLabel?.textColor = color
            }
            cell.textLabel?.textColor = cell.tintColor
        }
    }
}

/// A String valued row where the user can enter names. Biggest difference to TextRow is that it autocapitalization is set to Words.
public final class NameRow: _NameRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        onCellHighlight { cell, row  in
            let color = cell.textLabel?.textColor
            row.onCellUnHighlight { cell, _ in
                cell.textLabel?.textColor = color
            }
            cell.textLabel?.textColor = cell.tintColor
        }
    }
}

/// A String valued row where the user can enter secure text.
public final class PasswordRow: _PasswordRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        onCellHighlight { cell, row  in
            let color = cell.textLabel?.textColor
            row.onCellUnHighlight { cell, _ in
                cell.textLabel?.textColor = color
            }
            cell.textLabel?.textColor = cell.tintColor
        }
    }
}

/// A String valued row where the user can enter an email address.
public final class EmailRow: _EmailRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        onCellHighlight { cell, row  in
            let color = cell.textLabel?.textColor
            row.onCellUnHighlight { cell, _ in
                cell.textLabel?.textColor = color
            }
            cell.textLabel?.textColor = cell.tintColor
        }
    }
}

/// A String valued row where the user can enter a twitter username.
public final class TwitterRow: _TwitterRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        onCellHighlight { cell, row  in
            let color = cell.textLabel?.textColor
            row.onCellUnHighlight { cell, _ in
                cell.textLabel?.textColor = color
            }
            cell.textLabel?.textColor = cell.tintColor
        }
    }
}

/// A String valued row where the user can enter a simple account username.
public final class AccountRow: _AccountRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        onCellHighlight { cell, row  in
            let color = cell.textLabel?.textColor
            row.onCellUnHighlight { cell, _ in
                cell.textLabel?.textColor = color
            }
            cell.textLabel?.textColor = cell.tintColor
        }
    }
}

/// A String valued row where the user can enter a zip code.
public final class ZipCodeRow: _ZipCodeRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        onCellHighlight { cell, row  in
            let color = cell.textLabel?.textColor
            row.onCellUnHighlight { cell, _ in
                cell.textLabel?.textColor = color
            }
            cell.textLabel?.textColor = cell.tintColor
        }
    }
}

/// A row where the user can enter an integer number.
public final class IntRow: _IntRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        onCellHighlight { cell, row  in
            let color = cell.textLabel?.textColor
            row.onCellUnHighlight { cell, _ in
                cell.textLabel?.textColor = color
            }
            cell.textLabel?.textColor = cell.tintColor
        }
    }
}

/// A row where the user can enter a decimal number.
public final class DecimalRow: _DecimalRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        onCellHighlight { cell, row  in
            let color = cell.textLabel?.textColor
            row.onCellUnHighlight { cell, _ in
                cell.textLabel?.textColor = color
            }
            cell.textLabel?.textColor = cell.tintColor
        }
    }
}

/// A row where the user can enter an URL. The value of this row will be a NSURL.
public final class URLRow: _URLRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        onCellHighlight { cell, row  in
            let color = cell.textLabel?.textColor
            row.onCellUnHighlight { cell, _ in
                cell.textLabel?.textColor = color
            }
            cell.textLabel?.textColor = cell.tintColor
        }
    }
}

/// A String valued row where the user can enter a phone number.
public final class PhoneRow: _PhoneRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        onCellHighlight { cell, row  in
            let color = cell.textLabel?.textColor
            row.onCellUnHighlight { cell, _ in
                cell.textLabel?.textColor = color
            }
            cell.textLabel?.textColor = cell.tintColor
        }
    }
}

/// A row with a UITextView where the user can enter large text.
public final class TextAreaRow: _TextAreaRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

/// An options row where the user can select an option from an UISegmentedControl
public final class SegmentedRow<T: Equatable>: OptionsRow<T, SegmentedCell<T>>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

/// An options row where the user can select an option from an ActionSheet
public final class ActionSheetRow<T: Equatable>: _ActionSheetRow<T, AlertSelectorCell<T>>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

/// An options row where the user can select an option from a modal Alert
public final class AlertRow<T: Equatable>: _AlertRow<T, AlertSelectorCell<T>>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A selector row where the user can pick an image
public final class ImageRow : _ImageRow<PushSelectorCell<UIImage>>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A selector row where the user can pick an option from a pushed view controller
public final class PushRow<T: Equatable> : _PushRow<T, PushSelectorCell<T>>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

public final class PopoverSelectorRow<T: Equatable> : _PopoverSelectorRow<T, PushSelectorCell<T>>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}


/// A selector row where the user can pick several options from a pushed view controller
public final class MultipleSelectorRow<T: Hashable> : _MultipleSelectorRow<T, PushSelectorCell<Set<T>>>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A generic row with a button. The action of this button can be anything but normally will push a new view controller
public final class ButtonRowOf<T: Equatable> : _ButtonRowOf<T>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A row with a button and String value. The action of this button can be anything but normally will push a new view controller
public typealias ButtonRow = ButtonRowOf<String>

/// A generic row with a button that presents a view controller when tapped
public final class ButtonRowWithPresent<T: Equatable, VCType: TypedRowControllerType where VCType: UIViewController, VCType.RowValue == T> : _ButtonRowWithPresent<T, VCType>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A generic inline row where the user can pick an option from a picker view
public final class PickerInlineRow<T where T: Equatable> : _PickerInlineRow<T>, RowType, InlineRowType{
    
    required public init(tag: String?) {
        super.init(tag: tag)
        onExpandInlineRow { cell, row, _ in
            let color = cell.detailTextLabel?.textColor
            row.onCollapseInlineRow { cell, _, _ in
                cell.detailTextLabel?.textColor = color
            }
            cell.detailTextLabel?.textColor = cell.tintColor
        }
    }
    
    public override func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            toggleInlineRow()
        }
    }
    
    public func setupInlineRow(inlineRow: InlineRow) {
        inlineRow.options = self.options
        inlineRow.displayValueFor = self.displayValueFor
    }
}

/// A generic row where the user can pick an option from a picker view
public final class PickerRow<T where T: Equatable>: _PickerRow<T>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A PostalAddress valued row where the user can enter a postal address.
public final class PostalAddressRow: _PostalAddressRow<PostalAddress, DefaultPostalAddressCell<PostalAddress>>, RowType {
	public required init(tag: String? = nil) {
		super.init(tag: tag)
		onCellHighlight { cell, row  in
			let color = cell.textLabel?.textColor
			row.onCellUnHighlight { cell, _ in
				cell.textLabel?.textColor = color
			}
			cell.textLabel?.textColor = cell.tintColor
		}
	}
}