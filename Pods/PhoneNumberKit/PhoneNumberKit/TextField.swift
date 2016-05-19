//
//  TextField.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 07/11/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation
import UIKit

/// Custom text field that formats phone numbers
public class PhoneNumberTextField: UITextField, UITextFieldDelegate {
    
    /// Override region to set a custom region. Automatically uses the default region code.
    public var defaultRegion = PhoneNumberKit().defaultRegionCode() {
        didSet {
            partialFormatter.defaultRegion = defaultRegion
        }
    }
    
    public var withPrefix: Bool = true {
        didSet {
            partialFormatter.withPrefix = withPrefix
            if withPrefix == false {
                self.keyboardType = UIKeyboardType.NumberPad
            }
            else {
                self.keyboardType = UIKeyboardType.PhonePad
            }
        }
    }

    
    var partialFormatter = PartialFormatter()
    
    let nonNumericSet: NSCharacterSet = {
        var mutableSet = NSCharacterSet.decimalDigitCharacterSet().invertedSet.mutableCopy() as! NSMutableCharacterSet
        mutableSet.removeCharactersInString(PhoneNumberConstants.plusChars)
        return mutableSet
    }()
    
    weak private var _delegate: UITextFieldDelegate?
    
    override public var delegate: UITextFieldDelegate? {
        get {
            return _delegate
        }
        set {
            self._delegate = newValue
        }
    }
    
    //MARK: Status

    public var currentRegion: String {
        get {
            return partialFormatter.currentRegion
        }
    }
    public var isValidNumber: Bool {
        get {
            let rawNumber = self.text ?? String()
            do {
                let phoneNumber = try PhoneNumber(rawNumber: rawNumber)
                return phoneNumber.isValidNumber
            } catch {
                return false
            }
        }
    }
    
     //MARK: Lifecycle
    
    /**
    Init with frame
    
    - parameter frame: UITextfield F
    
    - returns: UITextfield
    */
    override public init(frame:CGRect)
    {
        super.init(frame:frame)
        self.setup()
    }
    
     /**
     Init with coder
     
     - parameter aDecoder: decoder
     
     - returns: UITextfield
     */
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setup()
    }
    
    func setup(){
        self.autocorrectionType = .No
        self.keyboardType = UIKeyboardType.PhonePad
        super.delegate = self
    }

    
    // MARK: Phone number formatting
    
    /**
    *  To keep the cursor position, we find the character immediately after the cursor and count the number of times it repeats in the remaining string as this will remain constant in every kind of editing.
    */
    
    internal struct CursorPosition {
        let numberAfterCursor: String
        let repetitionCountFromEnd: Int
    }
    
    internal func extractCursorPosition() -> CursorPosition? {
        var repetitionCountFromEnd = 0
        // Check that there is text in the UITextField
        guard let text = text, let selectedTextRange = selectedTextRange else {
            return nil
        }
        let textAsNSString = text as NSString
        let cursorEnd = offsetFromPosition(beginningOfDocument, toPosition: selectedTextRange.end)
        // Look for the next valid number after the cursor, when found return a CursorPosition struct
        for i in cursorEnd ..< textAsNSString.length  {
            let cursorRange = NSMakeRange(i, 1)
            let candidateNumberAfterCursor: NSString = textAsNSString.substringWithRange(cursorRange)
            if (candidateNumberAfterCursor.rangeOfCharacterFromSet(nonNumericSet).location == NSNotFound) {
                for j in cursorRange.location ..< textAsNSString.length  {
                    let candidateCharacter = textAsNSString.substringWithRange(NSMakeRange(j, 1))
                    if candidateCharacter == candidateNumberAfterCursor {
                        repetitionCountFromEnd += 1
                    }
                }
                return CursorPosition(numberAfterCursor: candidateNumberAfterCursor as String, repetitionCountFromEnd: repetitionCountFromEnd)
            }
        }
        return nil
    }
    
    // Finds position of previous cursor in new formatted text
    internal func selectionRangeForNumberReplacement(textField: UITextField, formattedText: String) -> NSRange? {
        let textAsNSString = formattedText as NSString
        var countFromEnd = 0
        guard let cursorPosition = extractCursorPosition() else {
            return nil
        }
        
        for i in (textAsNSString.length - 1).stride(through: 0, by: -1) {
            let candidateRange = NSMakeRange(i, 1)
            let candidateCharacter = textAsNSString.substringWithRange(candidateRange)
            if candidateCharacter == cursorPosition.numberAfterCursor {
                countFromEnd += 1
                if countFromEnd == cursorPosition.repetitionCountFromEnd {
                    return candidateRange
                }
            }
        }

        return nil
    }
    
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = text else {
            return false
        }

        // allow delegate to intervene
        guard _delegate?.textField?(textField, shouldChangeCharactersInRange: range, replacementString: string) ?? true else {
            return false
        }

        let textAsNSString = text as NSString
        let changedRange = textAsNSString.substringWithRange(range) as NSString
        let modifiedTextField = textAsNSString.stringByReplacingCharactersInRange(range, withString: string)
        let formattedNationalNumber = partialFormatter.formatPartial(modifiedTextField as String)
        var selectedTextRange: NSRange?
        
        let nonNumericRange = (changedRange.rangeOfCharacterFromSet(nonNumericSet).location != NSNotFound)
        if (range.length == 1 && string.isEmpty && nonNumericRange)
        {
            selectedTextRange = selectionRangeForNumberReplacement(textField, formattedText: modifiedTextField)
            textField.text = modifiedTextField
        }
        else {
            selectedTextRange = selectionRangeForNumberReplacement(textField, formattedText: formattedNationalNumber)
            textField.text = formattedNationalNumber
        }
        sendActionsForControlEvents(.EditingChanged)
        if let selectedTextRange = selectedTextRange, let selectionRangePosition = textField.positionFromPosition(beginningOfDocument, offset: selectedTextRange.location) {
            let selectionRange = textField.textRangeFromPosition(selectionRangePosition, toPosition: selectionRangePosition)
            textField.selectedTextRange = selectionRange
        }

        return false
    }
    
    //MARK: UITextfield Delegate
    
    public func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return _delegate?.textFieldShouldBeginEditing?(textField) ?? true
    }
    
    public func textFieldDidBeginEditing(textField: UITextField) {
        _delegate?.textFieldDidBeginEditing?(textField)
    }
    
    public func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return _delegate?.textFieldShouldEndEditing?(textField) ?? true
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
        _delegate?.textFieldDidEndEditing?(textField)
    }
    
    public func textFieldShouldClear(textField: UITextField) -> Bool {
        return _delegate?.textFieldShouldClear?(textField) ?? true
    }
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        return _delegate?.textFieldShouldReturn?(textField) ?? true
    }
}