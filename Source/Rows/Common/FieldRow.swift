//  FieldRow.swift
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

public protocol InputTypeInitiable {
    init?(string stringValue: String)
}

public protocol FieldRowConformance : FormatterConformance {
    var textFieldPercentage : CGFloat? { get set }
    var placeholder : String? { get set }
    var placeholderColor : UIColor? { get set }
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
extension URL: InputTypeInitiable {}
extension Double: InputTypeInitiable {
    public init?(string stringValue: String){
        self.init(stringValue)
    }
}


public class FormatteableRow<Cell: CellType where Cell: BaseCell, Cell: TextInputCell>: Row<Cell>, FormatterConformance {
    
    
    /// A formatter to be used to format the user's input
    public var formatter: Formatter?
    
    /// If the formatter should be used while the user is editing the text.
    public var useFormatterDuringInput = false
    public var useFormatterOnDidBeginEditing: Bool?
    
    public required init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = { [unowned self] value in
            guard let v = value else { return nil }
            guard let formatter = self.formatter else { return String(v) }
            if (self.cell.textInput as? UIView)?.isFirstResponder() == true {
                return self.useFormatterDuringInput ? formatter.editingString(for: v as! AnyObject) : String(v)
            }
            return formatter.string(for: v as? AnyObject)
        }
    }

}


public class FieldRow<Cell: CellType where Cell: BaseCell, Cell: TextFieldCell>: FormatteableRow<Cell>, FieldRowConformance, KeyboardReturnHandler {
    
    /// Configuration for the keyboardReturnType of this row
    public var keyboardReturnType : KeyboardReturnTypeConfiguration?
    
    /// The percentage of the cell that should be occupied by the textField
    public var textFieldPercentage : CGFloat?
    
    /// The placeholder for the textField
    public var placeholder : String?
    
    /// The textColor for the textField's placeholder
    public var placeholderColor : UIColor?
    
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

/**
 *  Protocol for cells that contain a UITextField
 */
public protocol TextInputCell {
    var textInput : UITextInput { get }
}

public protocol TextFieldCell: TextInputCell {
    
    var textField: UITextField { get }
}

extension TextFieldCell {
    
    public var textInput: UITextInput {
        return textField
    }
}

public class _FieldCell<T where T: Equatable, T: InputTypeInitiable> : Cell<T>, UITextFieldDelegate, TextFieldCell {
    
    lazy public var textField : UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    public var titleLabel : UILabel? {
        textLabel?.translatesAutoresizingMaskIntoConstraints = false
        textLabel?.setContentHuggingPriority(500, for: .horizontal)
        textLabel?.setContentCompressionResistancePriority(1000, for: .horizontal)
        return textLabel
    }
    
    public var dynamicConstraints = [NSLayoutConstraint]()
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        textField.delegate = nil
        textField.removeTarget(self, action: nil, for: .allEvents)
        titleLabel?.removeObserver(self, forKeyPath: "text")
        imageView?.removeObserver(self, forKeyPath: "image")
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        contentView.addSubview(titleLabel!)
        contentView.addSubview(textField)
        
        titleLabel?.addObserver(self, forKeyPath: "text", options: NSKeyValueObservingOptions.old.union(.new), context: nil)
        imageView?.addObserver(self, forKeyPath: "image", options: NSKeyValueObservingOptions.old.union(.new), context: nil)
        textField.addTarget(self, action: #selector(_FieldCell.textFieldDidChange(_:)), for: .editingChanged)
        
    }
    
    public override func update() {
        super.update()
        detailTextLabel?.text = nil
        if let title = row.title {
            textField.textAlignment = title.isEmpty ? .left : .right
            textField.clearButtonMode = title.isEmpty ? .whileEditing : .never
        }
        else{
            textField.textAlignment =  .left
            textField.clearButtonMode =  .whileEditing
        }
        textField.delegate = self
        textField.text = row.displayValueFor?(row.value)
        textField.isEnabled = !row.isDisabled
        textField.textColor = row.isDisabled ? .gray() : .black()
        textField.font = .preferredFont(forTextStyle: UIFontTextStyleBody)
        if let placeholder = (row as? FieldRowConformance)?.placeholder {
            if let color = (row as? FieldRowConformance)?.placeholderColor {
                textField.attributedPlaceholder = AttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: color])
            }
            else{
                textField.placeholder = (row as? FieldRowConformance)?.placeholder
            }
        }
    }
    
    public override func cellCanBecomeFirstResponder() -> Bool {
        return !row.isDisabled && textField.canBecomeFirstResponder()
    }
    
    public override func cellBecomeFirstResponder(_ direction: Direction) -> Bool {
        return textField.becomeFirstResponder()
    }
    
    public override func cellResignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: AnyObject?, change: [NSKeyValueChangeKey : AnyObject]?, context: UnsafeMutablePointer<Void>?) {
        if let obj = object, let keyPathValue = keyPath, let changeType = change?[NSKeyValueChangeKey.kindKey] where ((obj === titleLabel && keyPathValue == "text") || (obj === imageView && keyPathValue == "image")) && changeType.uintValue == NSKeyValueChange.setting.rawValue {
            setNeedsUpdateConstraints()
            updateConstraintsIfNeeded()
        }
    }
    
    // Mark: Helpers
    
    public func customConstraints() {
        contentView.removeConstraints(dynamicConstraints)
        dynamicConstraints = []
        var views : [String: AnyObject] =  ["textField": textField]
        dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-11-[textField]-11-|", options: .alignAllLastBaseline, metrics: nil, views: ["textField": textField])
        
        if let label = titleLabel, let text = label.text where !text.isEmpty {
            dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-11-[titleLabel]-11-|", options: .alignAllLastBaseline, metrics: nil, views: ["titleLabel": label])
            dynamicConstraints.append(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: textField, attribute: .centerY, multiplier: 1, constant: 0))
        }
        if let imageView = imageView, let _ = imageView.image {
            views["imageView"] = imageView
            if let titleLabel = titleLabel, text = titleLabel.text where !text.isEmpty {
                views["label"] = titleLabel
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[imageView]-[label]-[textField]-|", options: NSLayoutFormatOptions(), metrics: nil, views: views)
                dynamicConstraints.append(NSLayoutConstraint(item: textField, attribute: .width, relatedBy: (row as? FieldRowConformance)?.textFieldPercentage != nil ? .equal : .greaterThanOrEqual, toItem: contentView, attribute: .width, multiplier: (row as? FieldRowConformance)?.textFieldPercentage ?? 0.3, constant: 0.0))
            }
            else{
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[imageView]-[textField]-|", options: [], metrics: nil, views: views)
            }
        }
        else{
            if let titleLabel = titleLabel, let text = titleLabel.text where !text.isEmpty {
                views["label"] = titleLabel
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-[textField]-|", options: [], metrics: nil, views: views)
                dynamicConstraints.append(NSLayoutConstraint(item: textField, attribute: .width, relatedBy: (row as? FieldRowConformance)?.textFieldPercentage != nil ? .equal : .greaterThanOrEqual, toItem: contentView, attribute: .width, multiplier: (row as? FieldRowConformance)?.textFieldPercentage ?? 0.3, constant: 0.0))
            }
            else{
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[textField]-|", options: .alignAllLeft, metrics: nil, views: views)
            }
        }
        contentView.addConstraints(dynamicConstraints)
    }
    
    public override func updateConstraints(){
        customConstraints()
        super.updateConstraints()
    }
    
    public func textFieldDidChange(_ textField : UITextField){
        
        guard let textValue = textField.text else {
            row.value = nil
            return
        }
        guard let fieldRow = row as? FieldRowConformance, let formatter = fieldRow.formatter else {
            row.value = textValue.isEmpty ? nil : (T.init(string: textValue) ?? row.value)
            return
        }
        if fieldRow.useFormatterDuringInput {
            let value: AutoreleasingUnsafeMutablePointer<AnyObject?> = AutoreleasingUnsafeMutablePointer<AnyObject?>.init(UnsafeMutablePointer<T>(allocatingCapacity: 1))
            let errorDesc: AutoreleasingUnsafeMutablePointer<NSString?>? = nil
            if formatter.getObjectValue(value, for: textValue, errorDescription: errorDesc) {
                row.value = value.pointee as? T
                guard var selStartPos = textField.selectedTextRange?.start else { return }
                let oldVal = textField.text
                textField.text = row.displayValueFor?(row.value)
                selStartPos = (formatter as? FormatterProtocol)?.getNewPosition(forPosition: selStartPos, inTextInput: textField, oldValue: oldVal, newValue: textField.text) ?? selStartPos
                textField.selectedTextRange = textField.textRange(from: selStartPos, to: selStartPos)
                return
            }
        }
        else {
            let value: AutoreleasingUnsafeMutablePointer<AnyObject?> = AutoreleasingUnsafeMutablePointer<AnyObject?>.init(UnsafeMutablePointer<T>(allocatingCapacity: 1))
            let errorDesc: AutoreleasingUnsafeMutablePointer<NSString?>? = nil
            if formatter.getObjectValue(value, for: textValue, errorDescription: errorDesc) {
                row.value = value.pointee as? T
            }
        }
    }
    
    //Mark: Helpers
    
    private func displayValue(useFormatter: Bool) -> String? {
        guard let v = row.value else { return nil }
        if let formatter = (row as? FormatterConformance)?.formatter where useFormatter {
            return textField.isFirstResponder() ? formatter.editingString(for: v as! AnyObject) : formatter.string(for: v as? AnyObject)
        }
        return String(v)
    }
    
    //MARK: TextFieldDelegate
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        formViewController()?.beginEditing(self)
        formViewController()?.textInputDidBeginEditing(textField, cell: self)
        if let fieldRowConformance = row as? FormatterConformance, let _ = fieldRowConformance.formatter where fieldRowConformance.useFormatterOnDidBeginEditing ?? fieldRowConformance.useFormatterDuringInput {
            textField.text = displayValue(useFormatter: true)
        } else {
            textField.text = displayValue(useFormatter: false)
        }
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        formViewController()?.endEditing(self)
        formViewController()?.textInputDidEndEditing(textField, cell: self)
        textFieldDidChange(textField)
        textField.text = displayValue(useFormatter: (row as? FormatterConformance)?.formatter != nil)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldReturn(textField, cell: self) ?? true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return formViewController()?.textInput(textField, shouldChangeCharactersInRange:range, replacementString:string, cell: self) ?? true
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldBeginEditing(textField, cell: self) ?? true
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldClear(textField, cell: self) ?? true
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldEndEditing(textField, cell: self) ?? true
    }
    
    
}
