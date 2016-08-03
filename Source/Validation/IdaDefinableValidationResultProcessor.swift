//
//  IdaDefinableValidationResultProcessor.swift
//  Eureka
//
//  Created by Jingang Liu on 8/3/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

public typealias ValidationResultProcessor = (result:ValidationResult, callback:(success:Bool, payload:Any?)->Void)->Void

public class IdaDefinableValidationResultProcessor:IdaValidationResultProcessor {
    public var processor:ValidationResultProcessor
    
    public init(processor:ValidationResultProcessor) {
        self.processor = processor
    }
    
    public override func processValidationResult(validationResult: ValidationResult) {
        self.processor(result: validationResult) { success, payload in
            //
        }
    }
}