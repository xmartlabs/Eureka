//
//  PhoneFormatter.swift
//  Eureka
//
//  Created by Paige Sun on 5/8/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

public class PhoneFormatter : NSFormatter, FormatterProtocol {
    
    override public func getObjectValue(obj: AutoreleasingUnsafeMutablePointer<AnyObject?>, forString string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>) -> Bool {
        guard obj != nil else { return false }
        let str = string.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("")
        obj.memory = str
        return true
    }
    
    override public func stringForObjectValue(obj: AnyObject) -> String? {
        if (obj is String) {
            let oldString = (obj as! String)
            return getNewFormattedString(oldString)
        } else {
            return nil
        }
    }
    
    public func getNewPosition(forPosition position: UITextPosition, inTextInput textInput: UITextInput, oldValue: String?, newValue: String?) -> UITextPosition {
      
        let offset = ((newValue?.characters.count ?? 0) - (oldValue?.characters.count ?? 0))
        return textInput.positionFromPosition(position, offset: offset) ?? position
    }
    
    private func getNewFormattedString (oldString: String) -> String {
        
        let oldString = oldString as NSString
        let length = oldString.length
        let formattedString = NSMutableString()
        var index = 0 as Int
        
        let hasLeadingOne = oldString.hasPrefix("1")
        if hasLeadingOne
        {
            formattedString.appendString("1 ")
            index += 1
        }
        
        if (length - index) > 2
        {
            let areaCode = oldString.substringWithRange(NSMakeRange(index, 3))
            formattedString.appendFormat("(%@) ", areaCode)
            index += 3
        }
        if length - index > 2
        {
            let prefix = oldString.substringWithRange(NSMakeRange(index, 3))
            formattedString.appendFormat("%@-", prefix)
            index += 3
        }
        let remainder = oldString.substringFromIndex(index)
        formattedString.appendString(remainder)
        
        return formattedString as String
    }
    
}