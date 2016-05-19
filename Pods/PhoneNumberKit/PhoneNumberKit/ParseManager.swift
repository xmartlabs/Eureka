//
//  ParseManager.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 01/11/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

/**
Manager for parsing flow.
*/
class ParseManager {
    let metadata = Metadata.sharedInstance
    let parser = PhoneNumberParser()
    let regex = RegularExpressions.sharedInstance
    private var multiParseArray = SynchronizedArray<PhoneNumber>()
    
    /**
    Parse a string into a phone number object with a custom region. Can throw.
    - Parameter rawNumber: String to be parsed to phone number struct.
    - Parameter region: ISO 639 compliant region code.
    */
    func parsePhoneNumber(rawNumber: String, region: String) throws -> PhoneNumber {
        // Make sure region is in uppercase so that it matches metadata (1)
        let region = region.uppercaseString
        // Extract number (2)
        var nationalNumber = rawNumber
        let matches = try self.regex.phoneDataDetectorMatches(rawNumber)
        if let phoneNumber = matches.first?.phoneNumber {
            nationalNumber = phoneNumber
        }
        // Strip and extract extension (3)
        let numberExtension = self.parser.stripExtension(&nationalNumber)
        // Country code parse (4)
        guard var regionMetadata =  self.metadata.metadataPerCountry[region] else {
            throw PhoneNumberError.InvalidCountryCode
        }
        var countryCode: UInt64 = 0
        do {
            countryCode = try self.parser.extractCountryCode(nationalNumber, nationalNumber: &nationalNumber, metadata: regionMetadata)
        }
        catch {
            do {
                let plusRemovedNumberString = self.regex.replaceStringByRegex(PhoneNumberPatterns.leadingPlusCharsPattern, string: nationalNumber as String)
                countryCode = try self.parser.extractCountryCode(plusRemovedNumberString, nationalNumber: &nationalNumber, metadata: regionMetadata)
            }
            catch {
                throw PhoneNumberError.InvalidCountryCode
            }
        }
        if countryCode == 0 {
            countryCode = regionMetadata.countryCode
        }
        // Nomralized number (5)
        let normalizedNationalNumber = self.parser.normalizePhoneNumber(nationalNumber)
        nationalNumber = normalizedNationalNumber
        // If country code is not default, grab correct metadata (6)
        if countryCode != regionMetadata.countryCode, let countryMetadata = self.metadata.metadataPerCode[countryCode] {
            regionMetadata = countryMetadata
        }
        // National Prefix Strip (7)
        self.parser.stripNationalPrefix(&nationalNumber, metadata: regionMetadata)
        
        // Test number against general number description for correct metadata (8)
        if let generalNumberDesc = regionMetadata.generalDesc where (self.regex.hasValue(generalNumberDesc.nationalNumberPattern) == false || self.parser.isNumberMatchingDesc(nationalNumber, numberDesc: generalNumberDesc) == false) {
            throw PhoneNumberError.NotANumber
        }
        // Finalize remaining parameters and create phone number object (9)
        let leadingZero = nationalNumber.hasPrefix("0")
        guard let finalNationalNumber = UInt64(nationalNumber) else{
            throw PhoneNumberError.NotANumber
        }
        let phoneNumber = PhoneNumber(countryCode: countryCode, leadingZero: leadingZero, nationalNumber: finalNationalNumber, numberExtension: numberExtension, rawNumber: rawNumber)
        return phoneNumber
    }
    
    // Parse task
    
    /**
    Fastest way to parse an array of phone numbers. Uses custom region code.
    - Parameter rawNumbers: An array of raw number strings.
    - Parameter region: ISO 639 compliant region code.
    - Returns: An array of valid PhoneNumber objects.
    */
    func parseMultiple(rawNumbers: [String], region: String, testCallback: (()->())? = nil) -> [PhoneNumber] {
        let rawNumbersCopy = rawNumbers
        self.multiParseArray = SynchronizedArray<PhoneNumber>()
        let queue = NSOperationQueue()
        var operationArray: [ParseOperation<PhoneNumber>] = []
        let completionOperation = ParseOperation<Bool>()
        completionOperation.onStart { asyncOp in
            asyncOp.finish(with: true)
        }
        completionOperation.whenFinished { asyncOp in
        }
        for (index, rawNumber) in rawNumbersCopy.enumerate() {
            let parseTask = parseOperation(rawNumber, region:region)
            parseTask.whenFinished { operation in
                if let phoneNumber = operation.output.value {
                    self.multiParseArray.append(phoneNumber)
                }
            }
            operationArray.append(parseTask)
            completionOperation.addDependency(parseTask)
            if index == rawNumbers.count/2 {
                testCallback?()
            }
        }
        queue.addOperations(operationArray, waitUntilFinished: false)
        queue.addOperations([completionOperation], waitUntilFinished: true)
        let localMultiParseArray = self.multiParseArray
        return localMultiParseArray.array
    }
    
    /**
     Single parsing task, used as an element of parseMultiple.
     - Parameter rawNumbers: An array of raw number strings.
     - Parameter region: ISO 639 compliant region code.
     - Returns: Parse operation with an implementation handler and no completion handler.
     */
    func parseOperation(rawNumber: String, region: String) -> ParseOperation<PhoneNumber> {
        let operation = ParseOperation<PhoneNumber>()
        operation.onStart { asyncOp in
            let phoneNumber = try self.parsePhoneNumber(rawNumber, region: region)
            asyncOp.finish(with: phoneNumber)
        }
        return operation
    }
}

/**
Thread safe Swift array generic that locks on write.
*/
class SynchronizedArray<T> {
    var array: [T] = []
    private let accessQueue = dispatch_queue_create("SynchronizedArrayAccess", DISPATCH_QUEUE_SERIAL)
    func append(newElement: T) {
        dispatch_async(self.accessQueue) {
            self.array.append(newElement)
        }
    }
}
