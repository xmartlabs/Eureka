//
//  InlineRowsExample.swift
//  Example
//
//  Created by Mathias Claassen on 3/15/18.
//  Copyright © 2018 Xmartlabs. All rights reserved.
//

import Eureka

class InlineRowsController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        form.inlineRowHideOptions = InlineRowHideOptions.AnotherInlineRowIsShown.union(.FirstResponderChanges)

        form

            +++ Section("Automatically Hide Inline Rows?")

            <<< SwitchRow() {
                $0.title = "Hides when another inline row is shown"
                $0.value = true
                }
                .onChange { [weak form] in
                    if $0.value == true {
                        form?.inlineRowHideOptions = form?.inlineRowHideOptions?.union(.AnotherInlineRowIsShown)
                    }
                    else {
                        form?.inlineRowHideOptions = form?.inlineRowHideOptions?.subtracting(.AnotherInlineRowIsShown)
                    }
            }

            <<< SwitchRow() {
                $0.title = "Hides when the First Responder changes"
                $0.value = true
                }
                .onChange { [weak form] in
                    if $0.value == true {
                        form?.inlineRowHideOptions = form?.inlineRowHideOptions?.union(.FirstResponderChanges)
                    }
                    else {
                        form?.inlineRowHideOptions = form?.inlineRowHideOptions?.subtracting(.FirstResponderChanges)
                    }
            }

            +++ Section()

            <<< DateInlineRow() {
                $0.title = "DateInlineRow"
                $0.value = Date()
            }

            <<< TimeInlineRow(){
                $0.title = "TimeInlineRow"
                $0.value = Date()
            }

            <<< DateTimeInlineRow(){
                $0.title = "DateTimeInlineRow"
                $0.value = Date()
            }

            <<< CountDownInlineRow(){
                $0.title = "CountDownInlineRow"
                var dateComp = DateComponents()
                dateComp.hour = 18
                dateComp.minute = 33
                dateComp.timeZone = TimeZone.current
                $0.value = Calendar.current.date(from: dateComp)
            }

            +++ Section("Generic inline picker")

            <<< PickerInlineRow<Date>("PickerInlineRow") { (row : PickerInlineRow<Date>) -> Void in
                row.title = row.tag
                row.displayValueFor = { (rowValue: Date?) in
                    return rowValue.map { "Year \(Calendar.current.component(.year, from: $0))" }
                }
                row.options = []
                var date = Date()
                for _ in 1...10{
                    row.options.append(date)
                    date = date.addingTimeInterval(60*60*24*365)
                }
                row.value = row.options[0]
        }
    }
}
