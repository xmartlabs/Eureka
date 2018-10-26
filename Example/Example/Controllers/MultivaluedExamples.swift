//
//  MultivaluedSectionsController.swift
//  Example
//
//  Created by Mathias Claassen on 3/15/18.
//  Copyright © 2018 Xmartlabs. All rights reserved.
//

import Eureka

class MultivaluedSectionsController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Multivalued examples"
        form +++
            Section("Multivalued examples")
            <<< ButtonRow(){
                $0.title = "Multivalued Sections"
                $0.presentationMode = .segueName(segueName: "MultivaluedControllerSegue", onDismiss: nil)
            }
            <<< ButtonRow(){
                $0.title = "Multivalued Only Reorder"
                $0.presentationMode = .segueName(segueName: "MultivaluedOnlyReorderControllerSegue", onDismiss: nil)
            }
            <<< ButtonRow(){
                $0.title = "Multivalued Only Insert"
                $0.presentationMode = .segueName(segueName: "MultivaluedOnlyInsertControllerSegue", onDismiss: nil)
            }
            <<< ButtonRow(){
                $0.title = "Multivalued Only Delete"
                $0.presentationMode = .segueName(segueName: "MultivaluedOnlyDeleteControllerSegue", onDismiss: nil)
        }
    }

}

class MultivaluedController: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Multivalued Examples"
        form +++
            MultivaluedSection(multivaluedOptions: [.Reorder, .Insert, .Delete],
                               header: "Multivalued TextField",
                               footer: ".Insert multivaluedOption adds the 'Add New Tag' button row as last cell.") {
                                $0.tag = "textfields"
                                $0.addButtonProvider = { section in
                                    return ButtonRow(){
                                        $0.title = "Add New Tag"
                                        }.cellUpdate { cell, row in
                                            cell.textLabel?.textAlignment = .left
                                    }
                                }
                                $0.multivaluedRowToInsertAt = { index in
                                    return NameRow() {
                                        $0.placeholder = "Tag Name"
                                    }
                                }
                                $0 <<< NameRow() {
                                    $0.placeholder = "Tag Name"
                                }
            }

            +++

            MultivaluedSection(multivaluedOptions: [.Insert, .Delete],
                               header: "Multivalued ActionSheet Selector example",
                               footer: ".Insert multivaluedOption adds a 'Add' button row as last cell.") {
                                $0.tag = "options"
                                $0.multivaluedRowToInsertAt = { index in
                                    return ActionSheetRow<String>{
                                        $0.title = "Tap to select.."
                                        $0.options = ["Option 1", "Option 2", "Option 3", "Option 4", "Option 5"]
                                    }
                                }
                                $0 <<< ActionSheetRow<String> {
                                    $0.title = "Tap to select.."
                                    $0.options = ["Option 1", "Option 2", "Option 3", "Option 4", "Option 5"]
                                }

            }

            +++

            MultivaluedSection(multivaluedOptions: [.Insert, .Delete, .Reorder],
                               header: "Multivalued Push Selector example",
                               footer: "") {
                                $0.tag = "push"
                                $0.multivaluedRowToInsertAt = { index in
                                    return PushRow<String>{
                                        $0.title = "Tap to select ;)..at \(index)"
                                        $0.options = ["Option 1", "Option 2", "Option 3"]
                                    }
                                }
                                $0 <<< PushRow<String> {
                                    $0.title = "Tap to select ;).."
                                    $0.options = ["Option 1", "Option 2", "Option 3"]
                                }

        }
    }

    @IBAction func save(_ sender: Any) {
        print("\(form.values())")
    }

}

class MultivaluedOnlyReorderController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let secondsPerDay = 24 * 60 * 60
        let list = ["Today", "Yesterday", "Before Yesterday"]

        form +++

            MultivaluedSection(multivaluedOptions: .Reorder,
                               header: "Reordering Selectors",
                               footer: "") {
                                $0 <<< PushRow<String> {
                                    $0.title = "Tap to select ;).."
                                    $0.options = ["Option 1", "Option 2", "Option 3"]
                                    }
                                    <<< PushRow<String> {
                                        $0.title = "Tap to select ;).."
                                        $0.options = ["Option 1", "Option 2", "Option 3"]
                                    }
                                    <<< PushRow<String> {
                                        $0.title = "Tap to select ;).."
                                        $0.options = ["Option 1", "Option 2", "Option 3"]
                                    }
                                    <<< PushRow<String> {
                                        $0.title = "Tap to select ;).."
                                        $0.options = ["Option 1", "Option 2", "Option 3"]
                                }

            }

            +++
            // Multivalued Section with inline rows - section set up to support only reordering
            MultivaluedSection(multivaluedOptions: .Reorder,
                               header: "Reordering Inline Rows",
                               footer: "") { section in
                                list.enumerated().forEach({ offset, string in
                                    let dateInlineRow = DateInlineRow(){
                                        $0.value = Date(timeInterval: Double(-secondsPerDay) * Double(offset), since: Date())
                                        $0.title = string
                                    }
                                    section <<< dateInlineRow
                                })
            }

            +++

            MultivaluedSection(multivaluedOptions: .Reorder,
                               header: "Reordering Field Rows",
                               footer: "")
            <<< NameRow {
                $0.value = "Martin"
            }
            <<< NameRow {
                $0.value = "Mathias"
            }
            <<< NameRow {
                $0.value = "Agustin"
            }
            <<< NameRow {
                $0.value = "Enrique"
        }

    }
}

class MultivaluedOnlyInsertController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Multivalued Only Insert"
        form    +++

            MultivaluedSection(multivaluedOptions: .Insert) { sec in
                sec.addButtonProvider = { _ in return ButtonRow {
                    $0.title = "Add Tag"
                    }.cellUpdate { cell, row in
                        cell.textLabel?.textAlignment = .left
                    }
                }
                sec.multivaluedRowToInsertAt = { index in
                    return TextRow {
                        $0.placeholder = "Tag Name"
                    }
                }
                sec.showInsertIconInAddButton = false
            }

            +++

            MultivaluedSection(multivaluedOptions: .Insert, header: "Insert With Inline Cells") {
                $0.multivaluedRowToInsertAt = { index in
                    return DateInlineRow {
                        $0.title = "Date"
                        $0.value = Date()
                    }
                }
        }
    }
}

class MultivaluedOnlyDeleteController: FormViewController {

    @IBOutlet weak var editButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isEditing = false
        let nameList = ["family", "male", "female", "client"]

        let section = MultivaluedSection(multivaluedOptions: .Delete)


        for tag in nameList {
            section <<< TextRow {
                $0.placeholder = "Tag Name"
                $0.value = tag
            }
        }


        let section2 =  MultivaluedSection(multivaluedOptions: .Delete, footer: "")
        for _ in 1..<4 {
            section2 <<< PickerInlineRow<String> {
                $0.title = "Tap to select"
                $0.value = "client"
                $0.options = nameList
            }
        }

        editButton.title = tableView.isEditing ? "Done" : "Edit"
        editButton.target = self
        editButton.action = #selector(editPressed(sender:))

        form    +++

            section

            +++

        section2
    }

    @objc func editPressed(sender: UIBarButtonItem){
        tableView.setEditing(!tableView.isEditing, animated: true)
        editButton.title = tableView.isEditing ? "Done" : "Edit"

    }
}
