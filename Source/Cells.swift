//  Cells.swift
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

// MARK: LabelCell

public class LabelCellOf<T: Equatable>: Cell<T>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .None
    }
    
    public override func update() {
        super.update()
    }
}

public typealias LabelCell = LabelCellOf<String>

// MARK: ButtonCell

public class ButtonCellOf<T: Equatable>: Cell<T>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func setup() {
        super.setup()
    }
    
    public override func update() {
        super.update()
        selectionStyle = row.isDisabled ? .None : .Default
        accessoryType = .None
        editingAccessoryType = accessoryType
        textLabel?.textAlignment = .Center
        textLabel?.textColor = tintColor
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        tintColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        textLabel?.textColor  = UIColor(red: red, green: green, blue: blue, alpha: row.isDisabled ? 0.3 : 1.0)
    }
    
    public override func didSelect() {
        super.didSelect()
        formViewController()?.tableView?.deselectRowAtIndexPath(row.indexPath()!, animated: true)
    }
}

public typealias ButtonCell = ButtonCellOf<String>

// MARK: FieldCell

public protocol InputTypeInitiable {
    init?(string stringValue: String)
}

extension Int: InputTypeInitiable {

    public init?(string stringValue: String){
        self.init(stringValue, radix: 10)
    }
}
extension Float: InputTypeInitiable {
    public init?(string stringValue: String){
        self.init(stringValue)
    }
}
extension String: InputTypeInitiable {
    public init?(string stringValue: String){
        self.init(stringValue)
    }
}
extension NSURL: InputTypeInitiable {}

public class _FieldCell<T where T: Equatable, T: InputTypeInitiable> : Cell<T>, UITextFieldDelegate, TextFieldCell {
    lazy public var textField : UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    public var titleLabel : UILabel? {
        textLabel?.translatesAutoresizingMaskIntoConstraints = false
        textLabel?.setContentHuggingPriority(500, forAxis: .Horizontal)
        textLabel?.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)
        return textLabel
    }

    private var dynamicConstraints = [NSLayoutConstraint]()
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    deinit {
        titleLabel?.removeObserver(self, forKeyPath: "text")
        imageView?.removeObserver(self, forKeyPath: "image")
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .None
        contentView.addSubview(titleLabel!)
        contentView.addSubview(textField)

        titleLabel?.addObserver(self, forKeyPath: "text", options: NSKeyValueObservingOptions.Old.union(.New), context: nil)
        imageView?.addObserver(self, forKeyPath: "image", options: NSKeyValueObservingOptions.Old.union(.New), context: nil)
        textField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
        
    }
    
    public override func update() {
        super.update()
        detailTextLabel?.text = nil
        if let title = row.title {
            textField.textAlignment = title.isEmpty ? .Left : .Right
            textField.clearButtonMode = title.isEmpty ? .WhileEditing : .Never
        }
        else{
            textField.textAlignment =  .Left
            textField.clearButtonMode =  .WhileEditing
        }
        textField.delegate = self
        textField.text = row.displayValueFor?(row.value)
        textField.enabled = !row.isDisabled
        textField.textColor = row.isDisabled ? .grayColor() : .blackColor()
        textField.font = .preferredFontForTextStyle(UIFontTextStyleBody)
        if let placeholder = (row as? FieldRowConformance)?.placeholder {
            if let color = (row as? FieldRowConformance)?.placeholderColor {
                textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: color])
            }
            else{
                textField.placeholder = (row as? FieldRowConformance)?.placeholder
            }
        }
    }
    
    public override func cellCanBecomeFirstResponder() -> Bool {
        return !row.isDisabled && textField.canBecomeFirstResponder()
    }
    
    public override func cellBecomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    public override func cellResignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let obj = object, let keyPathValue = keyPath, let changeType = change?[NSKeyValueChangeKindKey] where ((obj === titleLabel && keyPathValue == "text") || (obj === imageView && keyPathValue == "image")) && changeType.unsignedLongValue == NSKeyValueChange.Setting.rawValue {
            setNeedsUpdateConstraints()
            updateConstraintsIfNeeded()
        }
    }
    
    // Mark: Helpers
    
    public override func updateConstraints(){
        contentView.removeConstraints(dynamicConstraints)
        dynamicConstraints = []
        var views : [String: AnyObject] =  ["textField": textField]
        dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-11-[textField]-11-|", options: .AlignAllBaseline, metrics: nil, views: ["textField": textField])
        
        if let label = titleLabel, let text = label.text where !text.isEmpty {
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-11-[titleLabel]-11-|", options: .AlignAllBaseline, metrics: nil, views: ["titleLabel": label])
                dynamicConstraints.append(NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: textField, attribute: .CenterY, multiplier: 1, constant: 0))
        }
        if let imageView = imageView, let _ = imageView.image {
            views["imageView"] = imageView
            if let titleLabel = titleLabel, text = titleLabel.text where !text.isEmpty {
                views["label"] = titleLabel
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:[imageView]-[label]-[textField]-|", options: NSLayoutFormatOptions(), metrics: nil, views: views)
                dynamicConstraints.append(NSLayoutConstraint(item: textField, attribute: .Width, relatedBy: (row as? FieldRowConformance)?.textFieldPercentage != nil ? .Equal : .GreaterThanOrEqual, toItem: contentView, attribute: .Width, multiplier: (row as? FieldRowConformance)?.textFieldPercentage ?? 0.3, constant: 0.0))
            }
            else{
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:[imageView]-[textField]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
            }
        }
        else{
            if let titleLabel = titleLabel, let text = titleLabel.text where !text.isEmpty {
                views["label"] = titleLabel
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label]-[textField]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
                dynamicConstraints.append(NSLayoutConstraint(item: textField, attribute: .Width, relatedBy: (row as? FieldRowConformance)?.textFieldPercentage != nil ? .Equal : .GreaterThanOrEqual, toItem: contentView, attribute: .Width, multiplier: (row as? FieldRowConformance)?.textFieldPercentage ?? 0.3, constant: 0.0))
            }
            else{
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[textField]-|", options: .AlignAllLeft, metrics: nil, views: views)
            }
        }
        contentView.addConstraints(dynamicConstraints)
        super.updateConstraints()
    }
    
    public func textFieldDidChange(textField : UITextField){
        guard let textValue = textField.text else {
            row.value = nil
            return
        }
        if let fieldRow = row as? FieldRowConformance, let formatter = fieldRow.formatter where fieldRow.useFormatterDuringInput {
            let value: AutoreleasingUnsafeMutablePointer<AnyObject?> = AutoreleasingUnsafeMutablePointer<AnyObject?>.init(UnsafeMutablePointer<T>.alloc(1))
            let errorDesc: AutoreleasingUnsafeMutablePointer<NSString?> = nil
            if formatter.getObjectValue(value, forString: textValue, errorDescription: errorDesc) {
                row.value = value.memory as? T
                if var selStartPos = textField.selectedTextRange?.start {
                    let oldVal = textField.text
                    textField.text = row.displayValueFor?(row.value)
                    if let f = formatter as? FormatterProtocol {
                        selStartPos = f.getNewPosition(forPosition: selStartPos, inTextInput: textField, oldValue: oldVal, newValue: textField.text)
                    }
                    textField.selectedTextRange = textField.textRangeFromPosition(selStartPos, toPosition: selStartPos)
                }
                return
            }
        }
        guard !textValue.isEmpty else {
            row.value = nil
            return
        }
        guard let newValue = T.init(string: textValue) else {
            row.updateCell()
            return
        }
        row.value = newValue
    }
    
    //MARK: TextFieldDelegate
    
    public func textFieldDidBeginEditing(textField: UITextField) {
        formViewController()?.beginEditing(self)
        formViewController()?.textInputDidBeginEditing(textField, cell: self)
        if let fieldRowConformance = (row as? FieldRowConformance), let _ = fieldRowConformance.formatter where !fieldRowConformance.useFormatterDuringInput {
                textField.text = row.displayValueFor?(row.value)
        }
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
        formViewController()?.endEditing(self)
        formViewController()?.textInputDidEndEditing(textField, cell: self)
        textFieldDidChange(textField)
        if let fieldRowConformance = (row as? FieldRowConformance), let _ = fieldRowConformance.formatter where !fieldRowConformance.useFormatterDuringInput {
            textField.text = row.displayValueFor?(row.value)
        }
    }
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldReturn(textField, cell: self) ?? true
    }
    
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return formViewController()?.textInput(textField, shouldChangeCharactersInRange:range, replacementString:string, cell: self) ?? true
    }
    
    public func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldBeginEditing(textField, cell: self) ?? true
    }
    
    public func textFieldShouldClear(textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldClear(textField, cell: self) ?? true
    }
    
    public func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldEndEditing(textField, cell: self) ?? true
    }
    
    
}

public class TextCell : _FieldCell<String>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func setup() {
        super.setup()
        textField.autocorrectionType = .Default
        textField.autocapitalizationType = .Sentences
        textField.keyboardType = .Default
    }
}


public class IntCell : _FieldCell<Int>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func setup() {
        super.setup()
        textField.autocorrectionType = .Default
        textField.autocapitalizationType = .None
        textField.keyboardType = .NumberPad
    }
}

public class PhoneCell : _FieldCell<String>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func setup() {
        super.setup()
        textField.keyboardType = .PhonePad
    }
}

public class NameCell : _FieldCell<String>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func setup() {
        super.setup()
        textField.autocorrectionType = .No
        textField.autocapitalizationType = .Words
        textField.keyboardType = .ASCIICapable
    }
}

public class EmailCell : _FieldCell<String>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func setup() {
        super.setup()
        textField.autocorrectionType = .No
        textField.autocapitalizationType = .None
        textField.keyboardType = .EmailAddress
    }
}

public class PasswordCell : _FieldCell<String>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func setup() {
        super.setup()
        textField.autocorrectionType = .No
        textField.autocapitalizationType = .None
        textField.keyboardType = .ASCIICapable
        textField.secureTextEntry = true
    }
}

public class DecimalCell : _FieldCell<Float>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func setup() {
        super.setup()
        textField.autocorrectionType = .No
        textField.keyboardType = .DecimalPad
    }
}

public class URLCell : _FieldCell<NSURL>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func setup() {
        super.setup()
        textField.autocorrectionType = .No
        textField.autocapitalizationType = .None
        textField.keyboardType = .URL
    }
}

public class TwitterCell : _FieldCell<String>, CellType {

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    public override func setup() {
        super.setup()
        textField.autocorrectionType = .No
        textField.autocapitalizationType = .None
        textField.keyboardType = .Twitter
    }
}

public class AccountCell : _FieldCell<String>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func setup() {
        super.setup()
        textField.autocorrectionType = .No
        textField.autocapitalizationType = .None
        textField.keyboardType = .ASCIICapable
    }
}

public class ZipCodeCell : _FieldCell<String>, CellType {

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    public override func update() {
        super.update()
        textField.autocorrectionType = .No
        textField.autocapitalizationType = .AllCharacters
        textField.keyboardType = .NumbersAndPunctuation
    }
}

public class DateCell : Cell<NSDate>, CellType {
    
    lazy public var datePicker : UIDatePicker = {
        return UIDatePicker()
    }()
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func setup() {
        super.setup()
        accessoryType = .None
        editingAccessoryType =  .None
        datePicker.datePickerMode = datePickerMode()
        datePicker.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: .ValueChanged)
    }
    
    
    public override func update() {
        super.update()
        selectionStyle = row.isDisabled ? .None : .Default
        detailTextLabel?.text = row.displayValueFor?(row.value)
        datePicker.setDate(row.value ?? NSDate(), animated: row is CountDownPickerRow)
        datePicker.minimumDate = (row as? _DatePickerRowProtocol)?.minimumDate
        datePicker.maximumDate = (row as? _DatePickerRowProtocol)?.maximumDate
        if let minuteIntervalValue = (row as? _DatePickerRowProtocol)?.minuteInterval{
            datePicker.minuteInterval = minuteIntervalValue
        }
    }
    
    public override func didSelect() {
        super.didSelect()
        formViewController()?.tableView?.deselectRowAtIndexPath(row.indexPath()!, animated: true)
    }
    
    override public var inputView : UIView? {
        if let v = row.value{
            datePicker.setDate(v, animated:row is CountDownRow)
        }
        return datePicker
    }
    
    func datePickerValueChanged(sender: UIDatePicker){
        row.value = sender.date
        detailTextLabel?.text = row.displayValueFor?(row.value)
    }
    
    private func datePickerMode() -> UIDatePickerMode{
        switch row {
        case is DateRow:
            return .Date
        case is TimeRow:
            return .Time
        case is DateTimeRow:
            return .DateAndTime
        case is CountDownRow:
            return .CountDownTimer
        default:
            return .Date
        }
    }
    
    public override func cellCanBecomeFirstResponder() -> Bool {
        return canBecomeFirstResponder()
    }
    
    public override func canBecomeFirstResponder() -> Bool {
        return !row.isDisabled;
    }
}

public class DateInlineCell : Cell<NSDate>, CellType {
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    public override func setup() {
        super.setup()
        accessoryType = .None
        editingAccessoryType =  .None
    }
    
    public override func update() {
        super.update()
        selectionStyle = row.isDisabled ? .None : .Default
        detailTextLabel?.text = row.displayValueFor?(row.value)
    }
    
    public override func didSelect() {
        super.didSelect()
        formViewController()?.tableView?.deselectRowAtIndexPath(row.indexPath()!, animated: true)
    }
}

public class DatePickerCell : Cell<NSDate>, CellType {
    
    public lazy var datePicker: UIDatePicker = { [unowned self] in
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(picker)
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[picker]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["picker": picker]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[picker]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["picker": picker]))
        picker.addTarget(self, action: "datePickerValueChanged:", forControlEvents: .ValueChanged)
        return picker
        }()
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func setup() {
        super.setup()
        height = { 213 }
        accessoryType = .None
        editingAccessoryType =  .None
        datePicker.datePickerMode = datePickerMode()
    }
    
    public override func update() {
        super.update()
        selectionStyle = row.isDisabled ? .None : .Default
        datePicker.userInteractionEnabled = !row.isDisabled
        detailTextLabel?.text = nil
        textLabel?.text = nil
        datePicker.setDate(row.value ?? NSDate(), animated: row is CountDownPickerRow)
        datePicker.minimumDate = (row as? _DatePickerRowProtocol)?.minimumDate
        datePicker.maximumDate = (row as? _DatePickerRowProtocol)?.maximumDate
        if let minuteIntervalValue = (row as? _DatePickerRowProtocol)?.minuteInterval{
            datePicker.minuteInterval = minuteIntervalValue
        }
    }
    
    func datePickerValueChanged(sender: UIDatePicker){
        row.value = sender.date
    }
    
    private func datePickerMode() -> UIDatePickerMode{
        switch row {
        case is DatePickerRow:
            return .Date
        case is TimePickerRow:
            return .Time
        case is DateTimePickerRow:
           return .DateAndTime
        case is CountDownPickerRow:
            return .CountDownTimer
        default:
            return .Date
        }
    }
}

public class PickerCell<T where T: Equatable> : Cell<T>, CellType, UIPickerViewDataSource, UIPickerViewDelegate{
    
    public lazy var picker: UIPickerView = { [unowned self] in
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(picker)
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[picker]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["picker": picker]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[picker]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["picker": picker]))
        return picker
        }()
    
    private var pickerRow : _PickerRow<T> { return row as! _PickerRow<T> }
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func setup() {
        super.setup()
        height = { 213 }
        accessoryType = .None
        editingAccessoryType = .None
        picker.delegate = self
        picker.dataSource = self
    }
    
    public override func update(){
        super.update()
        textLabel?.text = nil
        detailTextLabel?.text = nil
        if let selectedValue = pickerRow.value, let index = pickerRow.options.indexOf(selectedValue){
            picker.selectRow(index, inComponent: 0, animated: true)
        }
    }
    
    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return pickerRow.options.count
    }
    
    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return pickerRow.displayValueFor?(pickerRow.options[row])
    }
    
    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerRow.value = pickerRow.options[row]
    }
    
}

public class _TextAreaCell<T where T: Equatable, T: InputTypeInitiable> : Cell<T>, UITextViewDelegate, AreaCell {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public lazy var placeholderLabel : UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.numberOfLines = 0
        v.textColor = UIColor(white: 0, alpha: 0.22)
        return v
    }()
    
    public lazy var textView : UITextView = {
        let v = UITextView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private var dynamicConstraints = [NSLayoutConstraint]()
    
    public override func setup() {
        super.setup()
        height = { 110 }
        textView.keyboardType = .Default
        textView.delegate = self
        textView.font = .preferredFontForTextStyle(UIFontTextStyleBody)
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsetsZero
        placeholderLabel.font = textView.font
        selectionStyle = .None
        contentView.addSubview(textView)
        contentView.addSubview(placeholderLabel)
        
        let views : [String: AnyObject] =  ["textView": textView, "label": placeholderLabel]
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[label]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[textView]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[textView]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }
    
    public override func update() {
        super.update()
        textLabel?.text = nil
        detailTextLabel?.text = nil
        textView.editable = !row.isDisabled
        textView.textColor = row.isDisabled ? .grayColor() : .blackColor()
        textView.text = row.displayValueFor?(row.value)
        placeholderLabel.text = (row as? TextAreaConformance)?.placeholder
        placeholderLabel.sizeToFit()
        placeholderLabel.hidden = textView.text.characters.count != 0
    }
    
    public override func cellCanBecomeFirstResponder() -> Bool {
        return !row.isDisabled && textView.canBecomeFirstResponder()
    }
    
    public override func cellBecomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }
    
    public override func cellResignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }
    
    public func textViewDidBeginEditing(textView: UITextView) {
        formViewController()?.beginEditing(self)
        formViewController()?.textInputDidBeginEditing(textView, cell: self)
        if let textAreaConformance = (row as? TextAreaConformance), let _ = textAreaConformance.formatter where !textAreaConformance.useFormatterDuringInput {
            textView.text = row.displayValueFor?(row.value)
        }
    }
    
    public func textViewDidEndEditing(textView: UITextView) {
        formViewController()?.endEditing(self)
        formViewController()?.textInputDidEndEditing(textView, cell: self)
        textViewDidChange(textView)
        if let textAreaConformance = (row as? TextAreaConformance), let _ = textAreaConformance.formatter where !textAreaConformance.useFormatterDuringInput {
            textView.text = row.displayValueFor?(row.value)
        }
    }
    
    public func textViewDidChange(textView: UITextView) {
        placeholderLabel.hidden = textView.text.characters.count != 0
        guard let textValue = textView.text else {
            row.value = nil
            return
        }
        if let fieldRow = row as? TextAreaConformance, let formatter = fieldRow.formatter where fieldRow.useFormatterDuringInput {
            let value: AutoreleasingUnsafeMutablePointer<AnyObject?> = AutoreleasingUnsafeMutablePointer<AnyObject?>.init(UnsafeMutablePointer<T>.alloc(1))
            let errorDesc: AutoreleasingUnsafeMutablePointer<NSString?> = nil
            if formatter.getObjectValue(value, forString: textValue, errorDescription: errorDesc) {
                row.value = value.memory as? T
                if var selStartPos = textView.selectedTextRange?.start {
                    let oldVal = textView.text
                    textView.text = row.displayValueFor?(row.value)
                    if let f = formatter as? FormatterProtocol {
                        selStartPos = f.getNewPosition(forPosition: selStartPos, inTextInput: textView, oldValue: oldVal, newValue: textView.text)
                    }
                    textView.selectedTextRange = textView.textRangeFromPosition(selStartPos, toPosition: selStartPos)
                }
                return
            }
        }
        guard !textValue.isEmpty else {
            row.value = nil
            return
        }
        guard let newValue = T.init(string: textValue) else {
            row.updateCell()
            return
        }
        row.value = newValue
    }
    
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return formViewController()?.textInput(textView, shouldChangeCharactersInRange: range, replacementString: text, cell: self) ?? true
    }
    
    public func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return formViewController()?.textInputShouldBeginEditing(textView, cell: self) ?? true
    }
    
    public func textViewShouldEndEditing(textView: UITextView) -> Bool {
        return formViewController()?.textInputShouldEndEditing(textView, cell: self) ?? true
    }
}

public class TextAreaCell : _TextAreaCell<String>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
}

public class CheckCell : Cell<Bool>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func update() {
        super.update()
        accessoryType = row.value == true ? .Checkmark : .None
        editingAccessoryType = accessoryType
        selectionStyle = .Default
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        tintColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        if row.isDisabled {
            tintColor = UIColor(red: red, green: green, blue: blue, alpha: 0.3)
            selectionStyle = .None
        }
        else {
            tintColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
        }
    }

    public override func setup() {
        super.setup()
        accessoryType =  .Checkmark
        editingAccessoryType = accessoryType
    }
    
    public override func didSelect() {
        row.value = row.value ?? false ? false : true
        formViewController()?.tableView?.deselectRowAtIndexPath(row.indexPath()!, animated: true)
        row.updateCell()
    }
    
}


public class ListCheckCell<T: Equatable> : Cell<T>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func update() {
        super.update()
        accessoryType = row.value != nil ? .Checkmark : .None
        editingAccessoryType = accessoryType
        selectionStyle = .Default
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        tintColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        if row.isDisabled {
            tintColor = UIColor(red: red, green: green, blue: blue, alpha: 0.3)
            selectionStyle = .None
        }
        else {
            tintColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
        }
    }
    
    public override func setup() {
        super.setup()
        accessoryType =  .Checkmark
        editingAccessoryType = accessoryType
    }
    
    public override func didSelect() {
        formViewController()?.tableView?.deselectRowAtIndexPath(row.indexPath()!, animated: true)
        row.updateCell()
    }
    
}

public class SwitchCell : Cell<Bool>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public var switchControl: UISwitch? {
        return accessoryView as? UISwitch
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .None
        accessoryView = UISwitch()
        editingAccessoryView = accessoryView
        switchControl?.addTarget(self, action: "valueChanged", forControlEvents: .ValueChanged)
    }
    
    public override func update() {
        super.update()
        switchControl?.on = row.value ?? false
        switchControl?.enabled = !row.isDisabled
    }
    
    func valueChanged() {
        row.value = switchControl?.on.boolValue ?? false
    }
}

public class SegmentedCell<T: Equatable> : Cell<T>, CellType {
    
    public var titleLabel : UILabel? {
        textLabel?.translatesAutoresizingMaskIntoConstraints = false
        textLabel?.setContentHuggingPriority(500, forAxis: .Horizontal)
        return textLabel
    }
    lazy public var segmentedControl : UISegmentedControl = {
        let result = UISegmentedControl()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.setContentHuggingPriority(500, forAxis: .Horizontal)
        return result
    }()
    private var dynamicConstraints = [NSLayoutConstraint]()
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    deinit {
        titleLabel?.removeObserver(self, forKeyPath: "text")
        imageView?.removeObserver(self, forKeyPath: "image")
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .None
        contentView.addSubview(titleLabel!)
        contentView.addSubview(segmentedControl)
        titleLabel?.addObserver(self, forKeyPath: "text", options: NSKeyValueObservingOptions.Old.union(.New), context: nil)
        imageView?.addObserver(self, forKeyPath: "image", options: NSKeyValueObservingOptions.Old.union(.New), context: nil)
        segmentedControl.addTarget(self, action: "valueChanged", forControlEvents: .ValueChanged)
        contentView.addConstraint(NSLayoutConstraint(item: segmentedControl, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0))
    }
    
    public override func update() {
        super.update()
        detailTextLabel?.text = nil

        updateSegmentedControl()
        segmentedControl.selectedSegmentIndex = selectedIndex() ?? UISegmentedControlNoSegment
        segmentedControl.enabled = !row.isDisabled
    }
    
    func valueChanged() {
        row.value =  (row as! SegmentedRow<T>).options[segmentedControl.selectedSegmentIndex]
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let obj = object, let changeType = change, let _ = keyPath where ((obj === titleLabel && keyPath == "text") || (obj === imageView && keyPath == "image")) && changeType[NSKeyValueChangeKindKey]?.unsignedLongValue == NSKeyValueChange.Setting.rawValue{
            setNeedsUpdateConstraints()
            updateConstraintsIfNeeded()
        }
    }
    
    func updateSegmentedControl() {
        segmentedControl.removeAllSegments()
        for item in items().enumerate() {
            segmentedControl.insertSegmentWithTitle(item.element, atIndex: item.index, animated: false)
        }
    }
    
    public override func updateConstraints() {
        contentView.removeConstraints(dynamicConstraints)
        dynamicConstraints = []
        var views : [String: AnyObject] =  ["segmentedControl": segmentedControl]
        
        var hasImageView = false
        var hasTitleLabel = false
        
        if let imageView = imageView, let _ = imageView.image {
            views["imageView"] = imageView
            hasImageView = true
        }
        
        if let titleLabel = titleLabel, text = titleLabel.text where !text.isEmpty {
            views["titleLabel"] = titleLabel
            hasTitleLabel = true
        }
        
        if hasImageView && hasTitleLabel {
            dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:[imageView]-[titleLabel]-[segmentedControl]-|", options: NSLayoutFormatOptions(), metrics: nil, views: views)
            dynamicConstraints.append(NSLayoutConstraint(item: segmentedControl, attribute: .Width, relatedBy: (row as? FieldRowConformance)?.textFieldPercentage != nil ? .Equal : .GreaterThanOrEqual, toItem: contentView, attribute: .Width, multiplier: (row as? FieldRowConformance)?.textFieldPercentage ?? 0.3, constant: 0.0))
            dynamicConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-12-[titleLabel]-12-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        }
        else if hasImageView && !hasTitleLabel {
            dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:[imageView]-[segmentedControl]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        }
        else if !hasImageView && hasTitleLabel {
            dynamicConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[titleLabel]-16-[segmentedControl]-|", options: .AlignAllCenterY, metrics: nil, views: views)
            dynamicConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-12-[titleLabel]-12-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        }
        else {
            dynamicConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[segmentedControl]-|", options: .AlignAllCenterY, metrics: nil, views: views)
        }
        
        contentView.addConstraints(dynamicConstraints)
        super.updateConstraints()
    }
    
    func items() -> [String] {// or create protocol for options
        var result = [String]()
        for object in (row as! SegmentedRow<T>).options{
            result.append(row.displayValueFor?(object) ?? "")
        }
        return result
    }
    
    func selectedIndex() -> Int? {
        guard let value = row.value else { return nil }
        return (row as! SegmentedRow<T>).options.indexOf(value)
    }
}

public class AlertSelectorCell<T: Equatable> : Cell<T>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    public override func update() {
        super.update()
        accessoryType = .None
        editingAccessoryType = accessoryType
        selectionStyle = row.isDisabled ? .None : .Default
    }
    
    public override func didSelect() {
        super.didSelect()
        formViewController()?.tableView?.deselectRowAtIndexPath(row.indexPath()!, animated: true)
    }
}

public class PushSelectorCell<T: Equatable> : Cell<T>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func update() {
        super.update()
        accessoryType = .DisclosureIndicator
        editingAccessoryType = accessoryType
        selectionStyle = row.isDisabled ? .None : .Default
    }
}


