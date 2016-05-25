//
//  Constants.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 25/10/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

// MARK: Private Enums
enum PhoneNumberCountryCodeSource {
    case NumberWithPlusSign
    case NumberWithIDD
    case NumberWithoutPlusSign
    case DefaultCountry
}

enum PhoneNumberFormat {
    case E164
    case International
    case National
}


// MARK: Public Enums

/**
Enumeration for parsing error types

- GeneralError: A general error occured.
- InvalidCountryCode: A country code could not be found or the one found was invalid
- NotANumber: The string provided is not a number
- TooLong: The string provided is too long to be a valid number
- TooShort: The string provided is too short to be a valid number
*/
public enum PhoneNumberError: ErrorType {
    case GeneralError
    case InvalidCountryCode
    case NotANumber
    case TooLong
    case TooShort
    
    public var description: String {
        switch self {
        case .GeneralError: return NSLocalizedString("An error occured whilst validating the phone number.", comment: "")
        case .InvalidCountryCode: return NSLocalizedString("The country code is invalid.", comment: "")
        case .NotANumber: return NSLocalizedString("The number provided is invalid.", comment: "")
        case .TooLong: return NSLocalizedString("The number provided is too long.", comment: "")
        case .TooShort: return NSLocalizedString("The number provided is too short.", comment: "")
        }
    }
}

/**
 Phone number type enumeration
 - FixedLine: Fixed line numbers
 - Mobile: Mobile numbers
 - FixedOrMobile: Either fixed or mobile numbers if we can't tell conclusively.
 - Pager: Pager numbers
 - PersonalNumber: Personal number numbers
 - PremiumRate: Premium rate numbers
 - SharedCost: Shared cost numbers
 - TollFree: Toll free numbers
 - Voicemail: Voice mail numbers
 - VOIP: Voip numbers
 - UAN: UAN numbers
 - Unknown: Unknown number type
 */
public enum PhoneNumberType {
    case FixedLine
    case Mobile
    case FixedOrMobile
    case Pager
    case PersonalNumber
    case PremiumRate
    case SharedCost
    case TollFree
    case Voicemail
    case VOIP
    case UAN
    case Unknown
}

// MARK: Constants

public struct PhoneNumberConstants {
  public static let defaultCountry = "US"
  public static let defaultExtnPrefix = " ext. "
  public static let longPhoneNumber = "999999999999999"
  public static let minLengthForNSN = 2
  public static let maxInputStringLength = 250
  public static let maxLengthCountryCode = 3
  public static let maxLengthForNSN = 16
  public static let nonBreakingSpace = "\u{00a0}"
  public static let plusChars = "+＋"
  public static let validDigitsString = "0-9０-９٠-٩۰-۹"
  public static let digitPlaceholder = "\u{2008}"
  public static let separatorBeforeNationalNumber = " "
}

public struct PhoneNumberPatterns {
  // MARK: Patterns
  
  public static let firstGroupPattern = "(\\$\\d)"
  public static let fgPattern = "\\$FG"
  public static let npPattern = "\\$NP"

  public static let allNormalizationMappings = ["0":"0", "1":"1", "2":"2", "3":"3", "4":"4", "5":"5", "6":"6", "7":"7", "8":"8", "9":"9"]

  public static let capturingDigitPattern = "([0-9０-９٠-٩۰-۹])"

  public static let extnPattern = "\\;(.*)"

  public static let iddPattern = "^(?:\\+|%@)"

  public static let formatPattern = "^(?:%@)$"

  public static let characterClassPattern = "\\[([^\\[\\]])*\\]"

  public static let standaloneDigitPattern = "\\d(?=[^,}][^,}])"

  public static let nationalPrefixParsingPattern = "^(?:%@)"

  public static let prefixSeparatorPattern = "[- ]"

  public static let eligibleAsYouTypePattern = "^[-x‐-―−ー－-／ ­​⁠　()（）［］.\\[\\]/~⁓∼～]*(\\$\\d[-x‐-―−ー－-／ ­​⁠　()（）［］.\\[\\]/~⁓∼～]*)+$"

  public static let leadingPlusCharsPattern = "^[+＋]+"

  public static let secondNumberStartPattern = "[\\\\\\/] *x"

  public static let unwantedEndPattern = "[^0-9０-９٠-٩۰-۹A-Za-z#]+$"

  public static let validStartPattern = "[+＋0-9０-９٠-٩۰-۹]"

  public static let validPhoneNumberPattern = "^[0-9０-９٠-٩۰-۹]{2}$|^[+＋]*(?:[-x\u{2010}-\u{2015}\u{2212}\u{30FC}\u{FF0D}-\u{FF0F} \u{00A0}\u{00AD}\u{200B}\u{2060}\u{3000}()\u{FF08}\u{FF09}\u{FF3B}\u{FF3D}.\\[\\]/~\u{2053}\u{223C}\u{FF5E}*]*[0-9\u{FF10}-\u{FF19}\u{0660}-\u{0669}\u{06F0}-\u{06F9}]){3,}[-x\u{2010}-\u{2015}\u{2212}\u{30FC}\u{FF0D}-\u{FF0F} \u{00A0}\u{00AD}\u{200B}\u{2060}\u{3000}()\u{FF08}\u{FF09}\u{FF3B}\u{FF3D}.\\[\\]/~\u{2053}\u{223C}\u{FF5E}*A-Za-z0-9\u{FF10}-\u{FF19}\u{0660}-\u{0669}\u{06F0}-\u{06F9}]*(?:(?:;ext=([0-9０-９٠-٩۰-۹]{1,7})|[  \\t,]*(?:e?xt(?:ensi(?:ó?|ó))?n?|ｅ?ｘｔｎ?|[,xｘX#＃~～]|int|anexo|ｉｎｔ)[:\\.．]?[  \\t,-]*([0-9０-９٠-٩۰-۹]{1,7})#?|[- ]+([0-9０-９٠-٩۰-۹]{1,5})#)?$)?$"
}