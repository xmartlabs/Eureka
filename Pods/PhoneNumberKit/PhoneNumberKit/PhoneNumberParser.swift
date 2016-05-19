//
//  PhoneNumberParser.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 26/09/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

/**
Parser. Contains parsing functions. 
*/
class PhoneNumberParser {
    let metadata = Metadata.sharedInstance
    let regex = RegularExpressions.sharedInstance
        
    // MARK: Normalizations
    
    /**
    Normalize a phone number (e.g +33 612-345-678 to 33612345678).
    - Parameter number: Phone number string.
    - Returns: Normalized phone number string.
    */
    func normalizePhoneNumber(number: String) -> String {
        let normalizationMappings = PhoneNumberPatterns.allNormalizationMappings
        return regex.stringByReplacingOccurrences(number, map: normalizationMappings)
    }

    // MARK: Extractions
    
    /**
    Extract country code (e.g +33 612-345-678 to 33).
    - Parameter number: Number string.
    - Parameter nationalNumber: National number string - inout.
    - Parameter metadata: Metadata territory object.
    - Returns: Country code is UInt64.
    */
    func extractCountryCode(number: String, inout nationalNumber: String, metadata: MetadataTerritory) throws -> UInt64 {
        var fullNumber = number
        guard let possibleCountryIddPrefix = metadata.internationalPrefix else {
            return 0
        }
        let countryCodeSource = stripInternationalPrefixAndNormalize(&fullNumber, possibleIddPrefix: possibleCountryIddPrefix)
        if countryCodeSource != .DefaultCountry {
            if fullNumber.characters.count <= PhoneNumberConstants.minLengthForNSN {
                throw PhoneNumberError.TooShort
            }
            if let potentialCountryCode = extractPotentialCountryCode(fullNumber, nationalNumber: &nationalNumber) where potentialCountryCode != 0 {
                return potentialCountryCode
            }
            else {
                return 0
            }
        }
        else {
            let defaultCountryCode = String(metadata.countryCode)
            if fullNumber.hasPrefix(defaultCountryCode) {
                let nsFullNumber = fullNumber as NSString
                var potentialNationalNumber = nsFullNumber.substringFromIndex(defaultCountryCode.characters.count)
                guard let validNumberPattern = metadata.generalDesc?.nationalNumberPattern, let possibleNumberPattern = metadata.generalDesc?.possibleNumberPattern else {
                    return 0
                }
                stripNationalPrefix(&potentialNationalNumber, metadata: metadata)
                let potentialNationalNumberStr = String(potentialNationalNumber.copy())
                if ((!regex.matchesEntirely(validNumberPattern, string: fullNumber) && regex.matchesEntirely(validNumberPattern, string: potentialNationalNumberStr )) || regex.testStringLengthAgainstPattern(possibleNumberPattern, string: fullNumber as String) == false) {
                    nationalNumber = potentialNationalNumberStr
                    if let countryCode = UInt64(defaultCountryCode) {
                        return UInt64(countryCode)
                    }
                }
            }
        }
        return 0
    }
    
    /**
    Extract potential country code (e.g +33 612-345-678 to 33).
    - Parameter fullNumber: Full number string.
    - Parameter nationalNumber: National number string.
    - Returns: Country code is UInt64. Optional.
    */
    func extractPotentialCountryCode(fullNumber: String, inout nationalNumber: String) -> UInt64? {
        let nsFullNumber = fullNumber as NSString
        if nsFullNumber.length == 0 || nsFullNumber.substringToIndex(1) == "0" {
            return 0
        }
        let numberLength = nsFullNumber.length
        let maxCountryCode = PhoneNumberConstants.maxLengthCountryCode
        var startPosition = 0
        if fullNumber.hasPrefix("+") {
            if nsFullNumber.length == 1 {
                return 0
            }
            startPosition = 1
        }
        for i in 1...numberLength {
            if i > maxCountryCode {
                break
            }
            let stringRange = NSMakeRange(startPosition, i)
            let subNumber = nsFullNumber.substringWithRange(stringRange)
            if let potentialCountryCode = UInt64(subNumber)
                where metadata.metadataPerCode[potentialCountryCode] != nil {
                    nationalNumber = nsFullNumber.substringFromIndex(i)
                    return potentialCountryCode
            }
        }
        return 0
    }
    
    // MARK: Validations
    
    /**
    Check number type (e.g +33 612-345-678 to .Mobile).
    - Parameter phoneNumber: The number to check
    - Returns: The type of the number
    */
    func checkNumberType(phoneNumber: PhoneNumber) -> PhoneNumberType {
        guard let region = PhoneNumberKit().regionCodeForNumber(phoneNumber) else {
            return .Unknown
        }
        guard let metadata = metadata.fetchMetadataForCountry(region) else {
            return .Unknown
        }
        if phoneNumber.leadingZero {
            let type = checkNumberType("0" + String(phoneNumber.nationalNumber), metadata: metadata)
            if type != .Unknown {
                return type
            }
        }
        let nationalNumber = String(phoneNumber.nationalNumber)
        return checkNumberType(nationalNumber, metadata: metadata)
    }

    func checkNumberType(nationalNumber: String, metadata: MetadataTerritory) -> PhoneNumberType {
        guard let generalNumberDesc = metadata.generalDesc else {
            return .Unknown
        }
        if (regex.hasValue(generalNumberDesc.nationalNumberPattern) == false || isNumberMatchingDesc(nationalNumber, numberDesc: generalNumberDesc) == false) {
            return .Unknown
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.pager)) {
            return .Pager
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.premiumRate)) {
            return .PremiumRate
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.tollFree)) {
            return .TollFree
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.sharedCost)) {
            return .SharedCost
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.voip)) {
            return .VOIP
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.personalNumber)) {
            return .PersonalNumber
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.uan)) {
            return .UAN
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.voicemail)) {
            return .Voicemail
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.fixedLine)) {
            if metadata.fixedLine?.nationalNumberPattern == metadata.mobile?.nationalNumberPattern {
                return .FixedOrMobile
            }
            else if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.mobile)) {
                return .FixedOrMobile
            }
            else {
                return .FixedLine
            }
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.mobile)) {
            return .Mobile
        }
        return .Unknown
    }
    
    /**
     Checks if number matches description.
     - Parameter nationalNumber: National number string.
     - Parameter numberDesc:  MetadataPhoneNumberDesc of a given phone number type.
     - Returns: True or false.
     */
    func isNumberMatchingDesc(nationalNumber: String, numberDesc: MetadataPhoneNumberDesc?) -> Bool {
        return regex.matchesEntirely(numberDesc?.nationalNumberPattern, string: nationalNumber)
    }
    
    /**
    Checks and strips if prefix is international dialing pattern.
    - Parameter number: Number string.
    - Parameter iddPattern:  iddPattern for a given country.
    - Returns: True or false and modifies the number accordingly.
    */
    func parsePrefixAsIdd(inout number: String, iddPattern: String) -> Bool {
        if (regex.stringPositionByRegex(iddPattern, string: number) == 0) {
            do {
                let nsString = number as NSString
                guard let matched = try regex.regexMatches(iddPattern as String, string: number as String).first else {
                    return false
                }
                let matchedString = number.substringWithNSRange(matched.range)
                let matchEnd = matchedString.characters.count
                let remainString: NSString = nsString.substringFromIndex(matchEnd)
                let capturingDigitPatterns = try NSRegularExpression(pattern: PhoneNumberPatterns.capturingDigitPattern, options:NSRegularExpressionOptions.CaseInsensitive)
                let matchedGroups = capturingDigitPatterns.matchesInString(remainString as String, options: [], range: NSMakeRange(0, remainString.length))
                if let firstMatch = matchedGroups.first {
                    let digitMatched = remainString.substringWithRange(firstMatch.range) as NSString
                    if digitMatched.length > 0 {
                        let normalizedGroup =  regex.stringByReplacingOccurrences(digitMatched as String, map: PhoneNumberPatterns.allNormalizationMappings)
                        if normalizedGroup == "0" {
                            return false
                        }
                    }
                }
                number = remainString as String
                return true
            }
            catch {
                return false
            }
        }
        return false
    }

    // MARK: Strip helpers
    
    /**
    Strip an extension (e.g +33 612-345-678 ext.89 to 89).
    - Parameter number: Number string.
    - Returns: Modified number without extension and optional extension as string.
    */
    func stripExtension(inout number: String) -> String? {
        do {
            let matches = try regex.regexMatches(PhoneNumberPatterns.extnPattern, string: number)
            if let match = matches.first {
                let adjustedRange = NSMakeRange(match.range.location + 1, match.range.length - 1)
                let matchString = number.substringWithNSRange(adjustedRange)
                let stringRange = NSMakeRange(0, match.range.location)
                number = number.substringWithNSRange(stringRange)
                return matchString
            }
            return nil
        }
        catch {
            return nil
        }
    }
    
    /**
    Strip international prefix.
    - Parameter number: Number string.
    - Parameter possibleIddPrefix:  Possible idd prefix for a given country.
    - Returns: Modified normalized number without international prefix and a PNCountryCodeSource enumeration.
    */
    func stripInternationalPrefixAndNormalize(inout number: String, possibleIddPrefix: String?) -> PhoneNumberCountryCodeSource {
        if (regex.matchesAtStart(PhoneNumberPatterns.leadingPlusCharsPattern, string: number as String)) {
            number = regex.replaceStringByRegex(PhoneNumberPatterns.leadingPlusCharsPattern, string: number as String)
            return .NumberWithPlusSign
        }
        number = normalizePhoneNumber(number as String)
        guard let possibleIddPrefix = possibleIddPrefix else {
            return .NumberWithoutPlusSign
        }
        let prefixResult = parsePrefixAsIdd(&number, iddPattern: possibleIddPrefix)
        if prefixResult == true {
            return .NumberWithIDD
        }
        else {
            return .DefaultCountry
        }
    }
    
    /**
     Strip national prefix.
     - Parameter number: Number string.
     - Parameter metadata:  Final country's metadata.
     - Returns: Modified number without national prefix.
     */
    func stripNationalPrefix(inout number: String, metadata: MetadataTerritory) {
        guard let possibleNationalPrefix = metadata.nationalPrefixForParsing else {
            return
        }
        let prefixPattern = String(format: "^(?:%@)", possibleNationalPrefix)
        do {
            let matches = try regex.regexMatches(prefixPattern, string: number)
            if let firstMatch = matches.first {
                let nationalNumberRule = metadata.generalDesc?.nationalNumberPattern
                let firstMatchString = number.substringWithNSRange(firstMatch.range)
                let numOfGroups = firstMatch.numberOfRanges - 1
                var transformedNumber: String = String()
                let firstRange = firstMatch.rangeAtIndex(numOfGroups)
                let firstMatchStringWithGroup = (firstRange.location != NSNotFound && firstRange.location < number.characters.count) ? number.substringWithNSRange(firstRange):  String()
                let firstMatchStringWithGroupHasValue = regex.hasValue(firstMatchStringWithGroup)
                if let transformRule = metadata.nationalPrefixTransformRule where firstMatchStringWithGroupHasValue == true {
                    transformedNumber = regex.replaceFirstStringByRegex(prefixPattern, string: number, templateString: transformRule)
                }
                else {
                    let index = number.startIndex.advancedBy(firstMatchString.characters.count)
                    transformedNumber = number.substringFromIndex(index)
                }
                if (regex.hasValue(nationalNumberRule) && regex.matchesEntirely(nationalNumberRule, string: number) && regex.matchesEntirely(nationalNumberRule, string: transformedNumber) == false){
                    return
                }
                number = transformedNumber
                return
            }
        }
        catch {
            return
        }
    }
    
}
