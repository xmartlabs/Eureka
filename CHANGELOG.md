# Change Log
All notable changes to this project will be documented in this file.

### [1.5.0](https://github.com/xmartlabs/Eureka/releases/tag/1.5.0)

* Xcode 7.3 support.
* Expose a public `KeyboardReturnTypeConfiguration` initializer.
* Allow to override constraints of FieldRow.
* Fixed SelectableSection wrong behaviour when the selectable rows was added to the section before adding the selectable section to the form.
* Implemented StepperRow and added an example to the example project.
* Allow AlertRow cancel title to be changed.
* Enabled CI UI testing and added some tests.
* Fixed "0 after decimal separator (DecimalRow)"
* Added ability to customize selector and multiple selector view controller option rows. Added `selectableRowCellUpdate` property to `SelectorViewController` and `MultipleSelectorViewController`.
* Performance improvement. Store values for each tag in a dictionary and do not calculate it every time we evaluateHidden.

### [1.4.1](https://github.com/xmartlabs/Eureka/releases/tag/1.4.1)
Released on 2016-02-25.

##### Breaking Changes

* `SelectorRow` now requires the cell among its generic values. This means it is easier to change the cell for a selector row.
* `_AlertRow` and `_ActionSheetRow` require generic cell parameter

If you are using custom rows that inherit from SelectorRow then you might want to change them as follows (or use your custom cell):
```
// before
// public final class LocationRow : SelectorRow<CLLocation, MapViewController>, RowType
// now
public final class LocationRow : SelectorRow<CLLocation, MapViewController, PushSelectorCell<CLLocation>>, RowType
```


### [1.4.0](https://github.com/xmartlabs/Eureka/releases/tag/1.4.0)
Released on 2016-02-25.

 * PopoverSelectorRow added.
 * BaseRow reload, select, deselect helpers added.
 * ImageRow update: allows clear button, image sources are public
 * Added PostalAddressRow
 * Lots of smaller bug fixes and new documentation

##### Breaking Changes

* `BaseCellType` protocol method `func cellBecomeFirstResponder() -> Bool`  was renamed to `func cellBecomeFirstResponder(direction: Direction) -> Bool`

If you are using custom rows you may have to fix the compiler error by adding the new parameter.

* DecimalRow value type changed from Float to Double.

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
