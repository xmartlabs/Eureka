//
//  IdaBaseValidator+FactoryHelpers.swift
//  Eureka
//
//  Created by Jingang Liu on 8/1/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

extension IdaBaseValidator {
    public class func SwitchDemoValidator(row:SwitchRow) -> IdaBaseValidator {
        let validator = IdaBaseValidator(target: row) { (target) -> ValidationResult in
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