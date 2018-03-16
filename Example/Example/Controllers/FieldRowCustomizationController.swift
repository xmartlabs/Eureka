//
//  FieldRowCustomizationController.swift
//  Example
//
//  Created by Mathias Claassen on 3/15/18.
//  Copyright © 2018 Xmartlabs. All rights reserved.
//

import Eureka

class FieldRowCustomizationController : FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        form +++
            Section(header: "Default field rows", footer: "Rows with title have a right-aligned text field.\nRows without title have a left-aligned text field.\nBut this can be changed...")

            <<< NameRow() {
                $0.title = "Your name:"
                $0.placeholder = "(right alignment)"
                }
                .cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "plus_image")
            }

            <<< NameRow() {
                $0.placeholder = "Name (left alignment)"
                }
                .cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "plus_image")
            }

            +++ Section("Customized Alignment")

            <<< NameRow() {
                $0.title = "Your name:"
                }.cellUpdate { cell, row in
                    cell.textField.textAlignment = .left
                    cell.textField.placeholder = "(left alignment)"
            }

            <<< NameRow().cellUpdate { cell, row in
                cell.textField.textAlignment = .right
                cell.textField.placeholder = "Name (right alignment)"
            }

            +++ Section(header: "Customized Text field width", footer: "Eureka allows us to set up a specific UITextField width using textFieldPercentage property. In the section above we have also right aligned the textLabels.")

            <<< NameRow() {
                $0.title = "Title"
                $0.titlePercentage = 0.4
                $0.placeholder = "textFieldPercentage = 0.6"
                }
                .cellUpdate {
                    $1.cell.textField.textAlignment = .left
                    $1.cell.textLabel?.textAlignment = .right
            }
            <<< NameRow() {
                $0.title = "Another Title"
                $0.titlePercentage = 0.4
                $0.placeholder = "textFieldPercentage = 0.6"
                }
                .cellUpdate {
                    $1.cell.textField.textAlignment = .left
                    $1.cell.textLabel?.textAlignment = .right
            }
            <<< NameRow() {
                $0.title = "One more"
                $0.titlePercentage = 0.3
                $0.placeholder = "textFieldPercentage = 0.7"
                }
                .cellUpdate {
                    $1.cell.textField.textAlignment = .left
                    $1.cell.textLabel?.textAlignment = .right
            }

            +++ Section("TextAreaRow")

            <<< TextAreaRow() {
                $0.placeholder = "TextAreaRow"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
        }

    }
}
