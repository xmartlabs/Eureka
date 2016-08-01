//
//  IdaBaseValidator.swift
//  Eureka
//
//  Created by Jingang Liu on 8/1/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

typealias ValidationRule = (AnyObject?) -> ValidationResult

class IdaBaseValidator: NSObject,IdaValidator {
    private var target:AnyObject
    private var rule:ValidationRule
    private var wr_listeners:[Weak<AnyObject>]=[]
    
    // MARK: - Initialization
    init(target:AnyObject, rule:ValidationRule) {
        self.target = target
        self.rule = rule
    }
    
    // MARK: - Validation
    func validate(autoPresent: Bool) -> ValidationResult {
        let result = rule(target)
        if (autoPresent) {
            self.iterateListeners({ (listener) in
                listener.processValidationResult(result)
            })
        }
        return result
    }
    
    
    // MARK: - Listeners
    func addListener(listener:IdaValidationListener) {
        // find the previously added reference
        guard listenerWeakReference(listener) == nil else{
            return
        }
        wr_listeners.append(Weak(value: listener))
    }
    
    func removeListener(listener:IdaValidationListener) {
        if let weakReference = listenerWeakReference(listener) {
            wr_listeners.removeAtIndex(indexOfWeakReference(weakReference))
        }
    }
    
    func iterateListeners( blockForListener: ((listener:IdaValidationListener)->Void) ) {
        var emptyReferencesRange = NSMakeRange(0, 0)
        
        for i in 0 ..< wr_listeners.count {
            let wr_listener = wr_listeners[i]
            if let listener = wr_listener.value {
                if let listener = listener as? IdaValidationListener {
                    blockForListener(listener: listener)
                }
            }
            else {
                emptyReferencesRange = NSUnionRange(emptyReferencesRange, NSMakeRange(i, 1))
            }
        }
        
        if let removeRange = emptyReferencesRange.toRange() {
            wr_listeners.removeRange(removeRange)
        }
    }
    
    // MARK: Private worker methods
    private func listenerWeakReference(listener:IdaValidationListener) -> Weak<AnyObject>? {
        
        var resultWeak:Weak<AnyObject>?
        
        var emptyReferencesRange = NSMakeRange(0, 0)
        
        for i in 0 ..< wr_listeners.count {
            let weakReference = wr_listeners[i]
            if weakReference.value == nil {
                emptyReferencesRange = NSUnionRange(emptyReferencesRange, NSMakeRange(i, 1))
            }
            else if listener === weakReference.value! {
                resultWeak = weakReference
                break
            }
        }
        
        // remove empty weakReferences
        if let removeRange = emptyReferencesRange.toRange() {
            wr_listeners.removeRange(removeRange)
        }
        
        return resultWeak
    }
    
    private func indexOfWeakReference(weakReference:Weak<AnyObject>) -> Int {
        for i in 0 ..< wr_listeners.count {
            if ( weakReference === wr_listeners[i] ){
                return i
            }
        }
        return -1
    }
}

private class Weak<T: AnyObject> {
    weak var value : T?
    init (value: T) {
        self.value = value
    }
}