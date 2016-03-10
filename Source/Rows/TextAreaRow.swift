//
//  AlertRow.swift
//  Eureka
//
//  Created by Martin Barreto on 2/23/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

protocol TextAreaConformance : FormatterConformance {
    var placeholder : String? { get set }
}


/**
 *  Protocol for cells that contain a UITextView
 */
public protocol AreaCell {
    var textView: UITextView { get }
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
        
        imageView?.addObserver(self, forKeyPath: "image", options: NSKeyValueObservingOptions.Old.union(.New), context: nil)
        
        let views : [String: AnyObject] =  ["textView": textView, "label": placeholderLabel]
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[label]", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[textView]-|", options: [], metrics: nil, views: views))
    }
    
    deinit {
        textView.delegate = nil
        imageView?.removeObserver(self, forKeyPath: "image")
        
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
    
    public override func cellBecomeFirstResponder(fromDiretion: Direction) -> Bool {
        return textView.becomeFirstResponder()
    }
    
    public override func cellResignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let obj = object, let keyPathValue = keyPath, let changeType = change?[NSKeyValueChangeKindKey] where obj === imageView && keyPathValue == "image" && changeType.unsignedLongValue == NSKeyValueChange.Setting.rawValue {
            setNeedsUpdateConstraints()
            updateConstraintsIfNeeded()
        }
    }
    
    //Mark: Helpers
    
    private func displayValue(useFormatter useFormatter: Bool) -> String? {
        guard let v = row.value else { return nil }
        if let formatter = (row as? FormatterConformance)?.formatter where useFormatter {
            return textView.isFirstResponder() ? formatter.editingStringForObjectValue(v as! AnyObject) : formatter.stringForObjectValue(v as! AnyObject)
        }
        return String(v)
    }
    
    //MARK: TextFieldDelegate
    
    
    public func textViewDidBeginEditing(textView: UITextView) {
        formViewController()?.beginEditing(self)
        formViewController()?.textInputDidBeginEditing(textView, cell: self)
        if let textAreaConformance = (row as? TextAreaConformance), let _ = textAreaConformance.formatter where textAreaConformance.useFormatterOnDidBeginEditing ?? textAreaConformance.useFormatterDuringInput {
            textView.text = self.displayValue(useFormatter: true)
        }
        else {
            textView.text = self.displayValue(useFormatter: false)
        }
    }
    
    public func textViewDidEndEditing(textView: UITextView) {
        formViewController()?.endEditing(self)
        formViewController()?.textInputDidEndEditing(textView, cell: self)
        textViewDidChange(textView)
        textView.text = displayValue(useFormatter: (row as? FormatterConformance)?.formatter != nil)
    }
    
    public func textViewDidChange(textView: UITextView) {
        placeholderLabel.hidden = textView.text.characters.count != 0
        guard let textValue = textView.text else {
            row.value = nil
            return
        }
        if let fieldRow = row as? FieldRowConformance, let formatter = fieldRow.formatter {
            if fieldRow.useFormatterDuringInput {
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
            else {
                let value: AutoreleasingUnsafeMutablePointer<AnyObject?> = AutoreleasingUnsafeMutablePointer<AnyObject?>.init(UnsafeMutablePointer<T>.alloc(1))
                let errorDesc: AutoreleasingUnsafeMutablePointer<NSString?> = nil
                if formatter.getObjectValue(value, forString: textValue, errorDescription: errorDesc) {
                    row.value = value.memory as? T
                }
                return
            }
        }
        guard !textValue.isEmpty else {
            row.value = nil
            return
        }
        guard let newValue = T.init(string: textValue) else {
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
    
    public override func updateConstraints(){
        contentView.removeConstraints(dynamicConstraints)
        dynamicConstraints = []
        var views : [String: AnyObject] = ["textView": textView, "label": placeholderLabel]
        if let imageView = imageView, let _ = imageView.image {
            views["imageView"] = imageView
            dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:[imageView]-[textView]-|", options: [], metrics: nil, views: views)
            dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:[imageView]-[label]-|", options: [], metrics: nil, views: views)
        }
        else{
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[textView]-|", options: [], metrics: nil, views: views))
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label]-|", options: [], metrics: nil, views: views))
        }
        contentView.addConstraints(dynamicConstraints)
        super.updateConstraints()
    }
    
}

public class TextAreaCell : _TextAreaCell<String>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
}

public class AreaRow<T: Equatable, Cell: CellType where Cell: BaseCell, Cell: TypedCellType, Cell: AreaCell, Cell.Value == T>: Row<T, Cell>, TextAreaConformance {
    
    public var placeholder : String?
    public var formatter: NSFormatter?
    public var useFormatterDuringInput = false
    public var useFormatterOnDidBeginEditing: Bool?
    
    public required init(tag: String?) {
        super.init(tag: tag)
        self.displayValueFor = { [unowned self] value in
            guard let v = value else { return nil }
            if let formatter = self.formatter {
                if self.cell.textView.isFirstResponder(){
                    return self.useFormatterDuringInput ? formatter.editingStringForObjectValue(v as! AnyObject) : String(v)
                }
                return formatter.stringForObjectValue(v as! AnyObject)
            }
            return String(v)
        }
    }
}

public class _TextAreaRow: AreaRow<String, TextAreaCell> {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A row with a UITextView where the user can enter large text.
public final class TextAreaRow: _TextAreaRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}


