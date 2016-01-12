# Change Log
All notable changes to this project will be documented in this file.

### [1.3.1](https://github.com/xmartlabs/Eureka/releases/tag/1.3.1)
Released on 2016-01-11.

 * Bug fixes and stability improvements.

### [1.3.0](https://github.com/xmartlabs/Eureka/releases/tag/1.3.0)
Released on 2015-12-08.

 * Memory leak fix.
 * Removed HeaderFooterView inits from Section.
 * Removed HeaderFooterView inits from Section
 * Added documentation for Section Header and Footer
 * Added documentation for Implementing custom Presenter row
 * Inject table view style on init (by [mikaoj])
 * Modified observeValueForKeyPath functions on FieldCell and SegmentedCell to correctly update constraints (by [dernster] and [estebansotoara])
 * Added Keyboard next button
 * Fixed bug with minimum dates [#111](https://github.com/xmartlabs/Eureka/issues/111)
 * Fixed bug where autocorrected value would not be saved in row.value
 * Fixed currency formatter bugs
 * Added list sections

### [1.2.0](https://github.com/xmartlabs/Eureka/releases/tag/1.2.0)
Released on 2015-11-12.

 * Added PickerRow.
 * Added PickerInlineRow.
 * Added ZipCodeRow.
 * Fix bug when inserting hidden row in midst of a section.
 * Example project: Added ability to set up a formatter to FloatLabelRow.
 * `rowValueHasBeenChanged` signature has been changed to `override func rowValueHasBeenChanged(row: BaseRow, oldValue: Any?, newValue: Any?)`.
 * Added `@noescape` attribute to initializer closures.
 * Fixed issue with tableView's bottom inset when keyboard was dismissed.
 * Changed NameRow keyboardType to make autocapitalization works.

### [1.1.0](https://github.com/xmartlabs/Eureka/releases/tag/1.1.0)
Released on 2015-10-20.

### [1.0.0](https://github.com/xmartlabs/Eureka/releases/tag/1.0.0)
Released on 2015-09-29. This is the initial version.





[mikaoj]: https://github.com/mikaoj
[estebansotoara]: https://github.com/estebansotoara
[dernster]: https://github.com/dernster
