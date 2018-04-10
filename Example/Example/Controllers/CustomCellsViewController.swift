//
//  CustomCellsViewController.swift
//  Example
//
//  Created by Mathias Claassen on 3/15/18.
//  Copyright © 2018 Xmartlabs. All rights reserved.
//

import Eureka
//MARK: Custom Cells Example

class CustomCellsController : FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        form +++
            Section() {
                var header = HeaderFooterView<EurekaLogoViewNib>(.nibFile(name: "EurekaSectionHeader", bundle: nil))
                header.onSetupView = { (view, section) -> () in
                    view.imageView.alpha = 0;
                    UIView.animate(withDuration: 2.0, animations: { [weak view] in
                        view?.imageView.alpha = 1
                    })
                    view.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1)
                    UIView.animate(withDuration: 1.0, animations: { [weak view] in
                        view?.layer.transform = CATransform3DIdentity
                    })
                }
                $0.header = header
            }
            +++ Section("WeekDay cell")

            <<< WeekDayRow(){
                $0.value = [.monday, .wednesday, .friday]
            }

            <<< TextFloatLabelRow() {
                $0.title = "Float Label Row, type something to see.."
            }

            <<< IntFloatLabelRow() {
                $0.title = "Float Label Row, type something to see.."
        }
    }

}

class EurekaLogoViewNib: UIView {

    @IBOutlet weak var imageView: UIImageView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
