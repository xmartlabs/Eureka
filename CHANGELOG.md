# Change Log
All notable changes to this project will be documented in this file.

### [4.3.0](https://github.com/xmartlabs/Eureka/releases/tag/4.3.0)

* Changes for Swift 4.2, Xcode 10 and iOS 12
* Add ability to customise the text color of UIPickerView used by PickerRow
* Make `onPresent` result discardable
* Add `insert(row: after:)` method on Section which allows inserting rows after a hidden row
* Other minor fixes

### [4.2.0](https://github.com/xmartlabs/Eureka/releases/tag/4.2.0)

* Adding support for RowType.subtitle on FieldRow (#1468)
* CompletionHandler for SwipeAction under iOS < 11
* Allow setting position of the cell after scrolling (#1452)
* Add Chinese readme (#1487)
* Implement readOnly textAreaRow feature (#1489)
* Update cell when tintColor changes (#1492)
* PickerRow for 2 and 3 components (#1540)
* And several bug fixes

### [4.1.1](https://github.com/xmartlabs/Eureka/releases/tag/4.1.1)

* Bug fixes and stability improvements.

### [4.1.0](https://github.com/xmartlabs/Eureka/releases/tag/4.1.0)

* Add compatibility for Xcode 9.3 beta 2 and Swift 4.1.
* New functionality 🎉. https://github.com/xmartlabs/eureka#swipe-actions. Thanks [@marbetschar](https://github.com/marbetschar).
* Add sectionIndexTitles and sectionForSectionIndexTitles to FormViewController to allow for subclasses to override.
* Fix SliderRow layout.
* Fix regular expression for URLs to allow query and location parameter.
* Corrected issue in section sorting function of MultipleSelectorViewController, where all options were placed in one section, with a section title based on the first option.
* Added missing call to super.updateConstraints in SegmentedCell.
* Add ability to setup alert cancel title from AlertRow.
* remove blank section headers/footers from plain tables on iOS 11. This prevents blank section headers and footers from appearing on iOS
11 when setting the table view style to plain and there are no headers
or footers.
* Fix UIDatePicker bug when mode == .countDownTimer.
* Allow non-selectable rows to exist besides selectable rows in a selectable section.
* SliderRow - added option 'shouldHideValue' to hide value label (default to false).
* Update cell when tintColor changes.
* Support dynamic font size changes.

### [4.0.0](https://github.com/xmartlabs/Eureka/releases/tag/4.0.0)

* Xcode 9, Swift 4 support.
* Add the values of MultivaluedSection into form.values().

### [3.1.0](https://github.com/xmartlabs/Eureka/releases/tag/3.1.0)

Bug fixes & stability improvements:

* Fixed how sections and rows are inserted using subscripts
* Fixed issue with disbled rows in selectable sections. Disabled rows were still selectable.
* Multivalued section does not display image in imagerow #977
* Improve currency formatter #1103
* Added option to use accessory view in ImageCheckCell
* Exact length validation (new feature)
* Change validation on demand behaviour when row was not valid (#1148)
* Move FormDelegate methods to `FormViewController` class to make it extensible and customizable.
* The slider was not being disabled when the row was disabled.



### [3.0.0](https://github.com/xmartlabs/Eureka/releases/tag/3.0.0)

Bug fixes & stability improvements:

* CountDownRow prints Date as Optional #683
* defaultOnCellHighlightChanged event not being called #704
* Error when compiling CustomRow with Swift 3.0 #693
* Fix strange animation when using `insertAtIndex` to add a new section to the form. #566
* Ability to customize validation message.
* New RuleEqualsToRow validation rule.
* fix RuleMaxLength & RuleMinLength issues. #729
* avoid `animateAlongsideTransition(in:` that could cause transition animation interruption.
* Fix initialisation of SliderRow when it has no value at start.
* Added isExpanded & isCollapsed helpers to InlineRowType.
* fix #800, added form.validate() argument to indicate if hiddenRows should be considered.
* Fix issue when showing StepperRow value. Now we use displayValueFor as we do with the rest of rows.
* Added PickerInputRow #818
* Fix an issue when FieldCell has a Formatter and the formatter is not used during text editing #796, #768
* Tapping inside an enabled text area row crashes #795
* Added ability to change scroll position when a row is selected.
* Added ability to specify that regex validation allows empty values.
* Changed the Access Control of Class RuleRegExp to be open.
* Implement init?(coder: NSCoder) for some cell types #860
* Removed fatalError from init(coder:) for selector view controllers #882
* Always call onSelectSelectableRow, added properties to control selector vc dismissal.
* Reload the tableView even if it is not added to a window.
* Adds 'cell.row.wasChanged' to check for cell validation.
* Added ability to group options of PushRow MultipleSelectorRow by adding sections to the selector table view.
* fix #887, TextAreaRow adds an enter when pressing next on keyboard coming from another row.
* Minor fix on how SliderRow update method is called.
* Adds RuleClosure example in code comments.
* Removing the forced navigationAccessoryView.tintColor set #921.

Thanks to all contributors!! 🍻🍻🍻🍻🍻🍻

### [2.0.1](https://github.com/xmartlabs/Eureka/releases/tag/2.0.1)

* Bug fixes and stability improvements.

### [2.0.0-beta.1](https://github.com/xmartlabs/Eureka/releases/tag/2.0.0)

Pull requests associated with this milestone can be found in this [filter](https://github.com/xmartlabs/Eureka/issues?utf8=%E2%9C%93&q=milestone%3A2.0.0%20).

We have made tons of changes to the Eureka API to follow the new Swift API design guidelines.
It's hard to enumerate all changes and most of them will be automatically suggested by Xcode.

We have also added to Eureka a extensible build-in validations support.

These are the most important changes...

#### Deleted

* `PostalAddressRow` was removed.
* `ImageRow` was removed.

You can find these both rows under [EurekaCommunity] github organization.

* Row's `func highlightCell()`
* Row's `func unhighlightCell()`
* Cell's `func highlight()`
* Cell's `func unhighlight()`
* Cell's `func didSelect()`

#### Added

* Rows's `var isHighlighted: Bool`.
* Rows's `var isValid: Bool`.
* Row's `func onCellHighlightChanged(_ callback: @escaping (_ cell: Cell, _ row: Self)->()) -> Self `.
* Row's `func onRowValidationChanged(_ callback: @escaping (_ cell: Cell, _ row: Self)->()) -> Self`.
* Row's `func validate() -> [ValidationError]`
* Form's `func validate() -> [ValidationError]`
* Row's `func add<Rule: RuleType>(rule: Rule)`
* Row's `func remove(ruleWithIdentifier: String)`
* `RuleSet<T: Equatable>` type.
* `ValidationOptions` Enum type.
* `RuleType` protocol.
* `ValidationError` type.

##### Fixes

* Fixed textlabel alignment for cells with custom constraints (FieldRow, SegmentedRow, TextAreaRow).
* Set 'Require Only App-Extension-Safe API' to YES to enable code sharing in App Extensions.
* Other bug fixes and minor improvements

Take a look at [2.0.0 Migration guide]() for more information on how to solve breaking changes.

### [1.7.0](https://github.com/xmartlabs/Eureka/releases/tag/1.7.0)

* **Breaking change**: Fixed typo in `hightlightCell`. You must now call / override `highlightCell`.
* Added `allSections` method to Form. (by @programmarchy)
* Updated navigation images for row navigation. (thanks @VladislavJevremovic)
* Removed +++= operator.
* Other bug fixes and minor improvements

### [1.6.0](https://github.com/xmartlabs/Eureka/releases/tag/1.6.0)

* **Breaking change**: Remove controller: FormViewController parameter from HeaderFooterViewRepresentable `viewForSection` method.


* Support for Xcode 7.3.1.
* Fixed ImageRow issue when trying to access imageURL after selecting image. Now imageURL is properly set up. #346
* Made FieldRowConformance protocol public.
* Added ability to override TextAreaRow constraints.
* Fix. Now section headerView/footerView cache is deleted whenever section header/footer is assigned.
* Made public `navigateToDirection(direction: Direction)` method.
* Fixed autolayout in cells. #396
* Removed cell.setNeedsLayout() and cell.setNeedsUpdateConstraints() from updateCell process.
* Added `ButtonRow` `onCellSelecttion` example.
* Improve row deselection behavior during interactive transitions. #406
* Autosize TextAreaRow functionality added.
* Moved `inputAccessoryViewForRow` method from extension to FormViewController allowing it to be overridden.
* Added ability to show a text when there is no value selected to some rows.
* Fixed: The top divider of a PickerInlineRow disappears upon selection.
* Fixed crash when selecting a date. DatePickerRow.
* Ensure inline row is visible when it’s expanded.
* Fixed PostalAddressRow - When a long form is scrolled up/down, values in Address box disappears.

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
[EurekaCommunity]: https://github.com/EurekaCommunity
