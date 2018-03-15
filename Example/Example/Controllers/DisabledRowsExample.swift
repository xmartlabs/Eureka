//
//  DisabledRowsExample.swift
//  Example
//
//  Created by Mathias Claassen on 3/15/18.
//  Copyright © 2018 Xmartlabs. All rights reserved.
//

import Eureka

class DisabledRowsExample : FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        form = Section()

            <<< SegmentedRow<String>("segments"){
                $0.options = ["Enabled", "Disabled"]
                $0.value = "Disabled"
            }

            <<< TextRow(){
                $0.title = "choose enabled, disable above..."
                $0.disabled = "$segments = 'Disabled'"
            }

            <<< SwitchRow("Disable Next Section?"){
                $0.title = $0.tag
                $0.disabled = "$segments = 'Disabled'"
            }

            +++ Section()

            <<< TextRow() {
                $0.title = "Gonna be disabled soon.."
                $0.disabled = Eureka.Condition.function(["Disable Next Section?"], { (form) -> Bool in
                    let row: SwitchRow! = form.rowBy(tag: "Disable Next Section?")
                    return row.value ?? false
                })
            }

            +++ Section()

            <<< SegmentedRow<String>(){
                $0.options = ["Always Disabled"]
                $0.disabled = true
        }
    }
}
