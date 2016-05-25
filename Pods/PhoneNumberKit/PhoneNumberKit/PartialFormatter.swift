//
//  PartialFormatter.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 29/11/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

/// Partial formatter
public class PartialFormatter {
    
    let metadata = Metadata.sharedInstance
    let parser = PhoneNumberParser()
    let regex = RegularExpressions.sharedInstance
    
    var defaultRegion: String {
        didSet {
            updateMetadataForDefaultRegion()
        }
    }

    func updateMetadataForDefaultRegion() {
        if let regionMetadata = metadata.fetchMetadataForCountry(defaultRegion) {
            defaultMetadata = metadata.fetchMainCountryMetadataForCode(regionMetadata.countryCode)
        } else {
            defaultMetadata = nil
        }
        currentMetadata = defaultMetadata
    }

    var defaultMetadata: MetadataTerritory?
    var currentMetadata: MetadataTerritory?
    var prefixBeforeNationalNumber =  String()
    var shouldAddSpaceAfterNationalPrefix = false
    
    var withPrefix = true
    
    //MARK: Status

    public var currentRegion: String {
        get {
            return currentMetadata?.codeID ?? defaultRegion
        }
    }
  
    
    //MARK: Lifecycle
    
    /**
    Initialise a partial formatter with the default region
    
    - returns: PartialFormatter object
    */
    public convenience init() {
        let defaultRegion = PhoneNumberKit().defaultRegionCode()
        self.init(defaultRegion: defaultRegion)
    }
    
    /**
     Inits a partial formatter with a custom region
     
     - parameter region: ISO 639 compliant region code.
     
     - returns: PartialFormatter object
     */
    public init(defaultRegion: String, withPrefix: Bool = true) {
        self.defaultRegion = defaultRegion
        updateMetadataForDefaultRegion()
        self.withPrefix = withPrefix
    }
    
    /**
     Formats a partial string (for use in TextField)
     
     - parameter rawNumber: Unformatted phone number string
     
     - returns: Formatted phone number string.
     */
    public func formatPartial(rawNumber: String) -> String {
        // Always reset variables with each new raw number
        resetVariables()
        // Check if number is valid for parsing, if not return raw
        guard isValidRawNumber(rawNumber) else {
            return rawNumber
        }
        // Determine if number is valid by trying to instantiate a PhoneNumber object with it
        let iddFreeNumber = extractIDD(rawNumber)
        var nationalNumber = parser.normalizePhoneNumber(iddFreeNumber)
        if prefixBeforeNationalNumber.characters.count > 0 {
            nationalNumber = extractCountryCallingCode(nationalNumber)
        }
        nationalNumber = extractNationalPrefix(nationalNumber)

        if let formats = availableFormats(nationalNumber) {
            if let formattedNumber = applyFormat(nationalNumber, formats: formats) {
                nationalNumber = formattedNumber
            }
            else {
                for format in formats {
                    if let template = createFormattingTemplate(format, rawNumber: nationalNumber) {
                        nationalNumber = applyFormattingTemplate(template, rawNumber: nationalNumber)
                        break
                    }
                }
            }
        }
        var finalNumber = String()
        if prefixBeforeNationalNumber.characters.count > 0 {
            finalNumber.appendContentsOf(prefixBeforeNationalNumber)
        }
        if shouldAddSpaceAfterNationalPrefix && prefixBeforeNationalNumber.characters.count > 0 && prefixBeforeNationalNumber.characters.last != PhoneNumberConstants.separatorBeforeNationalNumber.characters.first  {
            finalNumber.appendContentsOf(PhoneNumberConstants.separatorBeforeNationalNumber)
        }
        if nationalNumber.characters.count > 0 {
            finalNumber.appendContentsOf(nationalNumber)
        }
        if finalNumber.characters.last == PhoneNumberConstants.separatorBeforeNationalNumber.characters.first {
            finalNumber = finalNumber.substringToIndex(finalNumber.endIndex.predecessor())
        }

        return finalNumber
    }
    
    //MARK: Formatting Functions
    
    internal func resetVariables() {
        currentMetadata = defaultMetadata
        prefixBeforeNationalNumber = String()
        shouldAddSpaceAfterNationalPrefix = false
    }
    
    //MARK: Formatting Tests
    
    internal func isValidRawNumber(rawNumber: String) -> Bool {
        do {
            // In addition to validPhoneNumberPattern, 
            // accept any sequence of digits and whitespace, prefixed or not by a plus sign
            let validPartialPattern = "[+＋]?(\\s*\\d)+\\s*$|\(PhoneNumberPatterns.validPhoneNumberPattern)"
            let validNumberMatches = try regex.regexMatches(validPartialPattern, string: rawNumber)
            let validStart = regex.stringPositionByRegex(PhoneNumberPatterns.validStartPattern, string: rawNumber)
            if validNumberMatches.count == 0 || validStart != 0 {
                return false
            }
        }
        catch {
            return false
        }
        return true
    }
    
    internal func isNanpaNumberWithNationalPrefix(rawNumber: String) -> Bool {
        if currentMetadata?.countryCode != 1 {
            return false
        }
        return (rawNumber.characters.first == "1" && String(rawNumber.characters.startIndex.advancedBy(1)) != "0" && String(rawNumber.characters.startIndex.advancedBy(1)) != "1")
    }
    
    func isFormatEligible(format: MetadataPhoneNumberFormat) -> Bool {
        guard let phoneFormat = format.format else {
            return false
        }
        do {
            let validRegex = try regex.regexWithPattern(PhoneNumberPatterns.eligibleAsYouTypePattern)
            if validRegex.firstMatchInString(phoneFormat, options: [], range: NSMakeRange(0, phoneFormat.characters.count)) != nil {
                return true
            }
        }
        catch {}
        return false
    }
    
    //MARK: Formatting Extractions
    
    func extractIDD(rawNumber: String) -> String {
        var processedNumber = rawNumber
        do {
            if let internationalPrefix = currentMetadata?.internationalPrefix {
                let prefixPattern = String(format: PhoneNumberPatterns.iddPattern, arguments: [internationalPrefix])
                let matches = try regex.matchedStringByRegex(prefixPattern, string: rawNumber)
                if let m = matches.first {
                    let startCallingCode = m.characters.count
                    let index = rawNumber.startIndex.advancedBy(startCallingCode)
                    processedNumber = rawNumber.substringFromIndex(index)
                    prefixBeforeNationalNumber = rawNumber.substringToIndex(index)
                }
            }
        }
        catch {
            return processedNumber
        }
        return processedNumber
    }
    
    func extractNationalPrefix(rawNumber: String) -> String {
        var processedNumber = rawNumber
        var startOfNationalNumber: Int = 0
        if isNanpaNumberWithNationalPrefix(rawNumber) {
            prefixBeforeNationalNumber.appendContentsOf("1 ")
        }
        else {
            do {
                if let nationalPrefix = currentMetadata?.nationalPrefixForParsing {
                    let nationalPrefixPattern = String(format: PhoneNumberPatterns.nationalPrefixParsingPattern, arguments: [nationalPrefix])
                    let matches = try regex.matchedStringByRegex(nationalPrefixPattern, string: rawNumber)
                    if let m = matches.first {
                        startOfNationalNumber = m.characters.count
                    }
                }
            }
            catch {
                return processedNumber
                }
        }
        let index = rawNumber.startIndex.advancedBy(startOfNationalNumber)
        processedNumber = rawNumber.substringFromIndex(index)
        prefixBeforeNationalNumber.appendContentsOf(rawNumber.substringToIndex(index))
        return processedNumber
    }
    
    func extractCountryCallingCode(rawNumber: String) -> String {
        var processedNumber = rawNumber
        if rawNumber.isEmpty {
            return rawNumber
        }
        var numberWithoutCountryCallingCode = String()
        if prefixBeforeNationalNumber.isEmpty == false && prefixBeforeNationalNumber.characters.first != "+" {
            prefixBeforeNationalNumber.appendContentsOf(PhoneNumberConstants.separatorBeforeNationalNumber)
        }
        if let potentialCountryCode = self.parser.extractPotentialCountryCode(rawNumber, nationalNumber: &numberWithoutCountryCallingCode) where potentialCountryCode != 0 {
            processedNumber = numberWithoutCountryCallingCode
            currentMetadata = metadata.fetchMainCountryMetadataForCode(potentialCountryCode)
            let potentialCountryCodeString = String(potentialCountryCode)
            prefixBeforeNationalNumber.appendContentsOf(potentialCountryCodeString)
            prefixBeforeNationalNumber.appendContentsOf(" ")
        }
        else if withPrefix == false && prefixBeforeNationalNumber.isEmpty {
            let potentialCountryCodeString = String(currentMetadata?.countryCode)
            prefixBeforeNationalNumber.appendContentsOf(potentialCountryCodeString)
            prefixBeforeNationalNumber.appendContentsOf(" ")
        }
        return processedNumber
    }

    func availableFormats(rawNumber: String) -> [MetadataPhoneNumberFormat]? {
        var tempPossibleFormats = [MetadataPhoneNumberFormat]()
        var possibleFormats = [MetadataPhoneNumberFormat]()
        if let metadata = currentMetadata {
            let formatList = metadata.numberFormats
            for format in formatList {
                if isFormatEligible(format) {
                    tempPossibleFormats.append(format)
                    if let leadingDigitPattern = format.leadingDigitsPatterns?.last {
                        if (regex.stringPositionByRegex(leadingDigitPattern, string: String(rawNumber)) == 0) {
                            possibleFormats.append(format)
                        }
                    }
                    else {
                        if (regex.matchesEntirely(format.pattern, string: String(rawNumber))) {
                            possibleFormats.append(format)
                        }
                    }
                }
            }
            if possibleFormats.count == 0 {
                possibleFormats.appendContentsOf(tempPossibleFormats)
            }
            return possibleFormats
        }
        return nil
    }
    
    
    func applyFormat(rawNumber: String, formats: [MetadataPhoneNumberFormat]) -> String? {
        for format in formats {
            if let pattern = format.pattern, let formatTemplate = format.format {
                let patternRegExp = String(format: PhoneNumberPatterns.formatPattern, arguments: [pattern])
                do {
                    let matches = try regex.regexMatches(patternRegExp, string: rawNumber)
                    if matches.count > 0 {
                        if let nationalPrefixFormattingRule = format.nationalPrefixFormattingRule {
                            let separatorRegex = try regex.regexWithPattern(PhoneNumberPatterns.prefixSeparatorPattern)
                            let nationalPrefixMatches = separatorRegex.matchesInString(nationalPrefixFormattingRule, options: [], range:  NSMakeRange(0, nationalPrefixFormattingRule.characters.count))
                            if nationalPrefixMatches.count > 0 {
                                shouldAddSpaceAfterNationalPrefix = true
                            }
                        }
                        let formattedNumber = regex.replaceStringByRegex(pattern, string: rawNumber, template: formatTemplate)
                        return formattedNumber
                    }
                }
                catch {
                
                }
            }
        }
        return nil
    }
    
    
    
    func createFormattingTemplate(format: MetadataPhoneNumberFormat, rawNumber: String) -> String?  {
        guard var numberPattern = format.pattern, let numberFormat = format.format else {
            return nil
        }
        guard numberPattern.rangeOfString("|") == nil else {
            return nil
        }
        do {
            let characterClassRegex = try regex.regexWithPattern(PhoneNumberPatterns.characterClassPattern)
            var nsString = numberPattern as NSString
            var stringRange = NSMakeRange(0, nsString.length)
            numberPattern = characterClassRegex.stringByReplacingMatchesInString(numberPattern, options: [], range: stringRange, withTemplate: "\\\\d")
    
            let standaloneDigitRegex = try regex.regexWithPattern(PhoneNumberPatterns.standaloneDigitPattern)
            nsString = numberPattern as NSString
            stringRange = NSMakeRange(0, nsString.length)
            numberPattern = standaloneDigitRegex.stringByReplacingMatchesInString(numberPattern, options: [], range: stringRange, withTemplate: "\\\\d")
            
            if let tempTemplate = getFormattingTemplate(numberPattern, numberFormat: numberFormat, rawNumber: rawNumber) {
                if let nationalPrefixFormattingRule = format.nationalPrefixFormattingRule {
                    let separatorRegex = try regex.regexWithPattern(PhoneNumberPatterns.prefixSeparatorPattern)
                    let nationalPrefixMatch = separatorRegex.firstMatchInString(nationalPrefixFormattingRule, options: [], range:  NSMakeRange(0, nationalPrefixFormattingRule.characters.count))
                    if nationalPrefixMatch != nil {
                        shouldAddSpaceAfterNationalPrefix = true
                    }
                }
                return tempTemplate
            }
        }
        catch { }
        return nil
    }
    
    func getFormattingTemplate(numberPattern: String, numberFormat: String, rawNumber: String) -> String? {
        do {
            let matches =  try regex.matchedStringByRegex(numberPattern, string: PhoneNumberConstants.longPhoneNumber)
            if let match = matches.first {
                if match.characters.count < rawNumber.characters.count {
                    return nil
                }
                var template = regex.replaceStringByRegex(numberPattern, string: match, template: numberFormat)
                template = regex.replaceStringByRegex("9", string: template, template: PhoneNumberConstants.digitPlaceholder)
                return template
            }
        }
        catch {
        
        }
        return nil
    }
    
    func applyFormattingTemplate(template: String, rawNumber: String) -> String {
        var rebuiltString = String()
        var rebuiltIndex = 0
        for character in template.characters {
            if character == PhoneNumberConstants.digitPlaceholder.characters.first {
                if rebuiltIndex < rawNumber.characters.count {
                    let nationalCharacterIndex = rawNumber.startIndex.advancedBy(rebuiltIndex)
                    rebuiltString.append(rawNumber[nationalCharacterIndex])
                    rebuiltIndex += 1
                }
            }
            else {
                if rebuiltIndex < rawNumber.characters.count {
                rebuiltString.append(character)
                }
            }
        }
        if rebuiltIndex < rawNumber.characters.count {
            let nationalCharacterIndex = rawNumber.startIndex.advancedBy(rebuiltIndex)
            let remainingNationalNumber: String = rawNumber.substringFromIndex(nationalCharacterIndex)
            rebuiltString.appendContentsOf(remainingNationalNumber)
        }
        rebuiltString = rebuiltString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

        return rebuiltString
    }
    
}
