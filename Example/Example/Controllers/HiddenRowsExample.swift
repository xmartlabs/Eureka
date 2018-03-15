//
//  HiddenRowsExample.swift
//  Example
//
//  Created by Mathias Claassen on 3/15/18.
//  Copyright © 2018 Xmartlabs. All rights reserved.
//

import Eureka

class HiddenRowsExample : FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        TextRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.font = UIFont.italicSystemFont(ofSize: 12)
        }

        form = Section("What do you want to talk about:")
            <<< SegmentedRow<String>("segments"){
                $0.options = ["Sport", "Music", "Films"]
                $0.value = "Films"
            }
            +++ Section(){
                $0.tag = "sport_s"
                $0.hidden = "$segments != 'Sport'" // .Predicate(NSPredicate(format: "$segments != 'Sport'"))
            }
            <<< TextRow(){
                $0.title = "Which is your favourite soccer player?"
            }

            <<< TextRow(){
                $0.title = "Which is your favourite coach?"
            }

            <<< TextRow(){
                $0.title = "Which is your favourite team?"
            }

            +++ Section(){
                $0.tag = "music_s"
                $0.hidden = "$segments != 'Music'"
            }
            <<< TextRow(){
                $0.title = "Which music style do you like most?"
            }

            <<< TextRow(){
                $0.title = "Which is your favourite singer?"
            }
            <<< TextRow(){
                $0.title = "How many CDs have you got?"
            }

            +++ Section(){
                $0.tag = "films_s"
                $0.hidden = "$segments != 'Films'"
            }
            <<< TextRow(){
                $0.title = "Which is your favourite actor?"
            }

            <<< TextRow(){
                $0.title = "Which is your favourite film?"
            }

            +++ Section()

            <<< SwitchRow("Show Next Row"){
                $0.title = $0.tag
            }
            <<< SwitchRow("Show Next Section"){
                $0.title = $0.tag
                $0.hidden = .function(["Show Next Row"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "Show Next Row")
                    return row.value ?? false == false
                })
            }

            +++ Section(footer: "This section is shown only when 'Show Next Row' switch is enabled"){
                $0.hidden = .function(["Show Next Section"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "Show Next Section")
                    return row.value ?? false == false
                })
            }
            <<< TextRow() {
                $0.placeholder = "Gonna dissapear soon!!"
        }
    }
}
