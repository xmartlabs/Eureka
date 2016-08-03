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
    var row_lowerValue : DecimalRow!
    var row_higherValue : DecimalRow!
    
    private func initializeForm() {
        
        form +++ Section("Comapre Numeric Fields")
            <<< SwitchRow("Should be on") {
                $0.title = $0.tag
                $0.validator = IdaDefinableValidator.SwitchDemoValidator($0)
                $0.validator?.addListener(SwitchDemoValidationResultPresenter(), strong: true)
            }
            <<< DecimalRow("Should keep lower value") {
                $0.title = $0.tag
                row_lowerValue = $0
            }
            <<< DecimalRow("Should keep higher value") {
                $0.title = $0.tag
                row_higherValue = $0
        }
    }
}

// MARK: - Switch Validation
internal class SwitchDemoValidationResultPresenter : IdaValidationResultProcessor {
    override public func processValidationResult(validationResult: ValidationResult) {
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

// MARK: - Number Comparison
internal class IdaDecimalComparisonValidator : IdaValidator<(left:DecimalRow,right:DecimalRow)> {
    static let ValidationResultClassifier = "IdaDecimalComparisonValidationResult"
    var validCases:[NSComparisonResult]
    init(tag:String!, leftRow:DecimalRow, rightRow:DecimalRow, validCases:[NSComparisonResult]) {
        self.validCases = validCases
        super.init(tag: tag, target:(left:leftRow,right:rightRow))
    }
    override func validate(notify: Bool) -> ValidationResult {
        var failureMessage = "Validator's target is not set"
        if let (left,right) = self.target {
            guard let leftValue = left.value, rightValue = right.value else {
                failureMessage = "Values are not set"
            }
            var comparisonResult : NSComparisonResult = .OrderedSame
            if leftValue < rightValue {
                comparisonResult = .OrderedAscending
            }
            else if leftValue > rightValue {
                comparisonResult = .OrderedDescending
            }
            if validCases.contains(comparisonResult) {
                return ValidationResult(target: self.target, classifier: self.dynamicType.ValidationResultClassifier, isValid: true, payload: "Valid")
            }
            else {
                failureMessage = "Invalid case"
            }
        }
        return ValidationResult(target: self.target, classifier: self.dynamicType.ValidationResultClassifier, isValid: false, payload: failureMessage)
    }
}