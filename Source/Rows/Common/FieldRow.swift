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

public protocol FieldRowConformance: FormatterConformance {
    var textFieldPercentage: CGFloat? { get set }
    var placeholder: String? { get set }
    var placeholderColor: UIColor? { get set }
}

extension Int: InputTypeInitiable {

    public init?(string stringValue: String) {
        self.init(stringValue, radix: 10)
    }
}
extension Float: InputTypeInitiable {
    public init?(string stringValue: String) {
        self.init(stringValue)
    }
}
extension String: InputTypeInitiable {
    public init?(string stringValue: String) {
        self.init(stringValue)
    }
}
extension URL: InputTypeInitiable {}
extension Double: InputTypeInitiable {
    public init?(string stringValue: String) {
        self.init(stringValue)
    }
}

open class FormatteableRow<Cell: CellType>: Row<Cell>, FormatterConformance where Cell: BaseCell, Cell: TextInputCell {

    /// A formatter to be used to format the user's input
    open var formatter: Formatter?

    /// If the formatter should be used while the user is editing the text.
    open var useFormatterDuringInput = false
    open var useFormatterOnDidBeginEditing: Bool?

    public required init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = { [unowned self] value in
            guard let v = value else { return nil }
            guard let formatter = self.formatter else { return String(describing: v) }
            if (self.cell.textInput as? UIView)?.isFirstResponder == true {
                return self.useFormatterDuringInput ? formatter.editingString(for: v) : String(describing: v)
            }
            return formatter.string(for: v)
        }
    }

}

open class FieldRow<Cell: CellType>: FormatteableRow<Cell>, FieldRowConformance, KeyboardReturnHandler where Cell: BaseCell, Cell: TextFieldCell {

    /// Configuration for the keyboardReturnType of this row
    open var keyboardReturnType: KeyboardReturnTypeConfiguration?

    /// The percentage of the cell that should be occupied by the textField
    open var textFieldPercentage: CGFloat?

    /// The placeholder for the textField
    open var placeholder: String?

    /// The textColor for the textField's placeholder
    open var placeholderColor: UIColor?

    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

/**
 *  Protocol for cells that contain a UITextField
 */
public protocol TextInputCell {
    var textInput: UITextInput { get }
}

public protocol TextFieldCell: TextInputCell {
    var textField: UITextField! { get }
}

extension TextFieldCell {

    public var textInput: UITextInput {
        return textField
    }
}

open class _FieldCell<T> : Cell<T>, UITextFieldDelegate, TextFieldCell where T: Equatable, T: InputTypeInitiable {

    @IBOutlet public weak var textField: UITextField!
    @IBOutlet public weak var titleLabel: UILabel?

    fileprivate var observingTitleText = false
    private var awakeFromNibCalled = false

    open var dynamicConstraints = [NSLayoutConstraint]()

    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {

        let textField = UITextField()
        self.textField = textField
        textField.translatesAutoresizingMaskIntoConstraints = false

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        titleLabel = self.textLabel
        titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.setContentHuggingPriority(500, for: .horizontal)
        titleLabel?.setContentCompressionResistancePriority(1000, for: .horizontal)

        contentView.addSubview(titleLabel!)
        contentView.addSubview(textField)

        NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationWillResignActive, object: nil, queue: nil) { [weak self] _ in
            guard let me = self else { return }
            guard me.observingTitleText else { return }
            me.titleLabel?.removeObserver(me, forKeyPath: "text")
            me.observingTitleText = false
        }
        NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationDidBecomeActive, object: nil, queue: nil) { [weak self] _ in
            guard let me = self else { return }
            guard !me.observingTitleText else { return }
            me.titleLabel?.addObserver(me, forKeyPath: "text", options: NSKeyValueObservingOptions.old.union(.new), context: nil)
            me.observingTitleText = true
        }

        NotificationCenter.default.addObserver(forName: Notification.Name.UIContentSizeCategoryDidChange, object: nil, queue: nil) { [weak self] _ in
            self?.setNeedsUpdateConstraints()
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        awakeFromNibCalled = true
    }

    deinit {
        textField?.delegate = nil
        textField?.removeTarget(self, action: nil, for: .allEvents)
        guard !awakeFromNibCalled else { return }
        if observingTitleText {
            titleLabel?.removeObserver(self, forKeyPath: "text")
        }
        imageView?.removeObserver(self, forKeyPath: "image")
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
    }

    open override func setup() {
        super.setup()
        selectionStyle = .none

        if !awakeFromNibCalled {
            titleLabel?.addObserver(self, forKeyPath: "text", options: NSKeyValueObservingOptions.old.union(.new), context: nil)
            observingTitleText = true
            imageView?.addObserver(self, forKeyPath: "image", options: NSKeyValueObservingOptions.old.union(.new), context: nil)
        }
        textField.addTarget(self, action: #selector(_FieldCell.textFieldDidChange(_:)), for: .editingChanged)

    }

    open override func update() {
        super.update()
        detailTextLabel?.text = nil

        if !awakeFromNibCalled {
            if let title = row.title {
                textField.textAlignment = title.isEmpty ? .left : .right
                textField.clearButtonMode = title.isEmpty ? .whileEditing : .never
            } else {
                textField.textAlignment =  .left
                textField.clearButtonMode =  .whileEditing
            }
        }
        textField.delegate = self
        textField.text = row.displayValueFor?(row.value)
        textField.isEnabled = !row.isDisabled
        textField.textColor = row.isDisabled ? .gray : .black
        textField.font = .preferredFont(forTextStyle: .body)
        if let placeholder = (row as? FieldRowConformance)?.placeholder {
            if let color = (row as? FieldRowConformance)?.placeholderColor {
                textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: color])
            } else {
                textField.placeholder = (row as? FieldRowConformance)?.placeholder
            }
        }
        if row.isHighlighted {
            textLabel?.textColor = tintColor
        }
    }

    open override func cellCanBecomeFirstResponder() -> Bool {
        return !row.isDisabled && textField?.canBecomeFirstResponder == true
    }

    open override func cellBecomeFirstResponder(withDirection: Direction) -> Bool {
        return textField?.becomeFirstResponder() ?? false
    }

    open override func cellResignFirstResponder() -> Bool {
        return textField?.resignFirstResponder() ?? true
    }

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let obj = object as AnyObject?

        if let keyPathValue = keyPath, let changeType = change?[NSKeyValueChangeKey.kindKey],
            ((obj === titleLabel && keyPathValue == "text") || (obj === imageView && keyPathValue == "image")) &&
                (changeType as? NSNumber)?.uintValue == NSKeyValueChange.setting.rawValue {
            setNeedsUpdateConstraints()
            updateConstraintsIfNeeded()
        }
    }

    // MARK: Helpers

    open func customConstraints() {

        guard !awakeFromNibCalled else { return }
        contentView.removeConstraints(dynamicConstraints)
        dynamicConstraints = []
        var views: [String: AnyObject] =  ["textField": textField]
        dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-11-[textField]-11-|", options: .alignAllLastBaseline, metrics: nil, views: views)

        if let label = titleLabel, let text = label.text, !text.isEmpty {
            dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-11-[titleLabel]-11-|", options: .alignAllLastBaseline, metrics: nil, views: ["titleLabel": label])
            dynamicConstraints.append(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: textField, attribute: .centerY, multiplier: 1, constant: 0))
        }
        if let imageView = imageView, let _ = imageView.image {
            views["imageView"] = imageView
            if let titleLabel = titleLabel, let text = titleLabel.text, !text.isEmpty {
                views["label"] = titleLabel
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[imageView]-(15)-[label]-[textField]-|", options: NSLayoutFormatOptions(), metrics: nil, views: views)
                dynamicConstraints.append(NSLayoutConstraint(item: textField,
                                                             attribute: .width,
                                                             relatedBy: (row as? FieldRowConformance)?.textFieldPercentage != nil ? .equal : .greaterThanOrEqual,
                                                             toItem: contentView,
                                                             attribute: .width,
                                                             multiplier: (row as? FieldRowConformance)?.textFieldPercentage ?? 0.3,
                                                             constant: 0.0))
            } else {
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[imageView]-(15)-[textField]-|", options: [], metrics: nil, views: views)
            }
        } else {
            if let titleLabel = titleLabel, let text = titleLabel.text, !text.isEmpty {
                views["label"] = titleLabel
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-[textField]-|", options: [], metrics: nil, views: views)
                dynamicConstraints.append(NSLayoutConstraint(item: textField,
                                                             attribute: .width,
                                                             relatedBy: (row as? FieldRowConformance)?.textFieldPercentage != nil ? .equal : .greaterThanOrEqual,
                                                             toItem: contentView,
                                                             attribute: .width,
                                                             multiplier: (row as? FieldRowConformance)?.textFieldPercentage ?? 0.3,
                                                             constant: 0.0))
            } else {
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[textField]-|", options: .alignAllLeft, metrics: nil, views: views)
            }
        }
        contentView.addConstraints(dynamicConstraints)
    }

    open override func updateConstraints() {
        customConstraints()
        super.updateConstraints()
    }

    open func textFieldDidChange(_ textField: UITextField) {

        guard let textValue = textField.text else {
            row.value = nil
            return
        }
        guard let fieldRow = row as? FieldRowConformance, let formatter = fieldRow.formatter else {
            row.value = textValue.isEmpty ? nil : (T.init(string: textValue) ?? row.value)
            return
        }
        if fieldRow.useFormatterDuringInput {
            let value: AutoreleasingUnsafeMutablePointer<AnyObject?> = AutoreleasingUnsafeMutablePointer<AnyObject?>.init(UnsafeMutablePointer<T>.allocate(capacity: 1))
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
        } else {
            let value: AutoreleasingUnsafeMutablePointer<AnyObject?> = AutoreleasingUnsafeMutablePointer<AnyObject?>.init(UnsafeMutablePointer<T>.allocate(capacity: 1))
            let errorDesc: AutoreleasingUnsafeMutablePointer<NSString?>? = nil
            if formatter.getObjectValue(value, for: textValue, errorDescription: errorDesc) {
                row.value = value.pointee as? T
            } else {
                row.value = textValue.isEmpty ? nil : (T.init(string: textValue) ?? row.value)
            }
        }
    }

    // MARK: Helpers

    private func displayValue(useFormatter: Bool) -> String? {
        guard let v = row.value else { return nil }
        if let formatter = (row as? FormatterConformance)?.formatter, useFormatter {
            return textField?.isFirstResponder == true ? formatter.editingString(for: v) : formatter.string(for: v)
        }
        return String(describing: v)
    }

    // MARK: TextFieldDelegate

    open func textFieldDidBeginEditing(_ textField: UITextField) {
        formViewController()?.beginEditing(of: self)
        formViewController()?.textInputDidBeginEditing(textField, cell: self)
        if let fieldRowConformance = row as? FormatterConformance, let _ = fieldRowConformance.formatter, fieldRowConformance.useFormatterOnDidBeginEditing ?? fieldRowConformance.useFormatterDuringInput {
            textField.text = displayValue(useFormatter: true)
        } else {
            textField.text = displayValue(useFormatter: false)
        }
    }

    open func textFieldDidEndEditing(_ textField: UITextField) {
        formViewController()?.endEditing(of: self)
        formViewController()?.textInputDidEndEditing(textField, cell: self)
        textFieldDidChange(textField)
        textField.text = displayValue(useFormatter: (row as? FormatterConformance)?.formatter != nil)
    }

    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldReturn(textField, cell: self) ?? true
    }

    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return formViewController()?.textInput(textField, shouldChangeCharactersInRange:range, replacementString:string, cell: self) ?? true
    }

    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldBeginEditing(textField, cell: self) ?? true
    }

    open func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldClear(textField, cell: self) ?? true
    }

    open func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldEndEditing(textField, cell: self) ?? true
    }

}
