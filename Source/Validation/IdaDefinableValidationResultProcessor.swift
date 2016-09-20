//
//  IdaDefinableValidationResultProcessor.swift
//  Eureka
//
//  Created by Jingang Liu on 8/3/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

public typealias ValidationResultProcessor = (_ result:ValidationResult, _ callback:(_ success:Bool, _ payload:Any?)->Void)->Void

open class IdaDefinableValidationResultProcessor:IdaValidationResultProcessor {
    open var processor:ValidationResultProcessor
    
    public init(processor:@escaping ValidationResultProcessor) {
        self.processor = processor
    }
    
    open override func processValidationResult(_ validationResult: ValidationResult) {
        self.processor(validationResult) { success, payload in
            //
        }
    }
}
