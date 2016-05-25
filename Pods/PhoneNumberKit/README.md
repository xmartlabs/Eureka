![PhoneNumberKit](https://cloud.githubusercontent.com/assets/889949/10723260/5225c86c-7bb9-11e5-883c-9b42aa50ea27.png)

[![Build Status](https://travis-ci.org/marmelroy/PhoneNumberKit.svg?branch=master)](https://travis-ci.org/marmelroy/PhoneNumberKit) [![Version](http://img.shields.io/cocoapods/v/PhoneNumberKit.svg)](http://cocoapods.org/?q=PhoneNumberKit)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# PhoneNumberKit
Swift framework for parsing, formatting and validating international phone numbers.
Inspired by Google's libphonenumber.

### :construction: PhoneNumberKit is currently beta software :construction:

 | Remaining Objectives
--- | ---
⚔ | Battle-test PhoneNumberKit in a major app (100k+ users).

## Features

              |  Features
--------------------------|------------------------------------------------------------
:phone: | Validate, normalize and extract the elements of any phone number string.
:100: | Simple Swift syntax and a lightweight readable codebase.
:checkered_flag: | Fast. 1000 parses -> ~0.3 seconds.
:books: | Best-in-class metadata from Google's libPhoneNumber project.
:trophy: | Fully tested to match the accuracy of Google's JavaScript implementation of libPhoneNumber.
:iphone: | Built for iOS. Automatically grabs the default region code from the phone.
📝 | Editable (!) AsYouType formatter for UITextField.
:us: | Convert country codes to country names and vice versa

## Usage

Import PhoneNumberKit at the top of the Swift file that will interact with a phone number.

```swift
import PhoneNumberKit
```

To parse and validate a string, initialize a PhoneNumber object and supply the string as the rawNumber. The region code is automatically computed but can be overridden if needed. In case of an error, it will throw and you can catch and respond to in your app's UI
```swift
do {
    let phoneNumber = try PhoneNumber(rawNumber:"+33 6 89 017383")
    let phoneNumberCustomDefaultRegion = try PhoneNumber(rawNumber: "+44 20 7031 3000", region: "GB")
}
catch {
    print("Generic parser error")
}
```

If you need to parse and validate a large amount of numbers at once, there is a special function for that and it's lightning fast. The default region code is automatically computed but can be overridden if needed.
```swift
let rawNumberArray = ["0291 12345678", "+49 291 12345678", "04134 1234", "09123 12345"]
let phoneNumbers = PhoneNumberKit().parseMultiple(rawNumberArray)
let phoneNumbersCustomDefaultRegion = PhoneNumberKit().parseMultiple(rawNumberArray, region: "DE")
```

To use the AsYouTypeFormatter, just replace your UITextField with a PhoneNumberTextField (if you are using Interface Builder make sure the module field is set to PhoneNumberKit).

PhoneNumberTextField automatically formats phone numbers and gives the user full editing capabilities. If you want to customize you can use the PartialFormatter directly. The default region code is automatically computed but can be overridden if needed.  

![AsYouTypeFormatter](http://i.giphy.com/3o6gbgrudyCM8Ak6yc.gif)

```swift
let textField = PhoneNumberTextField()

PartialFormatter().formatPartial("+336895555") // +33 6 89 55 55
```

You can also query countries for a dialing code or the dailing code for a given country
```swift
let phoneNumberKit = PhoneNumberKit()
phoneNumberKit.countriesForCode(33)
phoneNumberKit.codeForCountry("FR")
```

Formatting a parsed phone number to a string is also very easy
```swift
phoneNumber.toE164() // +61236618300
phoneNumber.toInternational() // +61 2 3661 8300
phoneNumber.toNational() // (02) 3661 8300
```

You can access the following properties of a PhoneNumber object
```swift
phoneNumber.countryCode
phoneNumber.nationalNumber
phoneNumber.numberExtension
phoneNumber.rawNumber
phoneNumber.type // e.g Mobile or Fixed
phoneNumber.isValidNumber // Checks if number has a known type
```

### Setting up with Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate PhoneNumberKit into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "marmelroy/PhoneNumberKit"
```

### Setting up with [CocoaPods](http://cocoapods.org/?q=PhoneNumberKit)
```ruby
source 'https://github.com/CocoaPods/Specs.git'
pod 'PhoneNumberKit', '~> 0.8'
```
