//
//  PhoneNumber.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 26/09/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

/**
Parsed phone number object
 
- CountryCode: Country dialing code as an unsigned. Int.
- LeadingZero: Some countries (e.g. Italy) require leading zeros. Bool.
- NationalNumber: National number as an unsigned. Int.
- NumberExtension: Extension if available. String. Optional
- RawNumber: String used to generate phone number struct
- Type: Computed phone number type on access. Returns from an enumeration - PNPhoneNumberType.
*/
public struct PhoneNumber {
    public let countryCode: UInt64
    private(set) public var leadingZero = false
    public let nationalNumber: UInt64
    public let numberExtension: String?
    public let rawNumber: String
    public var type: PhoneNumberType {
        get {
            let parser = PhoneNumberParser()
            let type: PhoneNumberType = parser.checkNumberType(self)
            return type
        }
    }
    public var isValidNumber: Bool {
        get {
            return self.type != .Unknown
        }
    }
}

public extension PhoneNumber {
    /**
    Parse a string into a phone number object using default region. Can throw.
    - Parameter rawNumber: String to be parsed to phone number struct.
    */
    public init(rawNumber: String) throws {
        let defaultRegion = PhoneNumberKit().defaultRegionCode()
        try self.init(rawNumber: rawNumber, region: defaultRegion)
    }
    
    /**
    Parse a string into a phone number object using custom region. Can throw.
    - Parameter rawNumber: String to be parsed to phone number struct.
    - Parameter region: ISO 639 compliant region code.
    */
    public init(rawNumber: String, region: String) throws {
        let phoneNumber = try ParseManager().parsePhoneNumber(rawNumber, region: region)
        self = phoneNumber
    }

}


