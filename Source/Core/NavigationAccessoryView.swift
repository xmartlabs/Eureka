//  NavigationAccessoryView.swift
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

/// Class for the navigation accessory view used in FormViewController
open class NavigationAccessoryView : UIToolbar {
    open var previousButton: UIBarButtonItem!
    open var nextButton: UIBarButtonItem!
    open var doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
    private var fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
    private var flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    public override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 44.0))
        autoresizingMask = .flexibleWidth
        fixedSpace.width = 22.0
        initializeChevrons()
        setItems([previousButton, fixedSpace, nextButton, flexibleSpace, doneButton], animated: false)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func initializeChevrons() {
        var bundle = Bundle(for: self.classForCoder)
        if let resourcePath = bundle.path(forResource: "Eureka", ofType: "bundle") {
            if let resourcesBundle = Bundle(path: resourcePath) {
                bundle = resourcesBundle
            }
        }

        var imageLeftChevron = UIImage(named: "back-chevron", in: bundle, compatibleWith: nil)
        var imageRightChevron = UIImage(named: "forward-chevron", in: bundle, compatibleWith: nil)
        // RTL language support
        if #available(iOS 9.0, *) {
            imageLeftChevron = imageLeftChevron?.imageFlippedForRightToLeftLayoutDirection()
            imageRightChevron = imageRightChevron?.imageFlippedForRightToLeftLayoutDirection()
        }

        previousButton = UIBarButtonItem(image: imageLeftChevron, style: .plain, target: nil, action: nil)
        nextButton = UIBarButtonItem(image: imageRightChevron, style: .plain, target: nil, action: nil)
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {}
}
