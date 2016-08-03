//
//  IdaBaseValidator.swift
//  Eureka
//
//  Created by Jingang Liu on 8/1/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

public typealias ValidationRule = (Any?) -> ValidationResult

public class IdaDefinableValidator: IdaValidator<Any> {
    public var rule:ValidationRule
    // MARK: - Initialization
    public init (tag:String?, target:Any, rule:ValidationRule) {
        self.rule = rule
        super.init(tag: tag, target: target)
    }
    // MARK: - Validation
    public override func validate(notify: Bool) -> ValidationResult {
        let result = rule(target)
        if (notify) {
            self.notifyListeners(result)
        }
        return result
    }
}