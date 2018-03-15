//
//  NavigationAccessoryController.swift
//  Example
//
//  Created by Mathias Claassen on 3/15/18.
//  Copyright © 2018 Xmartlabs. All rights reserved.
//

import Eureka

class NavigationAccessoryController : FormViewController {

    var navigationOptionsBackup : RowNavigationOptions?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationOptions = RowNavigationOptions.Enabled.union(.SkipCanNotBecomeFirstResponderRow)
        navigationOptionsBackup = navigationOptions

        form = Section(header: "Settings", footer: "These settings change how the navigation accessory view behaves")

            <<< SwitchRow("set_none") { [weak self] in
                $0.title = "Navigation accessory view"
                $0.value = self?.navigationOptions != .Disabled
                }.onChange { [weak self] in
                    if $0.value ?? false {
                        self?.navigationOptions = self?.navigationOptionsBackup
                        self?.form.rowBy(tag: "set_disabled")?.baseValue = self?.navigationOptions?.contains(.StopDisabledRow)
                        self?.form.rowBy(tag: "set_skip")?.baseValue = self?.navigationOptions?.contains(.SkipCanNotBecomeFirstResponderRow)
                        self?.form.rowBy(tag: "set_disabled")?.updateCell()
                        self?.form.rowBy(tag: "set_skip")?.updateCell()
                    }
                    else {
                        self?.navigationOptionsBackup = self?.navigationOptions
                        self?.navigationOptions = .Disabled
                    }
            }

            <<< CheckRow("set_disabled") { [weak self] in
                $0.title = "Stop at disabled row"
                $0.value = self?.navigationOptions?.contains(.StopDisabledRow)
                $0.hidden = "$set_none == false" // .Predicate(NSPredicate(format: "$set_none == false"))
                }.onChange { [weak self] row in
                    if row.value ?? false {
                        self?.navigationOptions = self?.navigationOptions?.union(.StopDisabledRow)
                    }
                    else{
                        self?.navigationOptions = self?.navigationOptions?.subtracting(.StopDisabledRow)
                    }
            }

            <<< CheckRow("set_skip") { [weak self] in
                $0.title = "Skip non first responder view"
                $0.value = self?.navigationOptions?.contains(.SkipCanNotBecomeFirstResponderRow)
                $0.hidden = "$set_none  == false"
                }.onChange { [weak self] row in
                    if row.value ?? false {
                        self?.navigationOptions = self?.navigationOptions?.union(.SkipCanNotBecomeFirstResponderRow)
                    }
                    else{
                        self?.navigationOptions = self?.navigationOptions?.subtracting(.SkipCanNotBecomeFirstResponderRow)
                    }
            }


            +++

            NameRow() { $0.title = "Your name:" }

            <<< PasswordRow() { $0.title = "Your password:" }

            +++
            Section()

            <<< SegmentedRow<Emoji>() {
                $0.title = "Favourite food:"
                $0.options = [🐗, 🐖, 🐡, 🍐]
            }

            <<< PhoneRow() { $0.title = "Your phone number" }

            <<< URLRow() {
                $0.title = "Disabled"
                $0.disabled = true
            }

            <<< TextRow() { $0.title = "Your father's name"}

            <<< TextRow(){ $0.title = "Your mother's name"}
    }
}
