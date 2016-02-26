//
//  CellType.swift
//  Eureka
//
//  Created by Martin Barreto on 2/24/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation


//MARK: Cell Protocols

public protocol BaseCellType : class {
    
    /// Method that will return the height of the cell
    var height : (()->CGFloat)? { get }
    
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
     Method called each time the cell is selected (tapped on by the user).
     */
    func highlight()
    
    /**
     Method called each time the cell is deselected (looses first responder).
     */
    func unhighlight()
    
    /**
     Called when cell is about to become first responder
     
     - returns: If the cell should become first responder.
     */
    func cellCanBecomeFirstResponder() -> Bool
    
    /**
     Method called when the cell becomes first responder
     */
    func cellBecomeFirstResponder(direction: Direction) -> Bool
    
    /**
     Method called when the cell resigns first responder
     */
    func cellResignFirstResponder() -> Bool
    
    /**
     A reference to the controller in which the cell is displayed.
     */
    func formViewController () -> FormViewController?
}


public protocol TypedCellType : BaseCellType {
    
    associatedtype Value: Equatable
    
    /// The row associated to this cell.
    var row : RowOf<Value>! { get set }
}

public protocol CellType {}


