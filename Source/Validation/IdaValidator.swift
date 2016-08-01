//
//  IDAValidator.swift
//  Eureka
//
//  Created by Jingang Liu on 8/1/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

class ValidationResult: NSObject {
    var target:AnyObject!
    var isValid:Bool = false
    var payload:Any?
}

protocol IdaValidationListener:class {
    func processValidationResult(validationResult:ValidationResult)
}

protocol IdaValidator:_IdaValidator {
    func validate(autoPresent:Bool) -> ValidationResult
    func addListener(listener:IdaValidationListener)
    func removeListener(listener:IdaValidationListener)
}

@objc protocol _IdaValidator:class {
}