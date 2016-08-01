//
//  IdaValidationResultPresenter.swift
//  Eureka
//
//  Created by Jingang Liu on 8/1/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

class IdaValidationResultPresenter: NSObject, IdaValidationListener {
    func processValidationResult(validationResult: ValidationResult) {
    }
}

class SwitchDemoValidatorResultPresenter : IdaValidationResultPresenter {
    override func processValidationResult(validationResult: ValidationResult) {
        let row = validationResult.target as! SwitchRow
        row.cell.textLabel?.textColor = validationResult.isValid ? UIColor.blackColor() : UIColor.redColor()
    }
}