//  ViewController.swift
//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2016 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import Eureka
import CoreLocation

//MARK: HomeViewController

class HomeViewController : FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        ImageRow.defaultCellUpdate = { cell, row in
           cell.accessoryView?.layer.cornerRadius = 17
           cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        }
        
        form =
            
            Section() {
                $0.header = HeaderFooterView<EurekaLogoView>(.class)
            }
        
                <<< ButtonRow("Rows") {
                        $0.title = $0.tag
                        $0.presentationMode = .segueName(segueName: "RowsExampleViewControllerSegue", onDismiss: nil)
                    }
            
                <<< ButtonRow("Native iOS Event Form") { row in
                        row.title = row.tag
                        row.presentationMode = .segueName(segueName: "NativeEventsFormNavigationControllerSegue", onDismiss:{  vc in vc.dismiss(animated: true) })
                    }
            
                <<< ButtonRow("Accesory View Navigation") { (row: ButtonRow) in
                        row.title = row.tag
                        row.presentationMode = .segueName(segueName: "AccesoryViewControllerSegue", onDismiss: nil)
                    }
            
                <<< ButtonRow("Custom Cells") { (row: ButtonRow) -> () in
                        row.title = row.tag
                        row.presentationMode = .segueName(segueName: "CustomCellsControllerSegue", onDismiss: nil)
                    }
            
                <<< ButtonRow("Customization of rows with text input") { (row: ButtonRow) -> Void in
                        row.title = row.tag
                        row.presentationMode = .segueName(segueName: "FieldCustomizationControllerSegue", onDismiss: nil)
                    }
            
                <<< ButtonRow("Hidden rows") { (row: ButtonRow) -> Void in
                    row.title = row.tag
                    row.presentationMode = .segueName(segueName: "HiddenRowsControllerSegue", onDismiss: nil)
                    }
            
                <<< ButtonRow("Disabled rows") { (row: ButtonRow) -> Void in
                    row.title = row.tag
                    row.presentationMode = .segueName(segueName: "DisabledRowsControllerSegue", onDismiss: nil)
                }
            
                <<< ButtonRow("Formatters") { (row: ButtonRow) -> Void in
                    row.title = row.tag
                    row.presentationMode = .segueName(segueName: "FormattersControllerSegue", onDismiss: nil)
                }
        
                <<< ButtonRow("Inline rows") { (row: ButtonRow) -> Void in
                    row.title = row.tag
                    row.presentationMode = .segueName(segueName: "InlineRowsControllerSegue", onDismiss: nil)
                }
                <<< ButtonRow("List Sections") { (row: ButtonRow) -> Void in
                    row.title = row.tag
                    row.presentationMode = .segueName(segueName: "ListSectionsControllerSegue", onDismiss: nil)
                }
                <<< ButtonRow("Validations") { (row: ButtonRow) -> Void in
                    row.title = row.tag
                    row.presentationMode = .segueName(segueName: "ValidationsControllerSegue", onDismiss: nil)
                }
        +++ Section()
                <<< ButtonRow() { (row: ButtonRow) -> Void in
                   row.title = "About"
                }
                .onCellSelection { [weak self] (cell, row) in
                    self?.showAlert()
                }
    }
    
    
    @IBAction func showAlert() {
        let alertController = UIAlertController(title: "OnCellSelection", message: "Button Row Action", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true)
        
    }
    
}
//MARK: Emoji

typealias Emoji = String
let 👦🏼 = "👦🏼", 🍐 = "🍐", 💁🏻 = "💁🏻", 🐗 = "🐗", 🐼 = "🐼", 🐻 = "🐻", 🐖 = "🐖", 🐡 = "🐡"

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
            
            +++ Section("Selectors Rows Examples")
                
                <<< ActionSheetRow<String>() {
                        $0.title = "ActionSheetRow"
                        $0.selectorTitle = "Your favourite player?"
                        $0.options = ["Diego Forlán", "Edinson Cavani", "Diego Lugano", "Luis Suarez"]
                        $0.value = "Luis Suarez"
                    }
                
                <<< AlertRow<Emoji>() {
                        $0.title = "AlertRow"
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
                    }

                <<< PushRow<Emoji>() {
                    $0.title = "SectionedPushRow"
                    $0.options = [💁🏻, 🍐, 👦🏼, 🐗, 🐼, 🐻]
                    $0.value = 👦🏼
                    $0.selectorTitle = "Choose an Emoji!"
                    }.onPresent { from, to in
                        to.sectionKeyForValue = { option in
                            switch option {
                            case 💁🏻, 👦🏼: return "People"
                            case 🐗, 🐼, 🐻: return "Animals"
                            case 🍐: return "Food"
                            default: return ""
                            }
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
	
    func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
}

//MARK: Custom Cells Example

class CustomCellsController : FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++
            Section() {
                var header = HeaderFooterView<EurekaLogoViewNib>(.nibFile(name: "EurekaSectionHeader", bundle: nil))
                header.onSetupView = { (view, section) -> () in
                                            view.imageView.alpha = 0;
                                            UIView.animate(withDuration: 2.0, animations: { [weak view] in
                                                view?.imageView.alpha = 1
                                            })
                                            view.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1)
                                            UIView.animate(withDuration: 1.0, animations: { [weak view] in
                                                view?.layer.transform = CATransform3DIdentity
                                            })
                                     }
                $0.header = header
            }
            +++ Section("WeekDay cell")
            
                <<< WeekDayRow(){
                    $0.value = [.monday, .wednesday, .friday]
                }
               
                <<< TextFloatLabelRow() {
                    $0.title = "Float Label Row, type something to see.."
                }
        
                <<< IntFloatLabelRow() {
                    $0.title = "Float Label Row, type something to see.."
                }
    }
}

//MARK: Field row customization Example
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
                    $0.textFieldPercentage = 0.6
                    $0.placeholder = "textFieldPercentage = 0.6"
                }
                .cellUpdate {
                    $1.cell.textField.textAlignment = .left
                    $1.cell.textLabel?.textAlignment = .right
                }
                <<< NameRow() {
                    $0.title = "Another Title"
                    $0.textFieldPercentage = 0.6
                    $0.placeholder = "textFieldPercentage = 0.6"
                }
                .cellUpdate {
                    $1.cell.textField.textAlignment = .left
                    $1.cell.textLabel?.textAlignment = .right
                }
                <<< NameRow() {
                    $0.title = "One more"
                    $0.textFieldPercentage = 0.7
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


//MARK: Navigation Accessory View Example

class NavigationAccessoryController : FormViewController {
    
    var navigationOptionsBackup : RowNavigationOptions?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationOptions = RowNavigationOptions.Enabled.union(.SkipCanNotBecomeFirstResponderRow)
        navigationOptionsBackup = navigationOptions
        
        form = Section(header: "Settings", footer: "These settings change how the navigation accessory view behaves")
            
             <<< SwitchRow("set_none") {
                    $0.title = "Navigation accessory view"
                    $0.value = self.navigationOptions != .Disabled
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

            <<< CheckRow("set_disabled") {
                    $0.title = "Stop at disabled row"
                    $0.value = self.navigationOptions?.contains(.StopDisabledRow)
                    $0.hidden = "$set_none == false" // .Predicate(NSPredicate(format: "$set_none == false"))
                }.onChange { [weak self] row in
                    if row.value ?? false {
                        self?.navigationOptions = self?.navigationOptions?.union(.StopDisabledRow)
                    }
                    else{
                        self?.navigationOptions = self?.navigationOptions?.subtracting(.StopDisabledRow)
                    }
                }

            <<< CheckRow("set_skip") {
                    $0.title = "Skip non first responder view"
                    $0.value = self.navigationOptions?.contains(.SkipCanNotBecomeFirstResponderRow)
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

//MARK: Native Event Example

class NativeEventNavigationController: UINavigationController, RowControllerType {
    var onDismissCallback : ((UIViewController) -> ())?
}

class NativeEventFormViewController : FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeForm()
        
        self.navigationItem.leftBarButtonItem?.target = self
        self.navigationItem.leftBarButtonItem?.action = #selector(NativeEventFormViewController.cancelTapped(_:))
    }
    
    private func initializeForm() {
        
        form =
            
                TextRow("Title").cellSetup { cell, row in
                    cell.textField.placeholder = row.tag
                }
            
            <<< TextRow("Location").cellSetup {
                    $1.cell.textField.placeholder = $0.row.tag
                }
        
            +++
    
                SwitchRow("All-day") {
                    $0.title = $0.tag
                }.onChange { [weak self] row in
                    let startDate: DateTimeInlineRow! = self?.form.rowBy(tag: "Starts")
                    let endDate: DateTimeInlineRow! = self?.form.rowBy(tag: "Ends")
                    
                    if row.value ?? false {
                        startDate.dateFormatter?.dateStyle = .medium
                        startDate.dateFormatter?.timeStyle = .none
                        endDate.dateFormatter?.dateStyle = .medium
                        endDate.dateFormatter?.timeStyle = .none
                    }
                    else {
                        startDate.dateFormatter?.dateStyle = .short
                        startDate.dateFormatter?.timeStyle = .short
                        endDate.dateFormatter?.dateStyle = .short
                        endDate.dateFormatter?.timeStyle = .short
                    }
                    startDate.updateCell()
                    endDate.updateCell()
                    startDate.inlineRow?.updateCell()
                    endDate.inlineRow?.updateCell()
                }
        
            <<< DateTimeInlineRow("Starts") {
                    $0.title = $0.tag
                    $0.value = Date().addingTimeInterval(60*60*24)
                }
                .onChange { [weak self] row in
                    let endRow: DateTimeInlineRow! = self?.form.rowBy(tag: "Ends")
                    if row.value?.compare(endRow.value!) == .orderedDescending {
                        endRow.value = Date(timeInterval: 60*60*24, since: row.value!)
                        endRow.cell!.backgroundColor = .white
                        endRow.updateCell()
                    }
                }
                .onExpandInlineRow { cell, row, inlineRow in
                    inlineRow.cellUpdate { [weak self] cell, dateRow in
                        let allRow: SwitchRow! = self?.form.rowBy(tag: "All-day")
                        if allRow.value ?? false {
                            cell.datePicker.datePickerMode = .date
                        }
                        else {
                            cell.datePicker.datePickerMode = .dateAndTime
                        }
                    }
                    let color = cell.detailTextLabel?.textColor
                    row.onCollapseInlineRow { cell, _, _ in
                        cell.detailTextLabel?.textColor = color
                    }
                    cell.detailTextLabel?.textColor = cell.tintColor
                }
            
            <<< DateTimeInlineRow("Ends"){
                    $0.title = $0.tag
                    $0.value = Date().addingTimeInterval(60*60*25)
                }
                .onChange { [weak self] row in
                    let startRow: DateTimeInlineRow! = self?.form.rowBy(tag: "Starts")
                    if row.value?.compare(startRow.value!) == .orderedAscending {
                        row.cell!.backgroundColor = .red
                    }
                    else{
                        row.cell!.backgroundColor = .white
                    }
                    row.updateCell()
                }
                .onExpandInlineRow { cell, row, inlineRow in
                    inlineRow.cellUpdate { [weak self] cell, dateRow in
                        let allRow: SwitchRow! = self?.form.rowBy(tag: "All-day")
                        if allRow.value ?? false {
                            cell.datePicker.datePickerMode = .date
                        }
                        else {
                            cell.datePicker.datePickerMode = .dateAndTime
                        }
                    }
                    let color = cell.detailTextLabel?.textColor
                    row.onCollapseInlineRow { cell, _, _ in
                        cell.detailTextLabel?.textColor = color
                    }
                    cell.detailTextLabel?.textColor = cell.tintColor
                }
        
        form +++

                PushRow<RepeatInterval>("Repeat") {
                    $0.title = $0.tag
                    $0.options = RepeatInterval.allValues
                    $0.value = .Never
                }.onPresent({ (_, vc) in
                    vc.enableDeselection = false
                    vc.dismissOnSelection = false
                })
        
        form +++
            
            PushRow<EventAlert>() {
                $0.title = "Alert"
                $0.options = EventAlert.allValues
                $0.value = .Never
            }
            .onChange { [weak self] row in
                if row.value == .Never {
                    if let second : PushRow<EventAlert> = self?.form.rowBy(tag: "Another Alert"), let secondIndexPath = second.indexPath {
                        row.section?.remove(at: secondIndexPath.row)
                    }
                }
                else{
                    guard let _ : PushRow<EventAlert> = self?.form.rowBy(tag: "Another Alert") else {
                        let second = PushRow<EventAlert>("Another Alert") {
                            $0.title = $0.tag
                            $0.value = .Never
                            $0.options = EventAlert.allValues
                        }
                        row.section?.insert(second, at: row.indexPath!.row + 1)
                        return
                    }
                }
            }
        
        form +++
            
            PushRow<EventState>("Show As") {
                $0.title = "Show As"
                $0.options = EventState.allValues
            }
        
        form +++
            
            URLRow("URL") {
                $0.placeholder = "URL"
            }
        
            <<< TextAreaRow("notes") {
                    $0.placeholder = "Notes"
                    $0.textAreaHeight = .dynamic(initialTextViewHeight: 50)
                }
        
    }
    
    func cancelTapped(_ barButtonItem: UIBarButtonItem) {
        (navigationController as? NativeEventNavigationController)?.onDismissCallback?(self)
    }
 
    enum RepeatInterval : String, CustomStringConvertible {
        case Never = "Never"
        case Every_Day = "Every Day"
        case Every_Week = "Every Week"
        case Every_2_Weeks = "Every 2 Weeks"
        case Every_Month = "Every Month"
        case Every_Year = "Every Year"
        
        var description : String { return rawValue }
        
        static let allValues = [Never, Every_Day, Every_Week, Every_2_Weeks, Every_Month, Every_Year]
    }
    
    enum EventAlert : String, CustomStringConvertible {
        case Never = "None"
        case At_time_of_event = "At time of event"
        case Five_Minutes = "5 minutes before"
        case FifTeen_Minutes = "15 minutes before"
        case Half_Hour = "30 minutes before"
        case One_Hour = "1 hour before"
        case Two_Hour = "2 hours before"
        case One_Day = "1 day before"
        case Two_Days = "2 days before"
        
        var description : String { return rawValue }
        
        static let allValues = [Never, At_time_of_event, Five_Minutes, FifTeen_Minutes, Half_Hour, One_Hour, Two_Hour, One_Day, Two_Days]
    }
    
    enum EventState {
        case busy
        case free
        
        static let allValues = [busy, free]
    }
}


//MARK: HiddenRowsExample

class HiddenRowsExample : FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TextRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.font = UIFont.italicSystemFont(ofSize: 12)
        }
        
        form = Section("What do you want to talk about:")
                <<< SegmentedRow<String>("segments"){
                        $0.options = ["Sport", "Music", "Films"]
                        $0.value = "Films"
                    }
            +++ Section(){
                    $0.tag = "sport_s"
                    $0.hidden = "$segments != 'Sport'" // .Predicate(NSPredicate(format: "$segments != 'Sport'"))
                }
                <<< TextRow(){
                    $0.title = "Which is your favourite soccer player?"
                }
            
                <<< TextRow(){
                    $0.title = "Which is your favourite coach?"
                }
            
                <<< TextRow(){
                    $0.title = "Which is your favourite team?"
                }
            
            +++ Section(){
                    $0.tag = "music_s"
                    $0.hidden = "$segments != 'Music'"
                }
                <<< TextRow(){
                    $0.title = "Which music style do you like most?"
                }
                
                <<< TextRow(){
                    $0.title = "Which is your favourite singer?"
                }
                <<< TextRow(){
                    $0.title = "How many CDs have you got?"
                }
            
            +++ Section(){
                    $0.tag = "films_s"
                    $0.hidden = "$segments != 'Films'"
                }
                <<< TextRow(){
                    $0.title = "Which is your favourite actor?"
                }
                
                <<< TextRow(){
                    $0.title = "Which is your favourite film?"
                }
        
            +++ Section()
        
                <<< SwitchRow("Show Next Row"){
                    $0.title = $0.tag
                }
                <<< SwitchRow("Show Next Section"){
                    $0.title = $0.tag
                    $0.hidden = .function(["Show Next Row"], { form -> Bool in
                        let row: RowOf<Bool>! = form.rowBy(tag: "Show Next Row")
                        return row.value ?? false == false
                    })
                }
        
            +++ Section(footer: "This section is shown only when 'Show Next Row' switch is enabled"){
                    $0.hidden = .function(["Show Next Section"], { form -> Bool in
                        let row: RowOf<Bool>! = form.rowBy(tag: "Show Next Section")
                        return row.value ?? false == false
                    })
                }
                <<< TextRow() {
                    $0.placeholder = "Gonna dissapear soon!!"
                }
    }
}

//MARK: DisabledRowsExample

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

//MARK: FormatterExample

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
            let str = string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
            obj?.pointee = NSNumber(value: (Double(str) ?? 0.0)/Double(pow(10.0, Double(minimumFractionDigits))))
        }
        
        func getNewPosition(forPosition position: UITextPosition, inTextInput textInput: UITextInput, oldValue: String?, newValue: String?) -> UITextPosition {
            return textInput.position(from: position, offset:((newValue?.characters.count ?? 0) - (oldValue?.characters.count ?? 0))) ?? position
        }
    }
}

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

class ListSectionsController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let continents = ["Africa", "Antarctica", "Asia", "Australia", "Europe", "North America", "South America"]
        
        form +++ SelectableSection<ImageCheckRow<String>>() { section in
            section.header = HeaderFooterView(title: "Where do you live?")
        }
        
        for option in continents {
            form.last! <<< ImageCheckRow<String>(option){ lrow in
                lrow.title = option
                lrow.selectableValue = option
                lrow.value = nil
            }
        }
        
        let oceans = ["Arctic", "Atlantic", "Indian", "Pacific", "Southern"]
        
        form +++ SelectableSection<ImageCheckRow<String>>("And which of the following oceans have you taken a bath in?", selectionType: .multipleSelection)
        for option in oceans {
            form.last! <<< ImageCheckRow<String>(option){ lrow in
                lrow.title = option
                lrow.selectableValue = option
                lrow.value = nil
            }.cellSetup { cell, _ in
                cell.trueImage = UIImage(named: "selectedRectangle")!
                cell.falseImage = UIImage(named: "unselectedRectangle")!
            }
        }
    }
    
    override func valueHasBeenChanged(for row: BaseRow, oldValue: Any?, newValue: Any?) {
        if row.section === form[0] {
            print("Single Selection:\((row.section as! SelectableSection<ImageCheckRow<String>>).selectedRow()?.baseValue)")
        }
        else if row.section === form[1] {
            print("Mutiple Selection:\((row.section as! SelectableSection<ImageCheckRow<String>>).selectedRows().map({$0.baseValue}))")
        }
    }
}

class ValidationsController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
            
        }
        
        TextRow.defaultCellUpdate = { cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .red
            }
        }
        
        form
            +++ Section(header: "Required Rule", footer: "Options: Validates on change")
            
                    <<< TextRow() {
                        $0.title = "Required Rule"
                        $0.add(rule: RuleRequired())
                        $0.validationOptions = .validatesOnChange
                    }
            
            
            +++ Section(header: "Email Rule, Required Rule", footer: "Options: Validates on change after blurred")
            
                    <<< TextRow() {
                        $0.title = "Email Rule"
                        $0.add(rule: RuleRequired())
                        var ruleSet = RuleSet<String>()
                        ruleSet.add(rule: RuleRequired())
                        ruleSet.add(rule: RuleEmail())
                        $0.add(ruleSet: ruleSet)
                        $0.validationOptions = .validatesOnChangeAfterBlurred
                    }
    
            +++ Section(header: "URL Rule", footer: "Options: Validates on change")
        
                    <<< URLRow() {
                        $0.title = "URL Rule"
                        $0.add(rule: RuleURL())
                        $0.validationOptions = .validatesOnChange
                    }
                    .cellUpdate { cell, row in
                        if !row.isValid {
                            cell.titleLabel?.textColor = .red
                        }
                    }
        
            
            +++ Section(header: "MinLength 8 Rule, MaxLength 13 Rule", footer: "Options: Validates on blurred")
                    <<< PasswordRow() {
                        $0.title = "Password"
                        $0.add(rule: RuleMinLength(minLength: 8))
                        $0.add(rule: RuleMaxLength(maxLength: 13))
                    }
                    .cellUpdate { cell, row in
                        if !row.isValid {
                            cell.titleLabel?.textColor = .red
                        }
                    }
            
            
            +++ Section(header: "Should be GreaterThan 2 and SmallerThan 999", footer: "Options: Validates on blurred")
        
                    <<< IntRow() {
                        $0.title = "Range Rule"
                        $0.add(rule: RuleGreaterThan(min: 2))
                        $0.add(rule: RuleSmallerThan(max: 999))
                    }
                    .cellUpdate { cell, row in
                        if !row.isValid {
                            cell.titleLabel?.textColor = .red
                        }
                    }
            
            +++ Section(header: "Match field values", footer: "Options: Validates on blurred")
            
                    <<< PasswordRow("password") {
                        $0.title = "Password"
                    }
                    <<< PasswordRow() {
                        $0.title = "Confirm Password"
                        $0.add(rule: RuleEqualsToRow(form: form, tag: "password"))
                    }
                    .cellUpdate { cell, row in
                        if !row.isValid {
                            cell.titleLabel?.textColor = .red
                        }
                    }

        
            +++ Section(header: "More sophisticated validations UX using callbacks", footer: "")
        
                    <<< TextRow() {
                        $0.title = "Required Rule"
                        $0.add(rule: RuleRequired())
                        $0.validationOptions = .validatesOnChange
                    }
                    .cellUpdate { cell, row in
                        if !row.isValid {
                            cell.titleLabel?.textColor = .red
                        }
                    }
                    .onRowValidationChanged { cell, row in
                        let rowIndex = row.indexPath!.row
                        while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                            row.section?.remove(at: rowIndex + 1)
                        }
                        if !row.isValid {
                            for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                                let labelRow = LabelRow() {
                                    $0.title = validationMsg
                                    $0.cell.height = { 30 }
                                }
                                row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                            }
                        }
                    }
            
        
        
                    <<< EmailRow() {
                        $0.title = "Email Rule"
                        $0.add(rule: RuleRequired())
                        $0.add(rule: RuleEmail())
                        $0.validationOptions = .validatesOnChangeAfterBlurred
                    }
                    .cellUpdate { cell, row in
                        if !row.isValid {
                            cell.titleLabel?.textColor = .red
                        }
                    }
                    .onRowValidationChanged { cell, row in
                        let rowIndex = row.indexPath!.row
                        while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                            row.section?.remove(at: rowIndex + 1)
                        }
                        if !row.isValid {
                            for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                                let labelRow = LabelRow() {
                                    $0.title = validationMsg
                                    $0.cell.height = { 30 }
                                }
                                row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                            }
                        }
                    }

            
        
                    <<< URLRow() {
                            $0.title = "URL Rule"
                            $0.add(rule: RuleURL())
                            $0.validationOptions = .validatesOnChange
                        }
                        .cellUpdate { cell, row in
                            if !row.isValid {
                                cell.titleLabel?.textColor = .red
                            }
                    }
                    .onRowValidationChanged { cell, row in
                        let rowIndex = row.indexPath!.row
                        while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                            row.section?.remove(at: rowIndex + 1)
                        }
                        if !row.isValid {
                            for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                                let labelRow = LabelRow() {
                                    $0.title = validationMsg
                                    $0.cell.height = { 30 }
                                }
                                row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                            }
                        }
                    }
            
            
                    <<< PasswordRow("password2") {
                            $0.title = "Password"
                            $0.add(rule: RuleMinLength(minLength: 8))
                            $0.add(rule: RuleMaxLength(maxLength: 13))
                        }
                        .cellUpdate { cell, row in
                            if !row.isValid {
                                cell.titleLabel?.textColor = .red
                            }
                    }
                    .onRowValidationChanged { cell, row in
                        let rowIndex = row.indexPath!.row
                        while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                            row.section?.remove(at: rowIndex + 1)
                        }
                        if !row.isValid {
                            for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                                let labelRow = LabelRow() {
                                    $0.title = validationMsg
                                    $0.cell.height = { 30 }
                                }
                                row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                            }
                        }
                    }
            
            
                    <<< PasswordRow() {
                            $0.title = "Confirm Password"
                            $0.add(rule: RuleEqualsToRow(form: form, tag: "password2"))
                        }
                        .cellUpdate { cell, row in
                            if !row.isValid {
                                cell.titleLabel?.textColor = .red
                            }
                    }
                    .onRowValidationChanged { cell, row in
                        let rowIndex = row.indexPath!.row
                        while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                            row.section?.remove(at: rowIndex + 1)
                        }
                        if !row.isValid {
                            for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                                let labelRow = LabelRow() {
                                    $0.title = validationMsg
                                    $0.cell.height = { 30 }
                                }
                                row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                            }
                        }
                    }
            
            
            
                    <<< IntRow() {
                            $0.title = "Range Rule"
                            $0.add(rule: RuleGreaterThan(min: 2))
                            $0.add(rule: RuleSmallerThan(max: 999))
                        }
                        .cellUpdate { cell, row in
                            if !row.isValid {
                                cell.titleLabel?.textColor = .red
                            }
                        }
                        .onRowValidationChanged { cell, row in
                            let rowIndex = row.indexPath!.row
                            while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                                row.section?.remove(at: rowIndex + 1)
                            }
                            if !row.isValid {
                                for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                                    let labelRow = LabelRow() {
                                        $0.title = validationMsg
                                        $0.cell.height = { 30 }
                                    }
                                    row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                                }
                            }
                        }
        
        
            +++ Section()
                <<< ButtonRow() {
                    $0.title = "Tap to force form validation"
                }
                .onCellSelection { cell, row in
                    row.section?.form?.validate()
                }
        
    
    }
}

class EurekaLogoViewNib: UIView {

    @IBOutlet weak var imageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class EurekaLogoView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let imageView = UIImageView(image: UIImage(named: "Eureka"))
        imageView.frame = CGRect(x: 0, y: 0, width: 320, height: 130)
        imageView.autoresizingMask = .flexibleWidth
        self.frame = CGRect(x: 0, y: 0, width: 320, height: 130)
        imageView.contentMode = .scaleAspectFit
        self.addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
