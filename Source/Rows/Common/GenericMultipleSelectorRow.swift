//  GenericMultipleSelectorRow.swift
//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2016 Xmartlabs SRL ( http://xmartlabs.com )
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



/// Generic options selector row that allows multiple selection.
public class GenericMultipleSelectorRow<T: Hashable, Cell: CellType, VCType: TypedRowControllerType where Cell: BaseCell, Cell: TypedCellType, Cell.Value == Set<T>, VCType: UIViewController, VCType.RowValue == Set<T>>: Row<Set<T>, Cell>, PresenterRowType, NoValueDisplayTextConformance {
    
    /// Defines how the view controller will be presented, pushed, etc.
    public var presentationMode: PresentationMode<VCType>?
    
    /// Will be called before the presentation occurs.
    public var onPresentCallback : ((FormViewController, VCType)->())?
    
    /// Title to be displayed for the options
    public var selectorTitle: String?
    
    public var noValueDisplayText: String?
    
    /// Options from which the user will choose
    public var options: [T] {
        get { return self.dataProvider?.arrayData?.map({ $0.first! }) ?? [] }
        set { self.dataProvider = DataProvider(arrayData: newValue.map({ Set<T>(arrayLiteral: $0) })) }
    }
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = { (rowValue: Set<T>?) in
            return rowValue?.map({ String($0) }).sort().joinWithSeparator(", ")
        }
        presentationMode = .Show(controllerProvider: ControllerProvider.Callback { return VCType() }, completionCallback: { vc in vc.navigationController?.popViewControllerAnimated(true) })
    }
    
    /**
     Extends `didSelect` method
     */
    public override func customDidSelect() {
        super.customDidSelect()
        guard let presentationMode = presentationMode where !isDisabled else { return }
        if let controller = presentationMode.createController(){
            controller.row = self
            controller.title = selectorTitle ?? controller.title
            onPresentCallback?(cell.formViewController()!, controller)
            presentationMode.presentViewController(controller, row: self, presentingViewController: self.cell.formViewController()!)
        }
        else{
            presentationMode.presentViewController(nil, row: self, presentingViewController: self.cell.formViewController()!)
        }
    }
    
    /**
     Prepares the pushed row setting its title and completion callback.
     */
    public override func prepareForSegue(segue: UIStoryboardSegue) {
        super.prepareForSegue(segue)
        guard let rowVC = segue.destinationViewController as? VCType else { return }
        rowVC.title = selectorTitle ?? rowVC.title
        rowVC.completionCallback = presentationMode?.completionHandler ?? rowVC.completionCallback
        onPresentCallback?(cell.formViewController()!, rowVC)
        rowVC.row = self
    }
}

