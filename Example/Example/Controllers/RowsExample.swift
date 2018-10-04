//
//  RowsExample.swift
//  Example
//
//  Created by Mathias Claassen on 3/15/18.
//  Copyright © 2018 Xmartlabs. All rights reserved.
//

import CoreLocation
import Eureka

//Mark: RowsExampleViewController

class RowsExampleViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        URLRow.defaultCellUpdate = { cell, row in cell.textField.textColor = .blue }
        LabelRow.defaultCellUpdate = { cell, row in cell.detailTextLabel?.textColor = .orange  }
        CheckRow.defaultCellSetup = { cell, row in cell.tintColor = .orange }
        DateRow.defaultRowInitializer = { row in row.minimumDate = Date() }

        form +++

            Section()

            <<< LabelRow () {
                $0.title = "LabelRow"
                $0.value = "tap the row"
                }
                .onCellSelection { cell, row in
                    row.title = (row.title ?? "") + " 🇺🇾 "
                    row.reload() // or row.updateCell()
            }

            <<< DateRow() { $0.value = Date(); $0.title = "DateRow" }

            <<< CheckRow() {
                $0.title = "CheckRow"
                $0.value = true
            }

            <<< SwitchRow() {
                $0.title = "SwitchRow"
                $0.value = true
            }

            <<< SliderRow() {
                $0.title = "SliderRow"
                $0.value = 5.0
            }
            .cellSetup { cell, row in
                cell.imageView?.image = #imageLiteral(resourceName: "selected")
            }

            <<< StepperRow() {
                $0.title = "StepperRow"
                $0.value = 1.0
            }

            +++ Section("SegmentedRow examples")

            <<< SegmentedRow<String>() { $0.options = ["One", "Two", "Three"] }

            <<< SegmentedRow<Emoji>(){
                $0.title = "Who are you?"
                $0.options = [💁🏻, 🍐, 👦🏼, 🐗, 🐼, 🐻 ]
                $0.value = 🍐
            }

            <<< SegmentedRow<String>(){
                $0.title = "SegmentedRow"
                $0.options = ["One", "Two"]
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "plus_image")
            }

            <<< SegmentedRow<String>(){
                $0.options = ["One", "Two", "Three", "Four"]
                $0.value = "Three"
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "plus_image")
            }

            <<< SegmentedRow<UIImage>(){
                let names = ["selected", "plus_image", "unselected"]
                $0.options = names.map { UIImage(named: $0)! }
                $0.value = $0.options?.last
            }

            +++ Section("Selectors Rows Examples")

            <<< ActionSheetRow<String>() {
                $0.title = "ActionSheetRow"
                $0.selectorTitle = "Your favourite player?"
                $0.options = ["Diego Forlán", "Edinson Cavani", "Diego Lugano", "Luis Suarez"]
                $0.value = "Luis Suarez"
                }
                .onPresent { from, to in
                    to.popoverPresentationController?.permittedArrowDirections = .up
            }

            <<< AlertRow<Emoji>() {
                $0.title = "AlertRow"
                $0.cancelTitle = "Dismiss"
                $0.selectorTitle = "Who is there?"
                $0.options = [💁🏻, 🍐, 👦🏼, 🐗, 🐼, 🐻]
                $0.value = 👦🏼
                }.onChange { row in
                    print(row.value ?? "No Value")
                }
                .onPresent{ _, to in
                    to.view.tintColor = .purple
            }

            <<< PushRow<Emoji>() {
                $0.title = "PushRow"
                $0.options = [💁🏻, 🍐, 👦🏼, 🐗, 🐼, 🐻]
                $0.value = 👦🏼
                $0.selectorTitle = "Choose an Emoji!"
                }.onPresent { from, to in
                    to.dismissOnSelection = false
                    to.dismissOnChange = false
            }

            <<< PushRow<Emoji>() {
                $0.title = "SectionedPushRow"
                $0.options = [💁🏻, 🍐, 👦🏼, 🐗, 🐼, 🐻]
                $0.value = 👦🏼
                $0.selectorTitle = "Choose an Emoji!"
                }.onPresent { from, to in
                    to.dismissOnSelection = false
                    to.dismissOnChange = false
                    to.sectionKeyForValue = { option in
                        switch option {
                        case 💁🏻, 👦🏼: return "People"
                        case 🐗, 🐼, 🐻: return "Animals"
                        case 🍐: return "Food"
                        default: return ""
                        }
                    }
            }
            <<< PushRow<Emoji>() {
                $0.title = "LazySectionedPushRow"
                $0.value = 👦🏼
                $0.selectorTitle = "Choose a lazy Emoji!"
                $0.optionsProvider = .lazy({ (form, completion) in
                    let activityView = UIActivityIndicatorView(style: .gray)
                    form.tableView.backgroundView = activityView
                    activityView.startAnimating()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                        form.tableView.backgroundView = nil
                        completion([💁🏻, 🍐, 👦🏼, 🐗, 🐼, 🐻])
                    })
                })
                }
                .onPresent { from, to in
                    to.sectionKeyForValue = { option -> String in
                        switch option {
                        case 💁🏻, 👦🏼: return "People"
                        case 🐗, 🐼, 🐻: return "Animals"
                        case 🍐: return "Food"
                        default: return ""
                        }
                    }
        }

            <<< PushRow<Emoji>() {
                $0.title = "Custom Cell Push Row"
                $0.options = [💁🏻, 🍐, 👦🏼, 🐗, 🐼, 🐻]
                $0.value = 👦🏼
                $0.selectorTitle = "Choose an Emoji!"
                }
                .onPresent { from, to in
                    to.selectableRowSetup = { row in
                        row.cellProvider = CellProvider<ListCheckCell<Emoji>>(nibName: "EmojiCell", bundle: Bundle.main)
                    }
                    to.selectableRowCellUpdate = { cell, row in
                        var detailText: String?
                        switch row.selectableValue {
                        case 💁🏻, 👦🏼: detailText = "Person"
                        case 🐗, 🐼, 🐻: detailText = "Animal"
                        case 🍐: detailText = "Food"
                        default: detailText = ""
                        }
                        cell.detailTextLabel?.text = detailText
                    }
        }


        if UIDevice.current.userInterfaceIdiom == .pad {
            let section = form.last!

            section <<< PopoverSelectorRow<Emoji>() {
                $0.title = "PopoverSelectorRow"
                $0.options = [💁🏻, 🍐, 👦🏼, 🐗, 🐼, 🐻]
                $0.value = 💁🏻
                $0.selectorTitle = "Choose an Emoji!"
            }
        }

        let section = form.last!

        section
            <<< LocationRow(){
                $0.title = "LocationRow"
                $0.value = CLLocation(latitude: -34.91, longitude: -56.1646)
            }

            <<< ImageRow(){
                $0.title = "ImageRow"
            }

            <<< MultipleSelectorRow<Emoji>() {
                $0.title = "MultipleSelectorRow"
                $0.options = [💁🏻, 🍐, 👦🏼, 🐗, 🐼, 🐻]
                $0.value = [👦🏼, 🍐, 🐗]
                }
                .onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(RowsExampleViewController.multipleSelectorDone(_:)))
            }

            <<< MultipleSelectorRow<Emoji>() {
                $0.title = "SectionedMultipleSelectorRow"
                $0.options = [💁🏻, 🍐, 👦🏼, 🐗, 🐼, 🐻]
                $0.value = [👦🏼, 🍐, 🐗]
                }
                .onPresent { from, to in
                    to.sectionKeyForValue = { option in
                        switch option {
                        case 💁🏻, 👦🏼: return "People"
                        case 🐗, 🐼, 🐻: return "Animals"
                        case 🍐: return "Food"
                        default: return ""
                        }
                    }
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(RowsExampleViewController.multipleSelectorDone(_:)))
            }
            <<< MultipleSelectorRow<Emoji>() {
                $0.title = "LazyMultipleSelectorRow"
                $0.value = [👦🏼, 🍐, 🐗]
                $0.optionsProvider = .lazy({ (form, completion) in
                    let activityView = UIActivityIndicatorView(style: .gray)
                    form.tableView.backgroundView = activityView
                    activityView.startAnimating()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                        form.tableView.backgroundView = nil
                        completion([💁🏻, 🍐, 👦🏼, 🐗, 🐼, 🐻])
                    })
                })
                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(RowsExampleViewController.multipleSelectorDone(_:)))
        }

        form +++ Section("Generic picker")

            <<< PickerRow<String>("Picker Row") { (row : PickerRow<String>) -> Void in

                row.options = []
                for i in 1...10{
                    row.options.append("option \(i)")
                }
            }

            <<< PickerInputRow<String>("Picker Input Row"){
                $0.title = "Options"
                $0.options = []
                for i in 1...10{
                    $0.options.append("option \(i)")
                }
                $0.value = $0.options.first
            }
            
            <<< DoublePickerInlineRow<String, Int>() {
                $0.title = "2 Component picker"
                $0.firstOptions = { return ["a", "b", "c"]}
                $0.secondOptions = { _ in return [1, 2, 3]}
            }
            <<< TriplePickerInputRow<String, String, Int>() {
                $0.firstOptions = { return ["a", "b", "c"]}
                $0.secondOptions = { return [$0, $0 + $0, $0 + "-" + $0, "asd"]}
                $0.thirdOptions = { _,_ in return [1, 2, 3]}
                $0.title = "3 Component picker"
            }

            +++ Section("FieldRow examples")

            <<< TextRow() {
                $0.title = "TextRow"
                $0.placeholder = "Placeholder"
            }

            <<< DecimalRow() {
                $0.title = "DecimalRow"
                $0.value = 5
                $0.formatter = DecimalFormatter()
                $0.useFormatterDuringInput = true
                //$0.useFormatterOnDidBeginEditing = true
                }.cellSetup { cell, _  in
                    cell.textField.keyboardType = .numberPad
            }

            <<< URLRow() {
                $0.title = "URLRow"
                $0.value = URL(string: "http://xmartlabs.com")
            }

            <<< PhoneRow() {
                $0.title = "PhoneRow (disabled)"
                $0.value = "+598 9898983510"
                $0.disabled = true
            }

            <<< NameRow() {
                $0.title =  "NameRow"
            }

            <<< PasswordRow() {
                $0.title = "PasswordRow"
                $0.value = "password"
            }

            <<< IntRow() {
                $0.title = "IntRow"
                $0.value = 2015
            }

            <<< EmailRow() {
                $0.title = "EmailRow"
                $0.value = "a@b.com"
            }

            <<< TwitterRow() {
                $0.title = "TwitterRow"
                $0.value = "@xmartlabs"
            }

            <<< AccountRow() {
                $0.title = "AccountRow"
                $0.placeholder = "Placeholder"
            }

            <<< ZipCodeRow() {
                $0.title = "ZipCodeRow"
                $0.placeholder = "90210"
        }
    }

    @objc func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }

}
