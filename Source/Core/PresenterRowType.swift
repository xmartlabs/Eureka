//  PresenterRowType.swift
//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2016 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import Foundation

/**
 *  Protocol that every row that displays a new view controller must conform to.
 *  This includes presenting or pushing view controllers.
 */
public protocol PresenterRowType: TypedRowType {
    
    associatedtype ProviderType : UIViewController, TypedRowControllerType
    
    /// Defines how the view controller will be presented, pushed, etc.
    var presentationMode: PresentationMode<ProviderType>? { get set }
    
    /// Will be called before the presentation occurs.
    var onPresentCallback: ((FormViewController, ProviderType)->())? { get set }
}

extension PresenterRowType {
    
    /**
     Sets a block to be executed when the row presents a view controller
     
     - parameter callback: the block
     
     - returns: this row
     */
    public func onPresent(_ callback: ((FormViewController, ProviderType)->())?) -> Self {
        onPresentCallback = callback
        return self
    }
}
