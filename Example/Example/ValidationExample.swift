//
//  ValidationExample.swift
//  Example
//
//  Created by Jingang Liu on 8/3/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import UIKit
import Eureka
class ValidationExample: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeForm()
    }
    
    /// Rows for Tests with Simple Business Logic.
    var row_lowerValue : DecimalRow!
    var row_higherValue : DecimalRow!
    
    var row_systolic : DecimalRow!
    var row_diastolic : DecimalRow!
    
    var validation_limit : IdaDecimalComparisonValidator!
    var validation_bloodPressure : IdaDecimalComparisonValidator!
    
    var numericValidationResultProccessor: IdaDefinableValidationResultProcessor!
    
    var row_start : DateTimeInlineRow!
    var row_end : DateTimeInlineRow!
    var validation_duration : IdaDefinableValidator!
    
    /// Rows for Log Based Tests
    /// --- Field Rows
    var row_decimal : DecimalRow!
    var row_text : TextRow!
    var row_int : IntRow!
    var row_password : PasswordRow!
    /// --- Inline
    var row_time : DateTimeInlineRow!
    /// --- Simple Input
    var row_switch : SwitchRow!
    var row_check : CheckRow!
    var row_segment : SegmentedRow<String>!
    
    
    private func initializeForm() {
        initializeForm_ExamplesWithLogic()
        initializeForm_ExamplesLogBased()
        initializeForm_ShowingValidationResult()
    }
    private func initializeForm_ExamplesWithLogic() {
        
        form +++ Section("Switch")
            <<< SwitchRow("I agree to Privacy Policy") {
                $0.title = $0.tag
                // Validator 0. Should agree
                $0.validatorWhileEditing = IdaDefinableValidator.SwitchDemoValidator($0)
                $0.validatorWhileEditing?.addListener(SwitchDemoValidationResultPresenter(), strong: true)
            }
            +++ Section("Comapre Numeric Fields")
            <<< DecimalRow("Lower Limit") {
                $0.title = $0.tag
                row_lowerValue = $0
            }
            <<< DecimalRow("Higher Limit") {
                $0.title = $0.tag
                row_higherValue = $0
            }
            +++ Section("Blood Pressure")
            <<< DecimalRow("Systolic") {
                $0.title = $0.tag
                row_systolic = $0
            }
            <<< DecimalRow("Diastolic") {
                $0.title = $0.tag
                row_diastolic = $0
            }
            +++ Section("Holidy Period")
            <<< DateTimeInlineRow("Start Time") {
                $0.title = $0.tag
                row_start = $0
            }
            <<< DateTimeInlineRow("End Time") {
                $0.title = $0.tag
                row_end = $0
        }
        
        // Add Validators
        // Validator 1. Bounds
        validation_limit = IdaDecimalComparisonValidator(tag: "Bounds", leftRow: row_lowerValue, rightRow: row_higherValue, validCases: [.OrderedAscending , .OrderedSame], resultClassifier: IdaDecimalComparisonValidator.ProposedResultClassifierPrefix + ".Bounds")
        row_lowerValue.validatorAfterEditing = validation_limit
        row_higherValue.validatorAfterEditing = validation_limit
        
        // Validator 2. Blood Pressure
        validation_bloodPressure = IdaDecimalComparisonValidator(tag: "BloodPressure", leftRow: row_systolic, rightRow: row_diastolic, validCases: [.OrderedDescending], resultClassifier: IdaDecimalComparisonValidator.ProposedResultClassifierPrefix + ".BloodPressure")
        row_systolic.validatorWhileEditing = validation_bloodPressure
        row_diastolic.validatorWhileEditing = validation_bloodPressure
        row_systolic.validatorAfterEditing = validation_bloodPressure
        row_diastolic.validatorAfterEditing = validation_bloodPressure
        
        //// Listener for Validator 1, Validator 2.
        numericValidationResultProccessor = IdaDefinableValidationResultProcessor(processor: { (result, callback) in
            print ("numeric validation result")
            print (result)
            let (left,right) = result.target as! (DecimalRow,DecimalRow)
            var invalidColor = UIColor.redColor()
            if result.classifier == IdaDecimalComparisonValidator.ProposedResultClassifierPrefix + ".BloodPressure" {
                invalidColor = UIColor(red: 0.5, green: 0, blue: 0, alpha: 1)
            }
            
            left.cell.textLabel?.textColor = result.isValid ? UIColor.blackColor() : invalidColor
            right.cell.textLabel?.textColor = result.isValid ? UIColor.blackColor() : invalidColor
        })
        validation_limit.addListener(numericValidationResultProccessor, strong: false)
        validation_bloodPressure.addListener(numericValidationResultProccessor, strong: false)
        
        // Validator 3. Duration
        let _row_start = row_start!
        let _row_end = row_end!
        validation_duration = IdaDefinableValidator(tag: "Duration", target: (_row_start,_row_end), rule: { (rowsPair) -> ValidationResult in
            let (startRow, endRow) = rowsPair as! (DateTimeInlineRow, DateTimeInlineRow)
            let startTime = startRow.value
            let endTime = endRow.value
            //
            var isValid = true
            var payloadLeftPart : String?
            var payloadRightPart : String?
            var payload = [String:String]()
            // Check Start Row
            if let startTime = startTime {
                // Check if the value is within the meaningful zone.
                if let endTime = endTime {
                    if startTime.compare(endTime) != .OrderedAscending {
                        isValid = false
                        payloadLeftPart = "Start time should be ahead of end time."
                    }
                }
            }
            else {
                payloadLeftPart = "Value is empty"
                isValid = false
            }
            
            // Check End Row
            if let endTime = endTime {
                // Check if the value is within the meaningful zone.
                if let startTime = startTime {
                    if startTime.compare(endTime) != .OrderedAscending {
                        isValid = false
                        payloadRightPart = "End time should be after start time."
                    }
                }
            }
            else {
                payloadRightPart = "Value is empty"
                isValid = false
            }
            //
            if let payloadLeftPart = payloadLeftPart {
                payload["start"] = payloadLeftPart
            }
            if let payloadRightPart = payloadRightPart {
                payload["end"] = payloadRightPart
            }
            return ValidationResult(target: rowsPair, classifier: "Duration", isValid: isValid, payload: payload)
        })
        validation_duration.addListener(IdaDefinableValidationResultProcessor(processor: { result , callback in
            let (rowStart,rowEnd) = result.target as! (DateTimeInlineRow, DateTimeInlineRow)
            var rowStartColor = UIColor.whiteColor()
            var rowEndColor = UIColor.whiteColor()
            if let payload = result.payload as? [String:String] {
                if payload["start"] != nil {
                    rowStartColor = UIColor.redColor()
                }
                if payload["end"] != nil {
                    rowEndColor = UIColor.redColor()
                }
            }
            rowStart.baseCell.backgroundColor = rowStartColor
            rowEnd.baseCell.backgroundColor = rowEndColor
        }) , strong: true)
        row_start.validatorWhileEditing = validation_duration
        row_start.validatorAfterEditing = validation_duration
        row_end.validatorAfterEditing = validation_duration
    }
    
    private func initializeForm_SimpleValidations() {
        var row_glucoseLevel : IntRow!
        form +++ Section("Simple Validations")
            <<< IntRow("Glucose Level") {
                $0.title = $0.tag
                row_glucoseLevel = $0
            }
    }
    
    private func initializeForm_ExamplesLogBased() {
        
        
        form +++ Section("Log Based Tests")
            +++ Section("Field Rows")
                <<< DecimalRow("Decimal Row") {
                    $0.title = $0.tag
                    $0.validatorWhileEditing = DummyValidator(tag:"DecimalRow.whileEditing", target:$0)
                    $0.validatorBeforeEditing = DummyValidator(tag:"DecimalRow.beforeEditing", target:$0)
                    $0.validatorAfterEditing = DummyValidator(tag:"DecimalRow.afterEditing", target:$0)
                }
                <<< IntRow("Int Row") {
                    $0.title = $0.tag
                    $0.validatorWhileEditing = DummyValidator(tag:"IntRow.whileEditing", target:$0)
                    $0.validatorBeforeEditing = DummyValidator(tag:"IntRow.beforeEditing", target:$0)
                    $0.validatorAfterEditing = DummyValidator(tag:"IntRow.afterEditing", target:$0)
                }
                <<< TextRow("Text Row") {
                    $0.title = $0.tag
                    $0.validatorWhileEditing = DummyValidator(tag:"TextRow.whileEditing", target:$0)
                    $0.validatorBeforeEditing = DummyValidator(tag:"IntRow.beforeEditing", target:$0)
                    $0.validatorAfterEditing = DummyValidator(tag:"IntRow.afterEditing", target:$0)
                }
                <<< PasswordRow("Password Row") {
                    $0.title = $0.tag
                    $0.validatorWhileEditing = DummyValidator(tag:"PasswordRow.whileEditing", target:$0)
                    $0.validatorBeforeEditing = DummyValidator(tag:"PasswordRow.beforeEditing", target:$0)
                    $0.validatorAfterEditing = DummyValidator(tag:"PasswordRow.afterEditing", target:$0)
                }
            +++ Section("Inline Rows")
                <<< DateTimeInlineRow("Time Row") {
                    $0.title = $0.tag
                    $0.validatorWhileEditing = DummyValidator(tag:"TimeRow.whileEditing", target:$0)
                    $0.validatorBeforeEditing = DummyValidator(tag:"TimeRow.beforeEditing", target:$0)
                    $0.validatorAfterEditing = DummyValidator(tag:"TimeRow.afterEditing", target:$0)
                }
            +++ Section("Simple")
                <<< SwitchRow("Switch Row") {
                    $0.title = $0.tag
                    $0.validatorWhileEditing = DummyValidator(tag: "SwitchRow.whileEditing", target: $0)
                }
                <<< CheckRow("Check Row") {
                    $0.title = $0.tag
                    $0.validatorWhileEditing = DummyValidator(tag: "CheckRow.whileEditing", target: $0)
                }
                <<< SegmentedRow<String>("SegmentedRow Row") {
                    $0.title = $0.tag
                    $0.options = ["💁🏻","🍐","👦🏼"]
                    $0.validatorWhileEditing = DummyValidator(tag: "SegmentedRow.whileEditing", target: $0)
                }
    }
    
    // MARK: - Showing Validation Demo
    var row_independent : DictionaryMessageRow? {
        return form.rowByTag("Independent") as? DictionaryMessageRow
    }
    var row_Age : IntRow? {
        return form.rowByTag("Age") as? IntRow
    }
    private func initializeForm_ShowingValidationResult() {
        form +++ Section("Showing Result")
            +++ Section("Message Row Alone")
                <<< SegmentedRow<String>("ControlIndependentMessage") {
                    $0.title = "Control Message"
                    $0.options = ["Hide","One line","Two lines"]
                    $0.value = "Two lines"
                    $0.onChange({ [unowned self](row) in
                        switch row.value ?? "" {
                            case "One line":
                                self.row_independent?.value = DictionaryMessage(messages: ["Message 1":"I am shown"])
                            case "Two lines":
                                self.row_independent?.value = DictionaryMessage(messages: ["Message1":"I am shown","Message2":"I can be hidden by Segmented row above"])
                            default:
                                self.row_independent?.value = DictionaryMessage(messages: [:])
                        }
                        self.row_independent?.reload()
                    })
                }
                <<< DictionaryMessageRow("Independent") {
                    $0.value = DictionaryMessage(messages: ["Message1":"I am shown","Message2":"I can be hidden by Segmented row above"])
                }
            +++ Section("Validation Message Row")
                <<< IntRow("Age") {
                    $0.title = $0.tag
                    $0.MessageRowType = CustomizedDictionaryMessageRow.self
                }
                <<< IntRow("Someother") {
                    $0.title = $0.tag
                }
        
        /// row.message[result.classifier] = result.isValid ? nil : result.payload
        let messagePresenter = IdaDefinableValidationResultProcessor { (result, callback) in
            guard let row = result.target as? BaseRow, let key = result.classifier else {return}
            let message = ( row.message as? DictionaryMessage ) ?? DictionaryMessage(messages: [:])
            if result.isValid {
                message[key] = nil
            }
            else {
                if let validationMessage = result.payload as? String {
                    message[key] = validationMessage
                }
            }
            row.message = message
        }
        let age_boundValidator = IdaDefinableValidator(tag: "AgeBound", target: row_Age) { (target) -> ValidationResult in
            let ageRow = target as! IntRow
            var valid = true
            var message = "You can watch the movie"
            
            if let age = ageRow.value {
                if age < 15 {
                    valid = false
                    message = "You should be older than 15 to watch the movie."
                }
                if age > 60 {
                    valid = false
                    message = "You should be younger than 60 to watch the movie."
                }
            }
            else {
                valid = false
                message = "You need to enter your age."
            }
            
            return ValidationResult(target: ageRow, classifier: "AgeBound", isValid: valid, payload: message)
        }
        age_boundValidator.addListener(messagePresenter, strong: true)
//        row_Age?.validatorAfterEditing = age_boundValidator
        row_Age?.validatorWhileEditing = age_boundValidator
    }
    
    class CustomizedDictionaryMessageRow : DictionaryMessageRow {
        required init(tag: String?) {
            super.init(tag: tag)
            cellBackgroundColor = UIColor.yellowColor()
            cellTextColor = UIColor.blueColor()
        }
        convenience init() {
            self.init(nil)
        }
    }
}

// MARK: - Helpers
// MARK: Switch Validation
internal class SwitchDemoValidationResultPresenter : IdaValidationResultProcessor {
    override internal func processValidationResult(validationResult: ValidationResult) {
        let row = validationResult.target as! SwitchRow
        row.cell.textLabel?.textColor = validationResult.isValid ? UIColor.blackColor() : UIColor.redColor()
    }
}


extension IdaDefinableValidator {
    public class func SwitchDemoValidator(row:SwitchRow) -> IdaDefinableValidator {
        let validator = IdaDefinableValidator(tag: nil, target: row) { (target) -> ValidationResult in
            let row = target as! SwitchRow
            let validationResult = ValidationResult()
            if row.value == true {
                validationResult.target = row
                validationResult.payload = "Valid"
                validationResult.isValid = true
            }
            else {
                validationResult.target = row
                validationResult.payload = "Invalid"
                validationResult.isValid = false
            }
            return validationResult
        }
        return validator
    }
}

// MARK: Number Comparison
internal class IdaDecimalComparisonValidator : IdaValidator<(left:DecimalRow,right:DecimalRow)> {
    static let ProposedResultClassifierPrefix = "IdaDecimalComparisonValidationResult"
    var validCases:[NSComparisonResult]
    var resultClassifier:String?
    init(tag:String!, leftRow:DecimalRow, rightRow:DecimalRow, validCases:[NSComparisonResult], resultClassifier:String?) {
        self.validCases = validCases
        self.resultClassifier = resultClassifier
        super.init(tag: tag, target:(left:leftRow,right:rightRow))
    }
    override func validate(notify: Bool) -> ValidationResult {
        var isValid = false
        var payloadMessage = "Validator's target is not set"
        if let (left,right) = self.target {
            if let leftValue = left.value, rightValue = right.value {
                var comparisonResult : NSComparisonResult = .OrderedSame
                if leftValue < rightValue {
                    comparisonResult = .OrderedAscending
                }
                else if leftValue > rightValue {
                    comparisonResult = .OrderedDescending
                }
                if validCases.contains(comparisonResult) {
                    isValid = true
                    payloadMessage = "Valid case"
                }
                else {
                    payloadMessage = "Invalid case"
                }
            }
            else {
                payloadMessage = "Values are not set"
            }
        }
        let result = ValidationResult(target: self.target, classifier: resultClassifier, isValid: isValid, payload: payloadMessage)
        if notify {
            notifyListeners(result)
        }
        return result
    }
}

// This is dummy validator to log that it's fired.
internal class DummyValidator : IdaValidator<BaseRow> {
    override func validate(notify: Bool) -> ValidationResult {
        print("Validator Fired. Validator Tag : "+(self.tag ?? "")+"Row Tag : "+(target.tag ?? ""))
        return ValidationResult(target: target, classifier: "DummyValidator")
    }
    init (tag:String?, target:BaseRow) {
        super.init(tag: tag, target: target)
    }
}

extension ValidationResult : CustomStringConvertible {
    public var description : String {
        get {
            var strDesc = ""
            strDesc += isValid ? "Valid. ":"Invalid. "
            
            if let classifier = classifier {
                strDesc += "Classfier: " + classifier + ". "
            }
            if let payload = payload as? String {
                strDesc += "Payload: " + payload + ". "
            }
            return strDesc
        }
    }
}