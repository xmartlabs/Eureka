//
//  FormatterExample.swift
//  Example
//
//  Created by Mathias Claassen on 3/15/18.
//  Copyright © 2018 Xmartlabs. All rights reserved.
//

import Eureka

class FormatterExample : FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        form +++ Section("Number formatters")
            <<< DecimalRow(){
                $0.useFormatterDuringInput = true
                $0.title = "Currency style"
                $0.value = 2015
                let formatter = CurrencyFormatter()
                formatter.locale = .current
                formatter.numberStyle = .currency
                $0.formatter = formatter
            }
            <<< DecimalRow(){
                $0.title = "Scientific style"
                $0.value = 2015
                let formatter = NumberFormatter()
                formatter.locale = .current
                formatter.numberStyle = .scientific
                $0.formatter = formatter
            }
            <<< IntRow(){
                $0.title = "Spell out style"
                $0.value = 2015
                let formatter = NumberFormatter()
                formatter.locale = .current
                formatter.numberStyle = .spellOut
                $0.formatter = formatter
            }
            +++ Section("Date formatters")
            <<< DateRow(){
                $0.title = "Short style"
                $0.value = Date()
                let formatter = DateFormatter()
                formatter.locale = .current
                formatter.dateStyle = .short
                $0.dateFormatter = formatter
            }
            <<< DateRow(){
                $0.title = "Long style"
                $0.value = Date()
                let formatter = DateFormatter()
                formatter.locale = .current
                formatter.dateStyle = .long
                $0.dateFormatter = formatter
            }
            +++ Section("Other formatters")
            <<< DecimalRow(){
                $0.title = "Energy: Jules to calories"
                $0.value = 100.0
                let formatter = EnergyFormatter()
                $0.formatter = formatter
            }
            <<< IntRow(){
                $0.title = "Weight: Kg to lb"
                $0.value = 1000
                $0.formatter = MassFormatter()
        }
    }

    class CurrencyFormatter : NumberFormatter, FormatterProtocol {
        override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, range rangep: UnsafeMutablePointer<NSRange>?) throws {
            guard obj != nil else { return }
            var str = string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
            if !string.isEmpty, numberStyle == .currency && !string.contains(currencySymbol) {
                // Check if the currency symbol is at the last index
                if let formattedNumber = self.string(from: 1), String(formattedNumber[formattedNumber.index(before: formattedNumber.endIndex)...]) == currencySymbol {
                    // This means the user has deleted the currency symbol. We cut the last number and then add the symbol automatically
                    str = String(str[..<str.index(before: str.endIndex)])

                }
            }
            obj?.pointee = NSNumber(value: (Double(str) ?? 0.0)/Double(pow(10.0, Double(minimumFractionDigits))))
        }

        func getNewPosition(forPosition position: UITextPosition, inTextInput textInput: UITextInput, oldValue: String?, newValue: String?) -> UITextPosition {
            return textInput.position(from: position, offset:((newValue?.count ?? 0) - (oldValue?.count ?? 0))) ?? position
        }
    }
}
