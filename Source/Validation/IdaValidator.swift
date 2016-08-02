//
//  IDAValidator.swift
//  Eureka
//
//  Created by Jingang Liu on 8/1/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

public class ValidationResult: NSObject {
    var target:AnyObject!
    var isValid:Bool = false
    var payload:Any?
}

public protocol IdaValidationListener:class {
    func processValidationResult(validationResult:ValidationResult)
}

public protocol IdaValidator:_IdaValidator {
    func validate(autoPresent:Bool) -> ValidationResult
    func addListener(listener:IdaValidationListener, strong:Bool)
    func removeListener(listener:IdaValidationListener)
}

@objc public protocol _IdaValidator:class {
}