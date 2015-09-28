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
        textLabel?.textColor = tintColor
        selectionStyle = row.isDisabled ? .None : .Default
        accessoryType = .None
        editingAccessoryType = accessoryType
        textLabel?.textAlignment = .Center
        
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        tintColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        textLabel?.textColor  = UIColor(red: red, green: green, blue: blue, alpha: row.isDisabled ? 0.3 : 1.0)
    }
}

public typealias ButtonCell = ButtonCellOf<String>

// MARK: FieldCell

public protocol FieldTypeInitiable {
    init?(string stringValue: String)
}

extension Int: FieldTypeInitiable {

    public init?(string stringValue: String){
        self.init(stringValue, radix: 10)
    }
}
extension Float: FieldTypeInitiable {
    public init?(string stringValue: String){
        self.init(stringValue)
    }
}
extension String: FieldTypeInitiable {
    public init?(string stringValue: String){
        self.init(stringValue)
    }
}
extension NSURL: FieldTypeInitiable {}

public class _FieldCell<T where T: Equatable, T: FieldTypeInitiable> : Cell<T>, UITextFieldDelegate, TextFieldCell {
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
    
    public func valueFromString(string: String?) -> T? {
        if let formatter = (row as? FieldRowConformance)?.formatter {
            let value: AutoreleasingUnsafeMutablePointer<AnyObject?> = nil
            let errorDesc: AutoreleasingUnsafeMutablePointer<NSString?> = nil
            formatter.getObjectValue(value, forString: string!, errorDescription: errorDesc)
            return value as? T
        }
        else{
            return row.value
        }
    }
    
    public override func update() {
        super.update()
        if let title = row.title {
            textField.textAlignment = title.isEmpty ? .Left : .Right
            textField.clearButtonMode = title.isEmpty ? .WhileEditing : .Never
        }
        else{
            textField.textAlignment =  .Left
            textField.clearButtonMode =  .WhileEditing
        }
        textField.delegate = self
        detailTextLabel?.text = nil
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
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let obj = object, let keyPathValue = keyPath, let changeType = change?[NSKeyValueChangeKindKey]{
            if (obj === titleLabel && keyPathValue == "text") || (obj === imageView && keyPathValue == "image"){
                if changeType.unsignedLongValue == NSKeyValueChange.Setting.rawValue{
                    contentView.setNeedsUpdateConstraints()
                }
            }
        }
    }
    
    // Mark: Helpers
    
    public override func updateConstraints(){
        contentView.removeConstraints(dynamicConstraints)
        var views : [String: AnyObject] =  ["textField": textField]
        
        
        dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-11-[textField]-11-|", options: .AlignAllBaseline, metrics: nil, views: ["textField": textField])
        
        if let label = titleLabel, _ = label.text {
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-11-[titleLabel]-11-|", options: .AlignAllBaseline, metrics: nil, views: ["titleLabel": label])
                dynamicConstraints.append(NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: textField, attribute: .CenterY, multiplier: 1, constant: 0))
        }
        if let image = imageView?.image {
            views["image"] = image
            if let text = titleLabel?.text {
                if !text.isEmpty {
                    views["label"] = titleLabel!
                    dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:[image]-[label]-[textField]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
                }
            }
            else{
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:[image]-[textField]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
            }
        }
        else{
            if let text = titleLabel?.text {
                if !text.isEmpty {
                    views["label"] = titleLabel!
                    dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label]-[textField]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
                }
            }
            else{
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[textField]-|", options: .AlignAllLeft, metrics: nil, views: views)
            }
        }
        dynamicConstraints.append(NSLayoutConstraint(item: textField, attribute: .Width, relatedBy: (row as? FieldRowConformance)?.textFieldPercentage != nil ? .Equal : .GreaterThanOrEqual, toItem: contentView, attribute: .Width, multiplier: (row as? FieldRowConformance)?.textFieldPercentage ?? 0.3, constant: 0.0))
        
        contentView.addConstraints(dynamicConstraints)
        super.updateConstraints()
    }
    
    public func textFieldDidChange(textField : UITextField){
        guard let textValue = textField.text else {
            row.value = nil
            return
        }
        if let fieldRow = row as? FieldRowConformance, let formatter = fieldRow.formatter {
            if fieldRow.useFormatterDuringInput {
                let value: AutoreleasingUnsafeMutablePointer<AnyObject?> = AutoreleasingUnsafeMutablePointer<AnyObject?>.init(UnsafeMutablePointer<T>.alloc(1))
                let errorDesc: AutoreleasingUnsafeMutablePointer<NSString?> = nil
                if formatter.getObjectValue(value, forString: textValue, errorDescription: errorDesc) {
                    row.value = value.memory as? T
                    if var selStartPos = textField.selectedTextRange?.start {
                        let oldVal = textField.text
                        textField.text = row.displayValueFor?(row.value)
                        if let f = formatter as? FormatterProtocol {
                            selStartPos = f.getNewPosition(forPosition: selStartPos, inTextField: textField, oldValue: oldVal, newValue: textField.text)
                        }
                        textField.selectedTextRange = textField.textRangeFromPosition(selStartPos, toPosition: selStartPos)
                    }
                    return
                }
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
        if let _ = (row as? FieldRowConformance)?.formatter {
            if (row as? FieldRowConformance)?.useFormatterDuringInput == false {
                textField.text = row.displayValueFor?(row.value)
            }
        }
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
        textFieldDidChange(textField)
        formViewController()?.endEditing(self)
        if let _ = (row as? FieldRowConformance)?.formatter {
            if (row as? FieldRowConformance)?.useFormatterDuringInput == false {
                textField.text = row.displayValueFor?(row.value)
            }
        }
    }
}

public class TextCell : _FieldCell<String>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func update() {
        super.update()
        textField.autocorrectionType = .Default
        textField.autocapitalizationType = .Sentences
        textField.keyboardType = .Default
    }
}


public class IntCell : _FieldCell<Int>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func update() {
        super.update()
        textField.autocorrectionType = .Default
        textField.autocapitalizationType = .None
        textField.keyboardType = .NumberPad
    }
}

public class PhoneCell : _FieldCell<String>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func update() {
        super.update()
        textField.keyboardType = .PhonePad
    }
}

public class NameCell : _FieldCell<String>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func update() {
        super.update()
        textField.autocorrectionType = .No
        textField.autocapitalizationType = .Words
        textField.keyboardType = .NamePhonePad
    }
}

public class EmailCell : _FieldCell<String>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func update() {
        super.update()
        textField.autocorrectionType = .No
        textField.autocapitalizationType = .None
        textField.keyboardType = .EmailAddress
    }
}

public class PasswordCell : _FieldCell<String>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func update() {
        super.update()
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
    
    public override func update() {
        super.update()
        textField.keyboardType = .DecimalPad
    }
}

public class URLCell : _FieldCell<NSURL>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func update() {
        super.update()
        textField.keyboardType = .URL
    }
    
}

public class TwitterCell : _FieldCell<String>, CellType {

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    public override func update() {
        super.update()
        textField.autocorrectionType = .No
        textField.autocapitalizationType = .None
        textField.keyboardType = .Twitter
    }
}

public class AccountCell : _FieldCell<String>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func update() {
        super.update()
        textField.autocorrectionType = .No
        textField.autocapitalizationType = .None
        textField.keyboardType = .ASCIICapable
    }
}



public class DateCell : Cell<NSDate>, CellType {
    
    lazy public var datePicker : UIDatePicker = {
        return UIDatePicker()
    }()
    
    private var _detailColor : UIColor!
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func setup() {
        super.setup()
        datePicker.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: .ValueChanged)
    }
    
    
    public override func update() {
        super.update()
        setModeToDatePicker(datePicker)
        accessoryType = .None
        editingAccessoryType =  .None
        selectionStyle = row.isDisabled ? .None : .Default
        detailTextLabel?.text = row.displayValueFor?(row.value)
        
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
        detailTextLabel?.text = row.displayValueFor!(row.value!)
        setNeedsLayout()
    }
    
    
    public func setModeToDatePicker(datePicker : UIDatePicker){
        switch row {
            case is DateRow:
                datePicker.datePickerMode = .Date
            case is TimeRow:
                datePicker.datePickerMode = .Time
            case is DateTimeRow:
                datePicker.datePickerMode = .DateAndTime
            case is CountDownRow:
                datePicker.datePickerMode = .CountDownTimer
            default:
                datePicker.datePickerMode = .Date
        }
        
        datePicker.minimumDate = (row as? _DateFieldRow)?.minimumDate
        datePicker.maximumDate = (row as? _DateFieldRow)?.maximumDate
        if let minuteIntervalValue = (row as? _DateFieldRow)?.minuteInterval{
            datePicker.minuteInterval = minuteIntervalValue
        }
    }
    
    public override func cellCanBecomeFirstResponder() -> Bool {
        return canBecomeFirstResponder()
    }
    
    public override func canBecomeFirstResponder() -> Bool {
        return !row.isDisabled;
    }
    
    public override func becomeFirstResponder() -> Bool {
        _detailColor = detailTextLabel?.textColor
        return super.becomeFirstResponder()
    }
    
    public override func highlight() {
        detailTextLabel?.textColor = tintColor
    }
    
    public override func unhighlight() {
        detailTextLabel?.textColor = _detailColor
    }

}

public class _TextAreaCell<T: Equatable> : Cell<T>, UITextViewDelegate {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public lazy var placeholderLabel : UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    public lazy var textView : UITextView = {
        let v = UITextView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private var dynamicConstraints = [NSLayoutConstraint]()
    
    deinit {
        placeholderLabel.removeObserver(self, forKeyPath: "text")
    }
    
    public override func setup() {
        super.setup()
        height = { 110 }
        textView.delegate = self
        textLabel?.text = nil
        textView.font = .preferredFontForTextStyle(UIFontTextStyleBody)
        placeholderLabel.text = (row as? TextAreaProtocol)?.placeholder
        placeholderLabel.numberOfLines = 0
        placeholderLabel.sizeToFit()
        textView.addSubview(placeholderLabel)
        placeholderLabel.font = .systemFontOfSize(textView.font!.pointSize)
        placeholderLabel.textColor = UIColor(white: 0, alpha: 0.22)
        
        selectionStyle = .None
        contentView.addSubview(textView)
        contentView.addSubview(placeholderLabel)
        placeholderLabel.addObserver(self, forKeyPath: "text", options: NSKeyValueObservingOptions.Old.union(.New), context: nil)
        
        let views : [String: AnyObject] =  ["textView": textView, "label": placeholderLabel]
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-8-[label]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[textView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        contentView.addConstraint(NSLayoutConstraint(item: textView, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: textView, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: 0))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[textView]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }
    
    public override func update() {
        super.update()
        placeholderLabel.hidden = textView.text.characters.count != 0
        textView.keyboardType = .Default
        textView.editable = !row.isDisabled
        textView.textColor = row.isDisabled ? .grayColor() : .blackColor()

    }
    
    public override func cellCanBecomeFirstResponder() -> Bool {
        return !row.isDisabled && textView.canBecomeFirstResponder()
    }
    
    public override func cellBecomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }
    
    public func textViewDidChange(textView: UITextView) {
        placeholderLabel.hidden = textView.text.characters.count != 0
        row.value = textView.text as? T
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let obj = object, let keyPathValue = keyPath, let changeType = change?[NSKeyValueChangeKindKey]{
            if (obj === placeholderLabel && keyPathValue == "text"){
                if changeType.unsignedLongValue == NSKeyValueChange.Setting.rawValue{
                    contentView.setNeedsUpdateConstraints()
                }
            }
        }
    }

}

public class TextAreaCell : _TextAreaCell<String>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func update() {
        super.update()
        textView.text = row.value
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
    private var dynamicConstraints : [NSLayoutConstraint]?
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        dynamicConstraints = nil
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    deinit {
        titleLabel?.removeObserver(self, forKeyPath: "text")
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .None
        contentView.addSubview(titleLabel!)
        contentView.addSubview(segmentedControl)
        titleLabel?.addObserver(self, forKeyPath: "text", options: NSKeyValueObservingOptions.Old.union(.New), context: nil)
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
        if let obj = object, let changeType = change, let _ = keyPath {
            if obj === titleLabel && keyPath == "text" && changeType[NSKeyValueChangeKindKey]?.unsignedLongValue == NSKeyValueChange.Setting.rawValue{
                contentView.setNeedsUpdateConstraints()
            }
        }
    }
    
    func updateSegmentedControl() {
        segmentedControl.removeAllSegments()
        for item in items().enumerate() {
            segmentedControl.insertSegmentWithTitle(item.element, atIndex: item.index, animated: false)
        }
    }
    
    public override func updateConstraints() {
        if let dynConst = dynamicConstraints {
            contentView .removeConstraints(dynConst)
        }
        dynamicConstraints = []
        var views : [String: AnyObject] =  ["segmentedControl": segmentedControl]
        if (titleLabel?.text?.isEmpty == false) {
            views["titleLabel"] = titleLabel
            dynamicConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[titleLabel]-16-[segmentedControl]-|", options: .AlignAllCenterY, metrics: nil, views: views)
            dynamicConstraints?.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-12-[titleLabel]-12-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        }
        else{
            dynamicConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[segmentedControl]-|", options: .AlignAllCenterY, metrics: nil, views: views)
        }
        contentView.addConstraints(dynamicConstraints!)
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


