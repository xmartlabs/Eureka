//
//  IdaBaseValidator.swift
//  Eureka
//
//  Created by Jingang Liu on 8/1/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

public typealias ValidationRule = (Any?) -> ValidationResult

open class IdaDefinableValidator: IdaValidator<Any> {
    open var rule:ValidationRule
    // MARK: - Initialization
    public init (tag:String?, target:Any, rule:@escaping ValidationRule) {
        self.rule = rule
        super.init(tag: tag, target: target)
    }
    // MARK: - Validation
    open override func validate(_ notify: Bool) -> ValidationResult {
        let result = rule(target)
        if (notify) {
            self.notifyListeners(result)
        }
        return result
    }
}
