//
//  IdaValidationResultPresenter.swift
//  Eureka
//
//  Created by Jingang Liu on 8/1/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

public class IdaValidationResultPresenter: NSObject, IdaValidationListener {
    public func processValidationResult(validationResult: ValidationResult) {
    }
}

public class SwitchDemoValidationResultPresenter : IdaValidationResultPresenter {
    override public func processValidationResult(validationResult: ValidationResult) {
        let row = validationResult.target as! SwitchRow
        row.cell.textLabel?.textColor = validationResult.isValid ? UIColor.blackColor() : UIColor.redColor()
    }
}