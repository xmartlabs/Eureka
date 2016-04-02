//
//  HeaderFooterView.swift
//  Eureka
//
//  Created by Martin Barreto on 2/23/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

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
    case Class
    
    /**
     * Will generate the view as a result of the given closure.
     */
    case Callback(()->ViewType)
    
    /**
     * Will load the view from a nib file.
     */
    case NibFile(name: String, bundle: NSBundle?)
    
    internal func createView() -> ViewType {
        switch self {
        case .Class:
            return ViewType.init()
        case .Callback(let builder):
            return builder()
        case .NibFile(let nibName, let bundle):
            return (bundle ?? NSBundle(forClass: ViewType.self)).loadNibNamed(nibName, owner: nil, options: nil)[0] as! ViewType
        }
    }
}

/**
 * Represents headers and footers of sections
 */
public enum HeaderFooterType {
    case Header, Footer
}

/**
 *  Struct used to generate headers and footers either from a view or a String.
 */
public struct HeaderFooterView<ViewType: UIView> : StringLiteralConvertible, HeaderFooterViewRepresentable {
    
    /// Holds the title of the view if it was set up with a String.
    public var title: String?
    
    /// Generates the view.
    public var viewProvider: HeaderFooterProvider<ViewType>?
    
    /// Closure called when the view is created. Useful to customize its appearance.
    public var onSetupView: ((view: ViewType, section: Section, form: FormViewController) -> ())?
    
    /// A closure that returns the height for the header or footer view.
    public var height: (()->CGFloat)?
    
    lazy var staticView : ViewType? = {
        guard let view = self.viewProvider?.createView() else { return nil }
        return view
    }()
    
    /**
     This method can be called to get the view corresponding to the header or footer of a section in a specific controller.
     
     - parameter section:    The section from which to get the view.
     - parameter type:       Either header or footer.
     - parameter controller: The controller from which to get that view.
     
     - returns: The header or footer of the specified section.
     */
    public func viewForSection(section: Section, type: HeaderFooterType, controller: FormViewController) -> UIView? {
        var view: ViewType?
        if type == .Header {
            view = section.headerView as? ViewType
            if view == nil {
                view = viewProvider?.createView()
                section.headerView = view
            }
        }
        else {
            view = section.footerView as? ViewType
            if view == nil {
                view = viewProvider?.createView()
                section.footerView = view
            }
        }
        guard let v = view else { return nil }
        onSetupView?(view: v, section: section, form: controller)
        v.setNeedsUpdateConstraints()
        v.updateConstraintsIfNeeded()
        v.setNeedsLayout()
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
