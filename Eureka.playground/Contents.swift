//: **Eureka Playground** - let us walk you through Eureka! cool features, we will show how to
//: easily create powerful forms using Eureka!

//: It allows us to create complex dynamic table view forms and obviously simple static table view. It's ideal for data entry task or settings pages.

import UIKit
import XCPlayground
import PlaygroundSupport

//: Start by importing Eureka module
import Eureka

//: Any **Eureka** form must extend from `FromViewController`
let formController = FormViewController()
PlaygroundPage.current.liveView = formController.view


let b = Array<Int>()
b.last

let f = Form()
f.last


//: ## Operators
//: ### +++
//: Adds a Section to a Form when the left operator is a Form
let form = Form() +++ Section()
//: When both operators are a Section it creates a new Form containing both Section and return the created form.
let form2 = Section("First") +++ Section("Second") +++ Section("Third")
//: Notice that you don't need to add parenthesis in the above expresion, +++ operator is left associative so it will create a form containing the 2 first sections and then append last Section (Third) to the created form.
//: form and form2 don't have any row and are not useful at all. Let's add some rows.


//: ### +++ 
//: Can be used to append a row to a form without having to create a Section to contain the row. The form section is implicitly created as a result of the +++ operator.
formController.form +++ TextRow("Text")
//: it can also be used to append a Section like this:
formController.form +++ Section()

//: ### <<<
//: Can be used to append rows to a section.
formController.form.last! <<< SwitchRow("Switch") { $0.title = "Switch"; $0.value = true }

//: it can also be used to create a section and append rows to it. Let's use that to add a new section to the form
formController.form +++ PhoneRow("Phone"){ $0.title = "Phone"}
                        <<< IntRow("IntRow"){ $0.title = "Int"; $0.value = 5 }

formController.view
//: # Callbacks
//: Rows might have several closures associated to be called at different events. Let's see them one by one. Sadly, we can not interact with it in our playground.

//: ### onChange callback
//: Will be called when the value of a row changes. Lots of things can be done with this feature. Let's create a new section for the new rows:
formController.form +++ Section("Callbacks") <<< SwitchRow("scr1"){ $0.title = "Switch to turn red"; $0.value = false }
    .onChange({ row in
        if row.value == true {
            row.cell.backgroundColor = .red
        }
        else {
            row.cell.backgroundColor = .black
        }
    })

//: Now when we change the value of this row its background color will change to red. Try that by (un)commenting the following line:
formController.view
formController.form.last?.last?.baseValue = true
formController.view
//: Notice that we set the `baseValue` attribute because we did not downcast the result of `formController.form.last?.last`. It is essentially the same as the `value` attribute

//: ### cellSetup and cellUpdate callbacks
//: The cellSetup will be called when the cell of this row is configured (just once at the beginning) and the cellUpdate will be called when it is updated (each time it reappears on screen). Here you should define the appearance of the cell

formController.form.last! <<< SegmentedRow<String>("Segments") { $0.title = "Choose an animal"; $0.value = "🐼"; $0.options = ["🐼", "🐶", "🐻"]}.cellSetup({ cell, row in
        cell.backgroundColor = .red
}).cellUpdate({ (cell, row) -> () in
    cell.textLabel?.textColor = .yellow
})


//: ### onSelection and onPresent callbacks
//: OnSelection will be called when this row is selected (tapped by the user). It might be useful for certain rows instead of the onChange callback.
//: OnPresent will be called when a row that presents another view controller is tapped. It might be useful to set up the presented view controller.
//: We can not try them out in the playground but they can be set just like the others.

formController.form.last! <<< SegmentedRow<String>("Segments2") { $0.title = "Choose an animal"; $0.value = "🐼"; $0.options = ["🐼", "🐶", "🐻"]
    }.onCellSelection{ cell, row in
        print("\(cell) for \(row) got selected")
    }

formController.view

//: ### Hiding rows
//: We can hide rows by defining conditions that will tell if they should appear on screen or not. Let's create a row that will hide when the previous one is "🐼".

formController.form.last! <<< LabelRow("Confirm") {
    $0.title = "Are you sure you do not want the 🐼?"
    $0.hidden = "$Segments2 == '🐼'"
}

//: Now let's see how this works:

formController.view
formController.form.rowBy(tag: "Segments2")?.baseValue = "🐶"
formController.view

//: We can do the same using functions. Functions are specially useful for more complicated conditions. This applies when the value of the row we depend on is not compatible with NSPredicates (which is not the current case, but anyway).

formController.form.last! <<< LabelRow("Confirm2") {
    $0.title = "Well chosen!!"
    $0.hidden = Condition.function(["Segments2"]){ form in
        if let r:SegmentedRow<String> = form.rowBy(tag: "Segments2") {
            return r.value != "🐼"
        }
        return true
    }
}

//: Now let's see how this works:

formController.view
formController.form.rowBy(tag: "Segments2")?.baseValue = "🐼"
formController.view

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            