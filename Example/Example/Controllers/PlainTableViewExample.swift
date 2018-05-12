//
//  PlainTableViewExample.swift
//  Example
//
//  Created by Mathias Claassen on 3/15/18.
//  Copyright © 2018 Xmartlabs. All rights reserved.
//

import Eureka

class PlainTableViewStyleController : FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        form +++

            Section()

            <<< TextRow() {
                $0.title = "Name"
                $0.value = "John Doe"
            }

            <<< TextRow() {
                $0.title = "Username"
                $0.value = "johndoe1"
            }

            <<< EmailRow() {
                $0.title = "Email Address"
                $0.value = "john@doe.com"
            }

            <<< PasswordRow() {
                $0.title = "Password"
                $0.value = "johndoe9876"
        }

        // Remove excess separator lines on non-existent cells
        tableView.tableFooterView = UIView()
    }
}
