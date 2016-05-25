//
//  Formatter.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 03/11/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

class Formatter {
    
    // MARK: Formatting functions
    let regex = RegularExpressions.sharedInstance
    
    /**
     Formats phone numbers for display
     - Parameter phoneNumber: Phone number object.
     - Returns: Modified national number ready for display.
     */
    func formatPhoneNumber(phoneNumber: PhoneNumber, formatType: PhoneNumberFormat) -> String {
        let metadata = Metadata.sharedInstance
        var formattedNationalNumber = phoneNumber.adjustedNationalNumber()
        if let regionMetadata = metadata.metadataPerCode[phoneNumber.countryCode] {
            formattedNationalNumber = formatNationalNumber(formattedNationalNumber, regionMetadata: regionMetadata, formatType: formatType)
            if let formattedExtension = formatExtension(phoneNumber.numberExtension, regionMetadata: regionMetadata) {
                formattedNationalNumber = formattedNationalNumber + formattedExtension
            }
        }
        return formattedNationalNumber
    }

    
    /**
     Formats extension for display
     - Parameter numberExtension: Number extension string.
     - Returns: Modified number extension with either a preferred extension prefix or the default one.
     */
    func formatExtension(numberExtension: String?, regionMetadata: MetadataTerritory) -> String? {
        if let extns = numberExtension {
            if let preferredExtnPrefix = regionMetadata.preferredExtnPrefix {
                return "\(preferredExtnPrefix)\(extns)"
            }
            else {
                return "\(PhoneNumberConstants.defaultExtnPrefix)\(extns)"
            }
        }
        return nil
    }
    
    /**
     Formats national number for display
     - Parameter nationalNumber: National number string.
     - Returns: Modified nationalNumber for display.
     */
    func formatNationalNumber(nationalNumber: String, regionMetadata: MetadataTerritory, formatType: PhoneNumberFormat) -> String {
        let formats = regionMetadata.numberFormats
        var selectedFormat: MetadataPhoneNumberFormat?
        for format in formats {
            if let leadingDigitPattern = format.leadingDigitsPatterns?.last {
                if (regex.stringPositionByRegex(leadingDigitPattern, string: String(nationalNumber)) == 0) {
                    if (regex.matchesEntirely(format.pattern, string: String(nationalNumber))) {
                        selectedFormat = format
                        break;
                    }
                }
            }
            else {
                if (regex.matchesEntirely(format.pattern, string: String(nationalNumber))) {
                    selectedFormat = format
                    break;
                }
            }
        }
        if let formatPattern = selectedFormat {
            guard let numberFormatRule = (formatType == PhoneNumberFormat.International && formatPattern.intlFormat != nil) ? formatPattern.intlFormat : formatPattern.format, let pattern = formatPattern.pattern else {
                return nationalNumber
            }
            var formattedNationalNumber = String()
            var prefixFormattingRule = String()
            if let nationalPrefixFormattingRule = formatPattern.nationalPrefixFormattingRule, let nationalPrefix = regionMetadata.nationalPrefix {
                prefixFormattingRule = regex.replaceStringByRegex(PhoneNumberPatterns.npPattern, string: nationalPrefixFormattingRule, template: nationalPrefix)
                prefixFormattingRule = regex.replaceStringByRegex(PhoneNumberPatterns.fgPattern, string: prefixFormattingRule, template:"\\$1")
            }
            if formatType == PhoneNumberFormat.National && regex.hasValue(prefixFormattingRule){
                let replacePattern = regex.replaceFirstStringByRegex(PhoneNumberPatterns.firstGroupPattern, string: numberFormatRule, templateString: prefixFormattingRule)
                formattedNationalNumber = self.regex.replaceStringByRegex(pattern, string: nationalNumber, template: replacePattern)
            }
            else {
                formattedNationalNumber = self.regex.replaceStringByRegex(pattern, string: nationalNumber, template: numberFormatRule)
            }
            return formattedNationalNumber
        }
        else {
            return nationalNumber
        }
    }
    
}

public extension PhoneNumber {
    
    // MARK: Formatting extenstions to PhoneNumber
    
    /**
    Formats a phone number to E164 format (e.g. +33689123456)
    - Returns: A string representing the phone number in E164 format.
    */
    public func toE164(prefix: Bool = true) -> String {
        let formattedNationalNumber = adjustedNationalNumber()
        if prefix == false {
            return formattedNationalNumber
        }
        return "+\(String(countryCode))\(formattedNationalNumber)"
    }
    
    /**
     Formats a phone number to International format (e.g. +33 6 89 12 34 56)
     - Returns: A string representing the phone number in International format.
     */
    public func toInternational(prefix: Bool = true) -> String {
        let formatter = Formatter()
        let formattedNationalNumber = formatter.formatPhoneNumber(self, formatType: .International)
        if prefix == false {
            return formattedNationalNumber
        }
        return "+\(String(countryCode)) \(formattedNationalNumber)"
    }
    
    /**
     Formats a phone number to local national format (e.g. 06 89 12 34 56)
     - Returns: A string representing the phone number in the local national format.
     */
    public func toNational() -> String {
        let formatter = Formatter()
        let formattedNationalNumber = formatter.formatPhoneNumber(self, formatType: .National)
        let formattedNumber = formattedNationalNumber
        return formattedNumber
    }
    
    /**
     Adjust national number for display by adding leading zero if needed. Used for basic formatting functions.
     - Returns: A string representing the adjusted national number.
     */
    private func adjustedNationalNumber() -> String {
        if self.leadingZero == true {
            return "0" + String(nationalNumber)
        }
        else {
            return String(nationalNumber)
        }
    }
    
}
