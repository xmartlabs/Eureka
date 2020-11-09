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
import UIKit

public protocol NavigationAccessory {
    var doneClosure: (() -> ())? { get set }
    var nextClosure: (() -> ())? { get set }
    var previousClosure: (() -> ())? { get set }

    var previousEnabled: Bool { get set }
    var nextEnabled: Bool { get set }
}

/// Class for the navigation accessory view used in FormViewController
@objc(EurekaNavigationAccessoryView)
open class NavigationAccessoryView: UIToolbar, NavigationAccessory {
    open var previousButton: UIBarButtonItem!
    open var nextButton: UIBarButtonItem!
    open var doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
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

    private func drawChevron(pointingRight: Bool) -> UIImage? {
        // Hardcoded chevron size
        let width = 12
        let height = 20

        // Begin the image context, with which we are going to draw a chevron
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        defer {
            UIGraphicsEndImageContext()
        }

        // The chevron looks like > or <. This can be drawn with 3 points; the Y coordinates of the points
        // are independant of whether it is to be pointing left or right; the X coordinates will depend, as follows.
        // The 1s are to ensure that the point of the chevron does not sit exactly on the edge of the frame, which
        // would slightly truncate the point.
        let chevronPointXCoordinate, chevronTailsXCoordinate: Int
        if pointingRight {
            chevronPointXCoordinate = width - 1
            chevronTailsXCoordinate = 1
        } else {
            chevronPointXCoordinate = 1
            chevronTailsXCoordinate = width - 1
        }

        // Draw the lines and return the image
        context.setLineWidth(1.5)
        context.setLineCap(.square)
        context.strokeLineSegments(between: [
            CGPoint(x: chevronTailsXCoordinate, y: 0),
            CGPoint(x: chevronPointXCoordinate, y: height / 2),
            CGPoint(x: chevronPointXCoordinate, y: height / 2),
            CGPoint(x: chevronTailsXCoordinate, y: height)
        ])

        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    private func initializeChevrons() {
        var imageLeftChevron, imageRightChevron: UIImage?
        if #available(iOS 13.0, *) {
            // If we have access to SFSymbols, use the system chevron images, rather than faffing around with our own
            imageLeftChevron = UIImage(systemName: "chevron.left")
            imageRightChevron = UIImage(systemName: "chevron.right")
        } else {
            imageLeftChevron = drawChevron(pointingRight: false)
            imageRightChevron = drawChevron(pointingRight: true)
        }
        
        // RTL language support
        imageLeftChevron = imageLeftChevron?.imageFlippedForRightToLeftLayoutDirection()
        imageRightChevron = imageRightChevron?.imageFlippedForRightToLeftLayoutDirection()

        previousButton = UIBarButtonItem(image: imageLeftChevron, style: .plain, target: self, action: #selector(didTapPrevious))
        nextButton = UIBarButtonItem(image: imageRightChevron, style: .plain, target: self, action: #selector(didTapNext))
    }

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {}

    public var doneClosure: (() -> ())?
    public var nextClosure: (() -> ())?
    public var previousClosure: (() -> ())?

    @objc private func didTapDone() {
        doneClosure?()
    }

    @objc private func didTapNext() {
        nextClosure?()
    }

    @objc private func didTapPrevious() {
        previousClosure?()
    }

    public var previousEnabled: Bool {
        get {
            return previousButton.isEnabled
        }
        set {
            previousButton.isEnabled = newValue
        }
    }

    public var nextEnabled: Bool {
        get {
            return nextButton.isEnabled
        }
        set {
            nextButton.isEnabled = newValue
        }
    }
}
