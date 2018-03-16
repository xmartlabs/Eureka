//
//  CustomDesignController.swift
//  Example
//
//  Created by Mathias Claassen on 3/15/18.
//  Copyright © 2018 Xmartlabs. All rights reserved.
//

import Eureka

class CustomDesignController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        form +++
            Section()
            <<< SwitchRow() {
                $0.cellProvider = CellProvider<SwitchCell>(nibName: "SwitchCell", bundle: Bundle.main)
                $0.cell.height = { 67 }
            }

            <<< DatePickerRow() {
                $0.cellProvider = CellProvider<DatePickerCell>(nibName: "DatePickerCell", bundle: Bundle.main)
                $0.cell.height = { 345 }
            }

            <<< TextRow() {
                $0.cellProvider = CellProvider<TextCell>(nibName: "TextCell", bundle: Bundle.main)
                $0.cell.height = { 199 }
                }
                .onChange { row in
                    if let textView = row.cell.viewWithTag(99) as? UITextView {
                        textView.text = row.cell.textField.text
                    }
        }
    }
}
