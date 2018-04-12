//
//  SwipeActionsController.swift
//  Example
//
//  Created by Mathias Claassen on 3/15/18.
//  Copyright © 2018 Xmartlabs. All rights reserved.
//

import Eureka

class SwipeActionsController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        form +++ Section(footer: "Eureka sets table.isEditing = true only if the form contains a MultivaluedSection. SwipeActions only work when isEditing = false, therefore you have to set that in ViewWillAppear. Both can't be used on the same form.")
            <<< LabelRow("Actions Right: iOS >= 7") {
                $0.title = $0.tag

                let moreAction = SwipeAction(style: .normal, title: "More", handler: { (action, row, completionHandler) in
                    print("More")
                    completionHandler?(true)
                })

                let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, row, completionHandler) in
                    print("Delete")
                    completionHandler?(true)
                }

                $0.trailingSwipe.actions = [deleteAction,moreAction]

            }

            <<< LabelRow("Actions Left & Right: iOS >= 11") {
                $0.title = $0.tag

                let moreAction = SwipeAction(style: .normal, title: "More") { (action, row, completionHandler) in
                    print("More")
                    completionHandler?(true)
                }

                let deleteAction = SwipeAction(style: .destructive, title: "Delete", handler: { (action, row, completionHandler) in
                    print("Delete")
                    completionHandler?(true)
                })

                $0.trailingSwipe.actions = [deleteAction,moreAction]
                $0.trailingSwipe.performsFirstActionWithFullSwipe = true

                if #available(iOS 11,*) {
                    let infoAction = SwipeAction(style: .normal, title: "Info", handler: { (action, row, completionHandler) in
                        print("Info")
                        completionHandler?(true)
                    })
                    infoAction.backgroundColor = .blue

                    $0.leadingSwipe.actions = [infoAction]
                    $0.leadingSwipe.performsFirstActionWithFullSwipe = true
                }
        }
    }
}
