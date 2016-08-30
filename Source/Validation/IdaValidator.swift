//
//  IDAValidator.swift
//  Eureka
//
//  Created by Jingang Liu on 8/1/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

public class ValidationResult {
    ///Target of validation.
    public var target:Any!
    ///True if the validation went successful and thus the target is valid.
    public var isValid:Bool = false
    ///Payload contains additional information about validation. For example, it can be readable message on the validation result like "Body fat is percent. Should be lower than 100."
    public var payload:Any?
    ///Classifies the validation result. It tells what kind of validation was happened and how this validation result should be processed. Classifier is used to classify the validation result when two different types of validation result are of same class type.
    public var classifier:String!
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
    func processValidationResult(validationResult:ValidationResult)
}

public class IdaBaseValidator {
    public var baseTarget:Any!
    public var tag:String?
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
    public func validate(notify:Bool) -> ValidationResult {
        return ValidationResult()
    }
    private var fireTime: UInt64 = 0
    public var delayTimeWhileEditing: Int64 {
        //Default is a quarter-second delay
        return Int64(NSEC_PER_SEC)/2
    }
    public func delayedValidation(notify:Bool, delayTime: Int64) {
        let popTime = dispatch_time(DISPATCH_TIME_NOW, delayTime);
        fireTime = popTime

        dispatch_after(popTime, dispatch_get_main_queue()){ [weak self] in
            if let _ = self where popTime == self!.fireTime {
                self!.validate(notify)
            }
        }
    }
    // MARK: - Keeping Listeners
    private var wr_listeners:[Weak<AnyObject>]=[]
    public func addListener(listener:IdaValidationListener, strong:Bool) {
        // find the previously added reference
        guard listenerWeakReference(listener) == nil else{
            return
        }
        wr_listeners.append(Weak(value: listener, strong:strong))
    }
    public func removeListener(listener:IdaValidationListener) {
        if let weakReference = listenerWeakReference(listener) {
            wr_listeners.removeAtIndex(indexOfWeakReference(weakReference))
        }
    }
    public func iterateListeners( blockForListener: ((listener:IdaValidationListener)->Void) ) {
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
    public func notifyListeners(result:ValidationResult) {
        self.iterateListeners({ (listener) in
            listener.processValidationResult(result)
        })
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

public class IdaValidator<TargetType> : IdaBaseValidator {
    // MARK: - Properties
    public var target:TargetType!
    override public var baseTarget: Any! {
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
    private(set) var  isStrong: Bool = false
    
    init (value: T, strong:Bool) {
        isStrong = strong
        self.value = value
    }
}