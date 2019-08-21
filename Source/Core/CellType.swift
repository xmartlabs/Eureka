//  CellType.swift
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

// MARK: Cell Protocols

public protocol BaseCellType : class {

    /// Method that will return the height of the cell
    var height : (() -> CGFloat)? { get }

    /**
     Method called once when creating a cell. Responsible for setting up the cell.
     */
    func setup()

    /**
     Method called each time the cell is updated (e.g. 'cellForRowAtIndexPath' is called). Responsible for updating the cell.
     */
    func update()

    /**
     Method called each time the cell is selected (tapped on by the user).
     */
    func didSelect()

    /**
     Called when cell is about to become first responder
     
     - returns: If the cell should become first responder.
     */
    func cellCanBecomeFirstResponder() -> Bool

    /**
     Method called when the cell becomes first responder
     */
    func cellBecomeFirstResponder(withDirection: Direction) -> Bool

    /**
     Method called when the cell resigns first responder
     */
    func cellResignFirstResponder() -> Bool

    /**
     A reference to the controller in which the cell is displayed.
     */
    func formViewController () -> FormViewController?
}

public protocol TypedCellType: BaseCellType {

    associatedtype Value: Equatable

    /// The row associated to this cell.
    var row: RowOf<Value>! { get set }
}

public protocol CellType: TypedCellType {}
