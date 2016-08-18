//  HeaderFooterView.swift
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
 Enumeration used to generate views for the header and footer of a section.
 
 - Class:              Will generate a view of the specified class.
 - Callback->ViewType: Will generate the view as a result of the given closure.
 - NibFile:            Will load the view from a nib file.
 */
public enum HeaderFooterProvider<ViewType: UIView> {
    
    /**
     * Will generate a view of the specified class.
     */
    case `class`
    
    /**
     * Will generate the view as a result of the given closure.
     */
    case callback(()->ViewType)
    
    /**
     * Will load the view from a nib file.
     */
    case nibFile(name: String, bundle: Bundle?)
    
    internal func createView() -> ViewType {
        switch self {
        case .class:
            return ViewType()
        case .callback(let builder):
            return builder()
        case .nibFile(let nibName, let bundle):
            return (bundle ?? Bundle(for: ViewType.self)).loadNibNamed(nibName, owner: nil, options: nil)![0] as! ViewType
        }
    }
}

/**
 * Represents headers and footers of sections
 */
public enum HeaderFooterType {
    case header, footer
}

/**
 *  Struct used to generate headers and footers either from a view or a String.
 */
public struct HeaderFooterView<ViewType: UIView> : ExpressibleByStringLiteral, HeaderFooterViewRepresentable {
    
    /// Holds the title of the view if it was set up with a String.
    public var title: String?
    
    /// Generates the view.
    public var viewProvider: HeaderFooterProvider<ViewType>?
    
    /// Closure called when the view is created. Useful to customize its appearance.
    public var onSetupView: ((_ view: ViewType, _ section: Section) -> ())?
    
    /// A closure that returns the height for the header or footer view.
    public var height: (()->CGFloat)?
    
    
    /**
     This method can be called to get the view corresponding to the header or footer of a section in a specific controller.
     
     - parameter section:    The section from which to get the view.
     - parameter type:       Either header or footer.
     - parameter controller: The controller from which to get that view.
     
     - returns: The header or footer of the specified section.
     */
    public func viewForSection(_ section: Section, type: HeaderFooterType) -> UIView? {
        var view: ViewType?
        if type == .header {
            view = section.headerView as? ViewType ?? {
                            let result = viewProvider?.createView()
                            section.headerView = result
                            return result
                        }()
        }
        else {
            view = section.footerView as? ViewType ?? {
                            let result = viewProvider?.createView()
                            section.footerView = result
                            return result
                        }()
        }
        guard let v = view else { return nil }
        onSetupView?(v, section)
        return v
    }
    
    /**
     Initiates the view with a String as title
     */
    public init?(title: String?){
        guard let t = title else { return nil }
        self.init(stringLiteral: t)
    }
    
    /**
     Initiates the view with a view provider, ideal for customized headers or footers
     */
    public init(_ provider: HeaderFooterProvider<ViewType>){
        viewProvider = provider
    }
    
    /**
     Initiates the view with a String as title
     */
    public init(unicodeScalarLiteral value: String) {
        self.title  = value
    }
    
    /**
     Initiates the view with a String as title
     */
    public init(extendedGraphemeClusterLiteral value: String) {
        self.title = value
    }
    
    /**
     Initiates the view with a String as title
     */
    public init(stringLiteral value: String) {
        self.title = value
    }
}

extension UIView {
    
    func eurekaInvalidate() {
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
        setNeedsLayout()
    }
    
}
