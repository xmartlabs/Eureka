# Eureka 2.0 Migration  Guide

#### Requirements:

Eureka 2.0.0 needs Xcode 8, Swift3+ to work. Minimum supported iOS version is 8.0.

#### Changes

Eureka 2.0.0 includes complete Swift 3 Compatibility and adopts the new [API Design Guidelines](https://swift.org/documentation/api-design-guidelines/). It also includes the whole new validations build-in feature.
Bring support to swift 3 involves some API updates to follow Apple's Swift API best practices, we have also changed and deprecated some API's.

Most important changes will be listed below...


Many properties, methods, types were renamed and Xcode should suggest the fix automatically.



These are some examples:

|Old API| New API|
|----|----|
|`func rowByTag<T: Equatable>(_: String) -> RowOf<T>?`|`func rowBy<T: Equatable>(tag: String) -> RowOf<T>?`|
|`func rowByTag<Row: RowType>(_: String) -> Row?`|`func rowBy<Row: RowType>(tag: String) -> Row?`|
|`func rowByTag(_: String) -> BaseRow?`|`func rowBy(tag: String) -> BaseRow?`|
|`func sectionByTag(_: String) -> Section?`|`func sectionBy(tag: String) -> Section?`|
|`func rowValueHasBeenChanged(_: BaseRow, oldValue: Any?, newValue: Any?)`|`func valueHasBeenChanged(for: BaseRow, oldValue: Any?, newValue: Any?)`|
|`public final func indexPath() -> IndexPath?`|`public final var indexPath: IndexPath?`|
|`func prepareForSegue(_ segue: UIStoryboardSegue)`|`func prepare(for segue: UIStoryboardSegue)`|
|`func presentViewController(_ viewController: VCType!, row: BaseRow, presentingViewController:FormViewController)`|`present(_ viewController: VCType!, row: BaseRow, presentingViewController:FormViewController)`|
|`func createController() -> VCType?`|`func makeController() -> VCType?`|


There are also some breaking changes related with deprecated API:

Removed APIs:

* `PostalAddressRow` and `ImageRow` was deleted. You can find them and many other custom rows at EurekaCommunity [organization account](https://github.com/eurekaCommunity).
* `highlightCell` and `unhighlightCell` callbacks were deleted, now we should use `row.isHighlighted` from cell update to check from highlighted status and make UI modification according its value.

In case you want to do something when the row's highlighted state switches its value you can set up `onCellHighlightChanged` callback.

Custom Rows changes:

Row generic type no longer specify the value type. Its Value type is inferred from cell specification.

Before:

`public final class WeekDayRow: Row<Set<WeekDay>, WeekDayCell>, RowType`


After:

`public final class WeekDayRow: Row<WeekDayCell>, RowType`
