//
//  IDAValidator.swift
//  Eureka
//
//  Created by Jingang Liu on 8/1/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

open class ValidationResult {
    ///Target of validation.
    open var target:Any!
    ///True if the validation went successful and thus the target is valid.
    open var isValid:Bool = false
    ///Payload contains additional information about validation. For example, it can be readable message on the validation result like "Body fat is percent. Should be lower than 100."
    open var payload:Any?
    ///Classifies the validation result. It tells what kind of validation was happened and how this validation result should be processed. Classifier is used to classify the validation result when two different types of validation result are of same class type.
    open var classifier:String!
    public init() {
    }
    public convenience init(target:Any!, classifier:String!) {
        self.init()
        self.target = target
        self.classifier = classifier
    }
    public convenience init(target:Any!, classifier:String!, isValid:Bool, payload:Any?) {
        self.init(target:target, classifier: classifier)
        self.isValid = isValid
        self.payload = payload
    }
}

public protocol IdaValidationListener:class {
    func processValidationResult(_ validationResult:ValidationResult)
}

open class IdaBaseValidator {
    open var baseTarget:Any!
    open var tag:String?
    // MARK: - Initializers
    public init(tag: String?, baseTarget: Any?) {
        self.tag = tag
        self.baseTarget = baseTarget
    }
    public convenience init() {
        self.init(tag: nil, baseTarget: nil)
    }
    public convenience init(tag:String?) {
        self.init(tag: tag, baseTarget: nil)
    }
    // MARK: - Validation
    open func validate(_ notify:Bool) -> ValidationResult {
        return ValidationResult()
    }
    // MARK: - Keeping Listeners
    fileprivate var wr_listeners:[Weak<AnyObject>]=[]
    open func addListener(_ listener:IdaValidationListener, strong:Bool) {
        // find the previously added reference
        guard listenerWeakReference(listener) == nil else{
            return
        }
        wr_listeners.append(Weak(value: listener, strong:strong))
    }
    open func removeListener(_ listener:IdaValidationListener) {
        if let weakReference = listenerWeakReference(listener) {
            wr_listeners.remove(at: indexOfWeakReference(weakReference))
        }
    }
    open func iterateListeners( _ blockForListener: ((_ listener:IdaValidationListener)->Void) ) {
        var emptyReferencesRange = NSMakeRange(0, 0)
        
        for i in 0 ..< wr_listeners.count {
            let wr_listener = wr_listeners[i]
            if let listener = wr_listener.value {
                if let listener = listener as? IdaValidationListener {
                    blockForListener(listener)
                }
            }
            else {
                emptyReferencesRange = NSUnionRange(emptyReferencesRange, NSMakeRange(i, 1))
            }
        }
        
        if let removeRange = emptyReferencesRange.toRange() {
            wr_listeners.removeSubrange(removeRange)
        }
    }
    open func notifyListeners(_ result:ValidationResult) {
        self.iterateListeners({ (listener) in
            listener.processValidationResult(result)
        })
    }
    // MARK: Private worker methods
    fileprivate func listenerWeakReference(_ listener:IdaValidationListener) -> Weak<AnyObject>? {
        
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
            wr_listeners.removeSubrange(removeRange)
        }
        
        return resultWeak
    }
    
    fileprivate func indexOfWeakReference(_ weakReference:Weak<AnyObject>) -> Int {
        for i in 0 ..< wr_listeners.count {
            if ( weakReference === wr_listeners[i] ){
                return i
            }
        }
        return -1
    }
}

open class IdaValidator<TargetType> : IdaBaseValidator {
    // MARK: - Properties
    open var target:TargetType!
    override open var baseTarget: Any! {
        get {
            return target
        }
        set {
            target = newValue as? TargetType
        }
    }
    // MARK: - Initializers
    public init(tag: String? , target:TargetType!) {
        super.init(tag: tag, baseTarget:target)
        self.target = target
    }
}

private class Weak<T: AnyObject> {
    weak var weakValue : T?
    var strongValue: T?
    var value : T? {
        get {
            if !isStrong {
                return weakValue
            }
            else {
                return strongValue
            }
        }
        set {
            if !isStrong {
                weakValue = newValue
            }
            else {
                strongValue = newValue
            }
        }
    }
    fileprivate(set) var  isStrong: Bool = false
    
    init (value: T, strong:Bool) {
        isStrong = strong
        self.value = value
    }
}
