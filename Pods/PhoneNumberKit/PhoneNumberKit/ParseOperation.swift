//
//  PhoneNumberParseOperation.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 31/10/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

/**
Custom NSOperation for phone number parsing that supports throwing closures.
*/
class ParseOperation<OutputType>: NSOperation {
    typealias OperationClosure = (parseOp: ParseOperation<OutputType>) -> Void
    typealias OperationThrowingClosure = (parseOp: ParseOperation<OutputType>) throws -> Void
    override final var executing: Bool { return state == .Executing }
    override final var finished: Bool { return state == .Finished }
    private var completionHandler: OperationClosure?
    private var implementationHandler: OperationThrowingClosure?
    private var dispatchOnceToken: dispatch_once_t = 0
    private(set) var output: ParseOperationValue<OutputType> = .None(PhoneNumberError.GeneralError)
    private var state = ParseOperationState.Initial {
        willSet {
            if newValue != state {
                willChangeValueForState(newValue)
                willChangeValueForState(state)
            }
        }
        didSet {
            if oldValue != state {
                didChangeValueForState(oldValue)
                didChangeValueForState(state)
            }
        }
    }
    
    // MARK: Lifecycle
    
    /**
    Start operation, perform implementation or finish with errors.
    */
    override func start() {
        if !cancelled {
            main()
        }
        else {
            finish(with: .None(.GeneralError))
        }
    }
    
    /**
    Main operation, tries to perform the implementation handler.
    */
    override func main() {
        func main_performImplementation() {
            if let implementationHandler = self.implementationHandler {
                self.implementationHandler = nil
                do {
                    try implementationHandler(parseOp: self)
                }
                catch {
                    finish(with: .GeneralError)
                }
            }
            else {
                finish(with: .GeneralError)
            }
        }
        autoreleasepool {
            main_performImplementation() // happy path
        }
    }
}

extension ParseOperation {
    /**
    Provide implementation handler for operation
    - Parameter implementationHandler: Potentially throwing implementation closure.
    */
    func onStart(implementationHandler: OperationThrowingClosure) {
        self.implementationHandler = implementationHandler
    }
    
    /**
    Provide completion handler for operation
    - Parameter completionHandler: Completion closure.
    */
    func whenFinished(whenFinishedQueue completionHandlerQueue: NSOperationQueue = NSOperationQueue.mainQueue(), completionHandler: OperationClosure) {
        guard self.completionHandler == nil else { return }
        self.completionHandler = completionHandler
    }
    
    /**
    Send a did change value for key notification
    - Parameter state: ParseOperationState.
    */
    func didChangeValueForState(state: ParseOperationState) {
        guard let key = state.key else { return }
        didChangeValueForKey(key)
    }
    
    /**
    Send a will change value for key notification
    - Parameter state: ParseOperationState.
    */
    func willChangeValueForState(state: ParseOperationState) {
        guard let key = state.key else { return }
        willChangeValueForKey(key)
    }
    
    /**
    Finish with an output value
    - Parameter value: Output of valid type.
    */
    final func finish(with value: OutputType) {
        finish(with: .Some(value))
    }
    
    /**
    Finish with a parsing error
    - Parameter parseOperationValueError: Parsing error.
    */
    final func finish(with parseOperationValueError: PhoneNumberError) {
        finish(with: .None(parseOperationValueError))
    }
    
    /**
    Process operation finish
    - Parameter parseOperationValue: Output type or error.
    */
    func finish(with parseOperationValue: ParseOperationValue<OutputType>) {
        dispatch_once(&dispatchOnceToken) {
            self.output = parseOperationValue
            guard let completionHandler = self.completionHandler else { return }
            self.completionHandler = nil
            self.implementationHandler = nil
            completionHandler(parseOp: self)
            self.state = .Finished
        }
    }
}


/**
ParseOperationValue enumeration, can contain a valuetype or an error.
- None: Value representing a parsing error.
- Some: Any operationvalue.
- ProvidedInputValueType: Alias for any operationvalue.
*/
enum ParseOperationValue<ValueType>: ParseOperationValueProvider {
    case None(PhoneNumberError)
    case Some(ValueType)
    typealias ProvidedInputValueType = ValueType
}

extension ParseOperationValue {
    /**
    Get value, can return a value type or throw an error.
    */
    func getValue() throws -> ValueType {
        switch self {
        case .None:
            throw PhoneNumberError.GeneralError
        case .Some(let value):
            return value
        }
    }
    
    /**
    Access value, can return a value type or nil (can't throw).
    */
    var value: ValueType? {
        switch self {
        case .None:
            return nil
        case .Some(let value):
            return value
        }
    }
    
    /**
    Access error, can return an error or nil (can't throw).
    */
    var noneError: PhoneNumberError? {
        switch self {
        case .None(let error):
            return error
        case .Some:
            return nil
        }
    }
}

/**
Value provider protocol.
*/
public protocol ParseOperationValueProvider {
    associatedtype ProvidedInputValueType
}

/**
Operation state enum.
*/
enum ParseOperationState {
    case Initial
    case Executing
    case Finished
    var key: String? {
        switch self {
        case .Executing:
            return "isExecuting"
        case .Finished:
            return "isFinished"
        case .Initial:
            return nil
        }
    }
}
