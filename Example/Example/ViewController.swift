//  ViewController.swift
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

import UIKit
import Eureka

//MARK: HomeViewController

class HomeViewController : FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ImageRow.defaultCellUpdate = { cell, row in
           cell.accessoryView?.layer.cornerRadius = 17
           cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        }

        form +++

            Section() {
                $0.header = HeaderFooterView<EurekaLogoView>(.class)
            }

                <<< ButtonRow("Rows") {
                        $0.title = $0.tag
                        $0.presentationMode = .segueName(segueName: "RowsExampleViewControllerSegue", onDismiss: nil)
                    }

                <<< ButtonRow("Native iOS Event Form") { row in
                        row.title = row.tag
                        row.presentationMode = .segueName(segueName: "NativeEventsFormNavigationControllerSegue", onDismiss:{  vc in vc.dismiss(animated: true) })
                    }

                <<< ButtonRow("Accesory View Navigation") { (row: ButtonRow) in
                        row.title = row.tag
                        row.presentationMode = .segueName(segueName: "AccesoryViewControllerSegue", onDismiss: nil)
                    }

                <<< ButtonRow("Custom Cells") { (row: ButtonRow) -> () in
                        row.title = row.tag
                        row.presentationMode = .segueName(segueName: "CustomCellsControllerSegue", onDismiss: nil)
                    }

                <<< ButtonRow("Customization of rows with text input") { (row: ButtonRow) -> Void in
                        row.title = row.tag
                        row.presentationMode = .segueName(segueName: "FieldCustomizationControllerSegue", onDismiss: nil)
                    }

                <<< ButtonRow("Hidden rows") { (row: ButtonRow) -> Void in
                    row.title = row.tag
                    row.presentationMode = .segueName(segueName: "HiddenRowsControllerSegue", onDismiss: nil)
                    }

                <<< ButtonRow("Disabled rows") { (row: ButtonRow) -> Void in
                    row.title = row.tag
                    row.presentationMode = .segueName(segueName: "DisabledRowsControllerSegue", onDismiss: nil)
                }

                <<< ButtonRow("Formatters") { (row: ButtonRow) -> Void in
                    row.title = row.tag
                    row.presentationMode = .segueName(segueName: "FormattersControllerSegue", onDismiss: nil)
                }

                <<< ButtonRow("Inline rows") { (row: ButtonRow) -> Void in
                    row.title = row.tag
                    row.presentationMode = .segueName(segueName: "InlineRowsControllerSegue", onDismiss: nil)
                }
                <<< ButtonRow("List Sections") { (row: ButtonRow) -> Void in
                    row.title = row.tag
                    row.presentationMode = .segueName(segueName: "ListSectionsControllerSegue", onDismiss: nil)
                }
                <<< ButtonRow("Validations") { (row: ButtonRow) -> Void in
                    row.title = row.tag
                    row.presentationMode = .segueName(segueName: "ValidationsControllerSegue", onDismiss: nil)
                }

                <<< ButtonRow("Custom Design") { (row: ButtonRow) -> Void in
                    row.title = row.tag
                    row.presentationMode = .segueName(segueName: "CustomDesignControllerSegue", onDismiss: nil)
                }

                <<< ButtonRow("Multivalued Sections") { (row: ButtonRow) -> Void in
                    row.title = row.tag
                    row.presentationMode = .segueName(segueName: "MultivaluedSectionsControllerSegue", onDismiss: nil)
                }

                <<< ButtonRow("Swipe Actions") { (row: ButtonRow) -> Void in
                  row.title = row.tag
                  row.presentationMode = .segueName(segueName: "SwipeActionsControllerSegue", onDismiss: nil)
                }

                <<< ButtonRow("Plain Table View Style") { (row: ButtonRow) in
                    row.title = row.tag
                    row.presentationMode = .segueName(segueName: "PlainTableViewStyleViewControllerSegue", onDismiss: nil)
                }


        +++ Section()
                <<< ButtonRow() { (row: ButtonRow) -> Void in
                   row.title = "About"
                }
                .onCellSelection { [weak self] (cell, row) in
                    self?.showAlert()
                }

    }


    @IBAction func showAlert() {
        let alertController = UIAlertController(title: "OnCellSelection", message: "Button Row Action", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true)

    }

}

//MARK: Emoji

typealias Emoji = String
let 👦🏼 = "👦🏼", 🍐 = "🍐", 💁🏻 = "💁🏻", 🐗 = "🐗", 🐼 = "🐼", 🐻 = "🐻", 🐖 = "🐖", 🐡 = "🐡"


class EurekaLogoView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        let imageView = UIImageView(image: UIImage(named: "Eureka"))
        imageView.frame = CGRect(x: 0, y: 0, width: 320, height: 130)
        imageView.autoresizingMask = .flexibleWidth
        self.frame = CGRect(x: 0, y: 0, width: 320, height: 130)
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
