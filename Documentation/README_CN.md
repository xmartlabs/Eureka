![Eureka: 一个优雅的用Swift编写的表单生成框架](../Eureka.jpg)

<p align="center">
<a href="https://travis-ci.org/xmartlabs/Eureka"><img src="https://travis-ci.org/xmartlabs/Eureka.svg?branch=master" alt="Build status" /></a>
<img src="https://img.shields.io/badge/platform-iOS-blue.svg?style=flat" alt="Platform iOS" />
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/swift4-compatible-4BC51D.svg?style=flat" alt="Swift 4 compatible" /></a>
<a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage compatible" /></a>
<a href="https://cocoapods.org/pods/Eureka"><img src="https://img.shields.io/cocoapods/v/Eureka.svg" alt="CocoaPods compatible" /></a>
<a href="https://raw.githubusercontent.com/xmartlabs/Eureka/master/LICENSE"><img src="http://img.shields.io/badge/license-MIT-blue.svg?style=flat" alt="License: MIT" /></a>
<a href="https://codebeat.co/projects/github-com-xmartlabs-eureka"><img alt="codebeat badge" src="https://codebeat.co/badges/16f29afb-f072-4633-9497-333c6eb71263" /></a>
</p>

由[XMARTLABS](http://xmartlabs.com)精心编写，是[XLForm]的Swift版本。

## 概览

<table>
  <tr>
    <th>
      <img src="../Example/Media/EurekaExample1.gif" width="220"/>
    </th>
    <th>
      <img src="../Example/Media/EurekaExample2.gif" width="220"/>
    </th>
    <th>
    <img src="../Example/Media/EurekaExample3.gif" width="220"/>
    </th>
  </tr>
</table>

## 目录

* [要求]
* [使用]
  + [如何创建表格]
  + [获取行的值]
  + [操作符]
  + [callbacks的使用]
  + [Section Header和Footer]
  + [动态地隐藏和显示row(或者Sections)]
  + [列表类型的sections]
  + [有多个值的sections]
  + [验证]
  + [滑动操作]
* [自定义row]
  + [简单的自定义rows]
  + [自定义内联rows]
  + [自定义Presenter rows]
* [row目录]
* [安装]
* [常见问题解答]

**想了解更多，可以查看我们的关于*Eureka*的[博客](https://blog.xmartlabs.com/2015/09/29/Introducing-Eureka-iOS-form-library-written-in-pure-Swift/)。**

## 要求

* Xcode 9.2+
* Swift 4+

### 示例程序

你可以clone这个项目，然后运行Example来欣赏Eureka的大部分特性。

<table>
  <tr>
    <th>
      <img src="../Example/Media/EurekaNavigation.gif" width="200"/>
    </th>
    <th>
      <img src="../Example/Media/EurekaRows.gif" width="200"/>
    </th>
  </tr>
</table>

## 使用

### 如何创建表格
通过继承 `FormViewController`，你可以很容易地把sections和rows添加到`form`变量。

```swift
import Eureka

class MyFormViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Section1")
            <<< TextRow(){ row in
                row.title = "Text Row"
                row.placeholder = "Enter text here"
            }
            <<< PhoneRow(){
                $0.title = "Phone Row"
                $0.placeholder = "And numbers here"
            }
        +++ Section("Section2")
            <<< DateRow(){
                $0.title = "Date Row"
                $0.value = Date(timeIntervalSinceReferenceDate: 0)
            }
    }
}
```

在这个例子中，我们创建了两个包含基本rows的sections，效果如下图：

<center>
<img src="../Example/Media/EurekaHowTo.gif" width="200" alt="Screenshot of Custom Cells"/>
</center>

你也可以不继承`FormViewController`，然后自己设置`form`变量。但是通过继承的话，会方便很多。

#### 配置键盘导航辅助

如果需要改变导航辅助，你需要设置控制器的`navigationOptions`变量，是一个`OptionSet`类型，所以我们可以给它设置一个或者多个值：

- **disabled**: 不显示
- **enabled**: 显示在底部
- **stopDisabledRow**: 如果下一行被禁用了，就隐藏
- **skipCanNotBecomeFirstResponderRow**: 如果当前行的`canBecomeFirstResponder()`返回`false`，导航辅助就跳过这行

默认值是 `enabled & skipCanNotBecomeFirstResponderRow`

如果需要流畅的滚动屏幕，要把`animateScroll`设置为`true`。默认情况下，在导航辅助上点击上一个和下一个按钮的时候，`FormViewController`是直接跳到上一行或者下一行的，包括上一行或者下一行不在屏幕内的时候。

如果要设置键盘和正在编辑的row的间距，设置`rowKeyboardSpacing`即可。默认情况下，当表格滚动到一个没有显示出来的view，键盘的顶部和编辑行的底部是没有间距的。

```swift
class MyFormViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        form = ...

	// 开启导航辅助，并且遇到被禁用的行就隐藏导航
	navigationOptions = RowNavigationOptions.Enabled.union(.StopDisabledRow)
	// 开启流畅地滚动到之前没有显示出来的行
	animateScroll = true
	// 设置键盘顶部和正在编辑行底部的间距为20
	rowKeyboardSpacing = 20
    }
}
```

如果你想要改变导航辅助，需要在`FormViewController`的子类重写`navigationAccessoryView`。


### 获取行的值

`Row`对象有一个具体类型的 ***value*** 。
例如，`SwitchRow`有一个`Bool`，而`TextRow`有一个`String`。

```swift
// 获取单个row的值
let row: TextRow? = form.rowBy(tag: "MyRowTag")
let value = row.value

// 获取表格中所有rows的值(必须给每个row的tag赋值)
// 字典中包含的键值对为：['rowTag': value]。
let valuesDictionary = form.values()
```

### 操作符

Eureka包含了自定义的操作符，使得我们更容易地创建表格：

#### +++ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;添加一个section
```swift
form +++ Section()

// 连起来添加多个sections
form +++ Section("First Section") +++ Section("Another Section")

// 或者直接利用行来创建一个空白的section
form +++ TextRow()
     +++ TextRow()  // 每个row显示在一个独立的section
```

#### <<< &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;插入一行

```swift
form +++ Section()
        <<< TextRow()
        <<< DateRow()

// 或者隐式地创建一个section
form +++ TextRow()
        <<< DateRow()
```

#### += &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 添加一个数组

```swift
// 添加多个Sections到表格中
form += [Section("A"), Section("B"), Section("C")]

// 添加多个rows到一个section中
section += [TextRow(), DateRow()]
```

### callbacks的使用

Eureka包含了很多callbacks来更改行的外观和行为。

#### 理解`Row`和`Cell`

`Row`是抽象的，是Eureka用来存储 **value** 的并包含了一个`Cell`。这个`Cell`用来管理view，并继承自`UITableViewCell`。

例子:

```swift
let row  = SwitchRow("SwitchRow") { row in      // 初始化函数
                        row.title = "The title"
                    }.onChange { row in
                        row.title = (row.value ?? false) ? "The title expands when on" : "The title"
                        row.updateCell()
                    }.cellSetup { cell, row in
                        cell.backgroundColor = .lightGray
                    }.cellUpdate { cell, row in
                        cell.textLabel?.font = .italicSystemFont(ofSize: 18.0)
                }
```

<img src="../Example/Media/EurekaOnChange.gif" width="300" alt="Screenshot of Disabled Row"/>

#### Callbacks清单

* **onChange()**

	当row的`value`改变时调用。你可以在这里调整一些参数，甚至显示或隐藏其他row。

* **onCellSelection()**

	当用户点击row并且被选中的时候调用。

* **cellSetup()**

	当cell第一次配置的时候调用，并且仅调用一次。可以在这做一些永久性的设置。

* **cellUpdate()**

	当cell每次在屏幕上显示的时候调用。可以在里个更新外观。

* **onCellHighlightChanged()**

  当cell或者里面的subview 成为或者辞去第一响应者 时调用。

* **onRowValidationChanged()**

  当与row关联的验证错误改变时调用。

* **onExpandInlineRow()**

  内联row展开前调用。适用于遵循`InlineRowType`协议的rows。

* **onCollapseInlineRow()**

  内联row折叠前调用。适用于遵循`InlineRowType`协议的rows。

* **onPresent()**

	在显示另外一个view controller之前调用。适用于遵循`PresenterRowType`的rows。可以在这里设置被显示的view controller。


### Section Header和Footer <a name="section-header-footer"></a>

你可以将`String`的title或者自定义的`View`作为`Section`的header或者footer。

#### String title
```swift
Section("Title")

Section(header: "Title", footer: "Footer Title")

Section(footer: "Footer Title")
```

#### 自定义View
你可以使用一个`.xib`作为自定义View：

```swift
Section() { section in
    var header = HeaderFooterView<MyHeaderNibFile>(.nibFile(name: "MyHeaderNibFile", bundle: nil))

    // header每次出现在屏幕的时候调用
    header.onSetupView = { view, _ in
        // 通常是在这修改view里面的文字
        // 不要在这修改view的大小或者层级关系
    }
    section.header = header
}
```

或者是一个使用纯代码创建的`UIView`

```swift
Section(){ section in
    var header = HeaderFooterView<MyCustomUIView>(.class)
    header.height = {100}
    header.onSetupView = { view, _ in
        view.backgroundColor = .red
    }
    section.header = header
}
```

或者直接用callback来创建view

```swift
Section(){ section in
    section.header = {
          var header = HeaderFooterView<UIView>(.callback({
              let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
              view.backgroundColor = .red
              return view
          }))
          header.height = { 100 }
          return header
        }()
}
```

### 动态地隐藏和显示row(或者Sections)  <a name="hide-show-rows"></a>

<img src="../Example/Media/EurekaSwitchSections.gif" width="300" alt="Screenshot of Hidden Rows" />

在这个例子里，我们隐藏或显示整个sections。

为了达到这个效果，每个row有一个`Condition`的可选类型的变量`hidden`，`Condition`可以通过`function`或者`NSPredicate`来设置。


#### 使用function condition来隐藏

使用`Condition`的`function` case:
```swift
Condition.function([String], (Form)->Bool)
```
`function`需要一个`Form`参数，并返回`Bool`，决定当前row是否需要隐藏。这是一个非常强大的设置`hidden`的方式，因为它没有明显的限制。

```swift
form +++ Section()
            <<< SwitchRow("switchRowTag"){
                $0.title = "Show message"
            }
            <<< LabelRow(){

                $0.hidden = Condition.function(["switchRowTag"], { form in
                    return !((form.rowBy(tag: "switchRowTag") as? SwitchRow)?.value ?? false)
                })
                $0.title = "Switch is on!"
        }
```

<img src="../Example/Media/EurekaHidden.gif" width="300" alt="Screenshot of Hidden Rows" />

```swift
public enum Condition {
    case function([String], (Form)->Bool)
    case predicate(NSPredicate)
}
```

#### 使用NSPredicate隐藏

`hidden`也可以用NSPredicate来设置。在predicate string里面，你可以引用其他row的tags，然后决定一个row是否需要隐藏。

但是使用NSPredicate来设置`hidden`的方式只适用于其他rows的value继承自NSObject（String 和 Int 也适用，因为它们被桥接到OjbC对应的类型，但是enums不适用）

使用NSPredicate限制这么多，我们为什么要使用它呢？
因为它比function更简单、更短而且更易读。例如下面这个例子：

```swift
$0.hidden = Condition.predicate(NSPredicate(format: "$switchTag == false"))
```

我们还可以写的更简单，因为`Condition`遵循`ExpressibleByStringLiteral`：

```swift
$0.hidden = "$switchTag == false"
```

*注意：我们会在执行的时候把'$switchTag'替换成tag为switchTag的row的value。*

所以的rows都必须有一个tag，我们会用这个tag去找到对应的row，这样才能达到我们想要的效果。

我们也可以直接隐藏一个row：
```swift
$0.hidden = true
```
因为`Condition`遵循`ExpressibleByBooleanLiteral`.

如果不设置`hidden`变量，那么对应的rows就会一直显示。

##### Sections

对于section来说，也是一样的。我们也可以通过设置`hidden`属性来控制显示或隐藏。

##### 禁用rows

为了禁用rows，每个row有一个`disable`变量，也是`Condition`的可选类型。使用的方式跟`hidden`一样，所以要求每个row有一个tag。

Note that if you want to disable a row permanently you can also set `disabled` variable to `true`.
注意：如果你想永久的禁用一个row，可以把`disabled`设置为`true`.

### 列表类型的sections

为了显示一个列表选项，Eukera有一个特殊的section，叫做`SelectableSection`。

当创建`SelectableSection`的时候，你需要传入在选项中使用的row的类型和`selectionTyle`。`selectionTyle`是一个枚举，`multipleSelection` 或者 `singleSelection(enableDeselection: Bool)`（`enableDeselection`决定选中的rows是否可以取消选中）。


```swift
form +++ SelectableSection<ListCheckRow<String>>("Where do you live", selectionType: .singleSelection(enableDeselection: true))

let continents = ["Africa", "Antarctica", "Asia", "Australia", "Europe", "North America", "South America"]
for option in continents {
    form.last! <<< ListCheckRow<String>(option){ listRow in
        listRow.title = option
        listRow.selectableValue = option
        listRow.value = nil
    }
}
```

##### 可以使用什么类型的row？

为了创建这样的section，你必须先创建一个遵循`SelectableRowType`协议的row。

```swift
public protocol SelectableRowType : RowType {
    var selectableValue : Value? { get set }
}
```

`selectableValue`是row的value，将会被永久存储。而`value`变量将会用来决定row是否选中，如果被选中，它的值就等于`selectableValue`，否则为nil。Eureka包含上面例子用到的`ListCheckRow`，在自定义rows的实例程序中，你还可以找到`ImageCheckRow`。

##### 获取选中的rows

为了获得`SelectableSection`中被选中的row，Eukera提供了两个方法：`selectedRow()`（获取`SingleSelection`选中的row） and `selectedRows()`获取`MultipleSelection`所有选中的rows。

##### 在sections中把选项分组

另外，你可以使用`SelectorViewController`的属性把选项列表分组。

- `sectionKeyForValue` - 是一个闭包，返回特定row的value对应的key，这个key被用来把选项分组。

- `sectionHeaderTitleForKey` - 是一个闭包，返回特定key对应的section的header title，默认是key本身的值。

- `sectionFooterTitleForKey` - 是一个闭包，返回特定key对应的section的footer title。

### 有多个值的sections

Eureka可以通过有多个值的section来支持一个字段对应多个值的情况。它允许我们很容易地创建能插入的、能删除的和能排序的sections。

<img src="../Example/Media/EurekaMultivalued.gif" width="300" alt="Screenshot of Multivalued Section" />

#### 如何创建多值section

为了创建一个多值section，我们要使用`MultivaluedSection` ，而不是常规的`Section`。`MultivaluedSection`继承自`Section`，拥有一些额外的属性来设置多值section的行为。

让我们来看一个例子：

```swift
form +++
    MultivaluedSection(multivaluedOptions: [.Reorder, .Insert, .Delete],
                       header: "Multivalued TextField",
                       footer: ".Insert adds a 'Add Item' (Add New Tag) button row as last cell.") {
        $0.addButtonProvider = { section in
            return ButtonRow(){
                $0.title = "Add New Tag"
            }
        }
        $0.multivaluedRowToInsertAt = { index in
            return NameRow() {
                $0.placeholder = "Tag Name"
            }
        }
        $0 <<< NameRow() {
            $0.placeholder = "Tag Name"
        }
    }
```

上面的代码演示了如何创建一个多值的section。在上面我们把insert, delete 和 reorder传给了`multivaluedOptions`。

`addButtonProvider`允许我们自定义button row，当点击这个button row并且`multivaluedOptions`包含`.Insert`的时候，就会添加一行。

`multivaluedRowToInsertAt`闭包在Eureka每次需要新的row插入的时候调用。为了提供一个row来插入到多值的section中，我们就要设置这个属性。Eureka传index作为闭包的参数。需要注意的是，我们可以返回任何类型的row，甚至自定义的row，即使在多数情况下多值section的rows都是同一类型的。

当我们创建多值section的时候，Eureka会自动添加button row。我们刚刚说到我们可以自定义button row的外观。默认情况下button row的左边有一个加号按钮，我们可以通过设置`showInsertIconInAddButton`属性来决定是否要显示加号按钮。

当创建一个可以插入的sections时，我们还需要更多的考虑。所以被添加到可插入的多值section的rows都应该放在Eureka通过点击按钮来插入的rows上面。我们可以在初始化section的时候，在最后一个闭包参数里添加额外的row，这样在点击button row的时候就会自动把要插入的rows放在最后面。

#### 编辑模式

默认情况下，Eureka只会在当表格中有含有MultivaluedSection的时候把tableView的`isEditing`设置为`true`，而且会在表格第一次显示时的`viewWillAppear`完成。

要了解更多如何使用多值section的相关信息，可以看下Eureka的示例程序，里面包含了多种用法。

### 验证

Eureka 2.0.0 内置了很多验证特性。

一个row有很多规则和一个用于决定rules是否需要验证的特定配置。

有很多规则是默认提供的，但是你也可以自己创建自己的规则。

默认提供的规则:
* RuleRequired
* RuleEmail
* RuleURL
* RuleGreaterThan, RuleGreaterOrEqualThan, RuleSmallerThan, RuleSmallerOrEqualThan
* RuleMinLength, RuleMaxLength
* RuleClosure

让我们看看如何设置验证规则。

```swift

override func viewDidLoad() {
        super.viewDidLoad()
        form
          +++ Section(header: "Required Rule", footer: "Options: Validates on change")

            <<< TextRow() {
                $0.title = "Required Rule"
                $0.add(rule: RuleRequired())

		// 这也可以通过一个闭包来实现：如果验证通过，返回nil，否则返回一个ValidationError。
		/*
		let ruleRequiredViaClosure = RuleClosure<String> { rowValue in
		return (rowValue == nil || rowValue!.isEmpty) ? ValidationError(msg: "Field required!") : nil
		}
		$0.add(rule: ruleRequiredViaClosure)
		*/

                $0.validationOptions = .validatesOnChange
            }
            .cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }

          +++ Section(header: "Email Rule, Required Rule", footer: "Options: Validates on change after blurred")

            <<< TextRow() {
                $0.title = "Email Rule"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleEmail())
                $0.validationOptions = .validatesOnChangeAfterBlurred
            }
            .cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }

```

从上面的代码可以看到，我们可以通过 `add(rule:)`设置多个我们想要的规则。

Row还提供了`func remove(ruleWithIdentifier identifier: String)`来移除规则。为了使用这个方法，我们必须在创建规则的时候，给规则设置一个id。

有时候我们想要在这个row上使用的规则，跟其他rows是一样的。这种情况下，我们可以使用`RuleSet`来设置所以规则：

```swift
var rules = RuleSet<String>()
rules.add(rule: RuleRequired())
rules.add(rule: RuleEmail())

let row = TextRow() {
            $0.title = "Email Rule"
            $0.add(ruleSet: rules)
            $0.validationOptions = .validatesOnChangeAfterBlurred
        }
```

Eureka允许我们指定何时执行验证规则。我们可以通过row的`validationOptions`属性来设置，它有以下这些值：

* `.validatesOnChange` - 当row的value改变时执行。
* `.validatesOnBlur` - （默认值）当cell辞去第一响应者时执行，不适用于所有rows。
* `.validatesOnChangeAfterBlurred` - 在第一次辞去第一响应者之后，row的value改变时执行
* `.validatesOnDemand` - 我们需要手动调用`validate()`来验证row或者form

如果你想验证整个form（或者所有rows），你可以手动调用Form的`validate()`方法。

#### 如何获取验证错误

每个row都有一个`validationErrors`属性，可以用来获取所有验证错误。这个属性仅仅存储了最后一次验证的错误清单，并不会执行验证规则。

#### 注意类型

正如我们所想的那样，规则的类型必须与row的类型相同。要格外小心检查所使用的row类型。你可能会看到这个编译错误：`"(Incorrect arugment label in call (have 'rule:' expected 'ruleSet:')"`，这并不是把类型混淆了的问题。

### 滑动操作

Eureka 4.1.0 引入了滑动特性.

现在你可以为每一行定义多个`leadingSwipe` 和 `trailingSwipe`操作。因为滑动操作决定于iOS系统的特性，所以`leadingSwipe`只能用于iOS 11 以上的系统。

让我们看看如何定义滑动操作：

```swift
let row = TextRow() {
            let deleteAction = SwipeAction(
                style: .destructive,
                title: "Delete",
                handler: { (action, row, completionHandler) in
                    // 在这添加你的代码
                    // 操作完成后一定要调用completionHandler
                    completionHandler?(true)
                })
            deleteAction.image = UIImage(named: "icon-trash")

            $0.trailingSwipe.actions = [deleteAction]
            $0.trailingSwipe.performsFirstActionWithFullSwipe = true

            // 请注意：`leadingSwipe`只能用于iOS 11以上的系统
            let infoAction = SwipeAction(
                style: .normal,
                title: "Info",
                handler: { (action, row, completionHandler) in
                    // 在这添加你的代码
                    // 操作完成后一定要调用completionHandler
                    completionHandler?(true)
                })
            infoAction.backgroundColor = .blue
            infoAction.image = UIImage(named: "icon-info")

            $0.leadingSwipe.actions = [infoAction]
            $0.leadingSwipe.performsFirstActionWithFullSwipe = true
        }
```

滑动操作需要把`tableView.isEditing`设置为`false`。Eureka会在当表格中有含有MultivaluedSection的时候把tableView的`isEditing`设置为`true`（在`viewWillAppear`设置）。如果你在同一个表格中同时拥有MultivaluedSections和滑动操作，你要根据情况来设置`isEditing`。

## 自定义row

通常你需要自定义不同于Eureka内置的row。这其实不是很难，你可以阅读[如何自定义rows的教程](https://blog.xmartlabs.com/2016/09/06/Eureka-custom-row-tutorial/)来开始。你也可以看看[EurekaCommunity]，这里包含了其他rows，并准备加入到Eukera中。

### 简单的自定义rows

为了创建一个拥有自定义行为和外观的row，你可能需要继承于`Row`和`Cell`。

请记住`Row`是Eureka使用的抽象类；而`Cell`实际上是`UITableViewCell`，用于管理view。
因为`Row`包含了`Cell`，所以`Row`和`Cell`必须同时定义。

```swift
// 自定义value类型是Bool的Cell
// Cell是使用 .xib 定义的，所以我们可以直接设置outlets
public class CustomCell: Cell<Bool>, CellType {
    @IBOutlet weak var switchControl: UISwitch!
    @IBOutlet weak var label: UILabel!

    public override func setup() {
        super.setup()
        switchControl.addTarget(self, action: #selector(CustomCell.switchValueChanged), for: .valueChanged)
    }

    func switchValueChanged(){
        row.value = switchControl.on
        row.updateCell() // Re-draws the cell which calls 'update' bellow
    }

    public override func update() {
        super.update()
        backgroundColor = (row.value ?? false) ? .white : .black
    }
}

// 自定义的Row，拥有CustomCell和对应的value
public final class CustomRow: Row<CustomCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应CustomCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<CustomCell>(nibName: "CustomCell")
    }
}
```
结果: <br>
<img src="../Example/Media/EurekaCustomRow.gif" alt="Screenshot of Disabled Row"/>

<br>

自定义rows需要继承自 `Row<CellType>`，并遵循`RowType`协议。
自定义的cells必须继承自`Cell<ValueType>`，并遵循`CellType`协议。

就像cellSetup和CellUpdate回调一样，`Cell`有setup和update方法，你可以在里面做自定义。


### 自定义内联rows

内联row是一个特定的row类型，可以在它下面动态的显示一个row。正常来说内联row在被点击时在展开和折叠两种状态切换。

所以，为了创建一个内联row，我们需要两个rows，一个总是显示的row，另外一个被展开和折叠的row。

另外一个要求是，这两个rows的value类型必须是一样的。

一旦我们拥有了两个rows，我们要让第一个row遵循`InlineRowType`，这将会给第一个row添加一些方法：

```swift
func expandInlineRow()
func hideInlineRow()
func toggleInlineRow()
```

最后，当row被点击时我们要调用`toggleInlineRow()`，例如重写`customDidSelect()`方法：

```swift
public override func customDidSelect() {
    toggleInlineRow()
}
```

### 自定义Presenter rows <a name="presenter-rows"></a>

**注意:** *一个Presenter row 是可以弹出UIViewController的row。*

为了创建一个Presenter rows，必须创建一个遵循`PresenterRowType`的类。高度推荐继承自`SelectorRow`，因为它遵循了那个协议并且添加了其他很有用的方法。

`PresenterRowType`协议的定义如下:
```swift
public protocol PresenterRowType: TypedRowType {
    typealias ProviderType : UIViewController, TypedRowControllerType
    var presentationMode: PresentationMode<ProviderType>? { get set }
    var onPresentCallback: ((FormViewController, ProviderType)->())? { get set }
}
```

`onPresentCallback`将会在row即将显示另外一个view controller的时候调用。在`SelectorRow`里面已经调用了，如果你没有继承自它的话，你需要自己手动调用。

`presentationMode`定义了应该显示哪个controller和怎么显示controller。我们可以通过Segue identifier、segue class、present或者push来展示controller。例如一个CustomPushRow可以像这样定义：

```swift
public final class CustomPushRow<T: Equatable>: SelectorRow<PushSelectorCell<T>, SelectorViewController<T>>, RowType {

    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .show(controllerProvider: ControllerProvider.callback {
            return SelectorViewController<T>(){ _ in }
            }, onDismiss: { vc in
                _ = vc.navigationController?.popViewController(animated: true)
        })
    }
}
```

你可以用自己的UIViewController替换`SelectorViewController<T>`，用自己的cell替换`PushSelectorCell<T>`。

### 使用相同的row来子类化cells

有时候我们想要改变我们其中一个row的外观，但是不需要改变row的类型和已有的逻辑。如果我们使用的cell是通过`xib`文件来初始化的，那么现在有一种方法能达到我们的要求。目前，所有Eureka内置的rows都不是通过`xib`来初始化的，但是[EurekaCommunity]的一些自定义rows是通过`xib`初始化，例如[PostalAddressRow](https://github.com/EurekaCommunity/PostalAddressRow)。

你所需要做的是：

* 创建一个包含你想要创建的cell的nib文件。
* 然后把cell的class设置为你想要修改的cell（如果你想要更改除了UI以外的东西，你需要子类化那个cell。），并且确保那个cell的module是正确的。
* 把outlets连接到类中
* 告诉你的row使用这个新的nib文件。这是通过设置`cellProvider`来完成的，这个设置需要在具体的初始化过程或者`defaultRowInitializer`里面完成。例如：

```swift
<<< PostalAddressRow() {
     $0.cellProvider = CellProvider<PostalAddressCell>(nibName: "CustomNib", bundle: Bundle.main)
}
```

另外，你也可以创建一个新的row来达到目的。这种情况下你要继承同一个父类，让这个row继承它的逻辑。

当我们在实现这个的时候，有些东西可以考虑下：

* 如果你想要看例子，你可以看看[PostalAddressRow](https://github.com/EurekaCommunity/PostalAddressRow)或者[CreditCardRow](https://github.com/EurekaCommunity/CreditCardRow)，它们都是用了自定义的nib文件。
* 如果你遇到了这样的错误：`Unknown class <YOUR_CLASS_NAME> in Interface Builder file`，可能是你需要在代码中的某个位置、在运行的时候实例化那个新的类型。我是通过调用`let t = YourClass.self`来解决的。




## row目录

### Controls Rows
<table>
    <tr>
        <td><center><b>Label Row</b><br>
        <img src="../Example/Media/RowStatics/LabelRow.png"/>
        </center><br><br>
        </td>
        <td><center><b>Button Row</b><br>
        <img src="../Example/Media/RowStatics/ButtonRow.png"/>
        </center><br><br>
        </td>
        <td><center><b>Check Row</b><br>
        <img src="../Example/Media/RowStatics/CheckRow.png"/>
        </center><br><br>
        </td>
    </tr>
    <tr>
        <td><center><b>Switch Row</b><br>
        <img src="../Example/Media/RowStatics/SwitchRow.png"/>
        </center><br><br>
        </td>
        <td><center><b>Slider Row</b><br>
        <img src="../Example/Media/RowStatics/SliderRow.png"/>
        </center><br><br>
        </td>
        <td><center><b>Stepper Row</b><br>
        <img src="../Example/Media/RowStatics/StepperRow.png"/>
        </center><br><br>
        </td>
    </tr>
    <tr>
        <td><center><b>Text Area Row</b><br>
        <img src="../Example/Media/RowStatics/TextAreaRow.png"/>
        </center><br><br>
        </td>
    </tr>
</table>

### Field Rows

这些rows在cell的右边有一个textField，它们的不同之处在于包含不同的大小写、自动更正和键盘类型配置。

<table>
<tr>
  <td>
    <img src="../Example/Media/CatalogFieldRows.jpg" width="300"/>
  </td>
  <td>
  TextRow<br><br>
  NameRow<br><br>
  URLRow<br><br>
  IntRow<br><br>
  PhoneRow<br><br>
  PasswordRow<br><br>
  EmailRow<br><br>
  DecimalRow<br><br>
  TwitterRow<br><br>
  AccountRow<br><br>
  ZipCodeRow
  </td>
<tr>
</table>

上面所有的`FieldRow`类型都有一个<a href="https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSFormatter_Class/">`NSFormatter`</a>类型的`formatter`属性，可以用来控制row的value如何显示。Eureka内置了一个可以保留两位小数的formatter，`DecimalFormatter`。实例程序中包含了`CurrencyFormatter`，可以根据用户所在地显示相应的货币格式。

默认情况下，设置row的`formatter`只会影响到在没有被编辑的时候的显示格式。如果要在编辑的时候也要格式化，要在初始化row的时候把`useFormatterDuringInput`设置为`true`。编辑的时候格式化value的时候可能需要更新光标的位置，Eukera提供了下面的协议，你的formatter需要遵循这个协议来处理光标的位置：

```swift
public protocol FormatterProtocol {
    func getNewPosition(forPosition forPosition: UITextPosition, inTextInput textInput: UITextInput, oldValue: String?, newValue: String?) -> UITextPosition
}
```

另外，`FieldRow`有一个`useFormatterOnDidBeginEditing`属性。当使用`DecimalRow`的时候，并且有一个允许decimal value和遵循用户所在地的formatter，例如`DecimalFormatter`，如果`useFormatterDuringInput`是`false`，`useFormatterOnDidBeginEditing`必须设置为`true`，这样value中的小数点才能匹配键盘中的小数点。

### Date Rows

Date Rows存储了一个Date，并且允许我们通过UIDatePicker来设置一个新的值。UIDatePicker的模式和date picker view的显示方法如下图：

<table>
<tr>
<td>
<center><b>Date Row</b>
<img src="../Example/Media/RowGifs/EurekaDateRow.gif" height="220" width="230" />
<br>
Picker在键盘上显示
</center>
</td>
<td>
<center><b>Date Row (Inline)</b>
<img src="../Example/Media/RowGifs/EurekaDateInlineRow.gif" height="220" width="210"/>
<br>
row展开
</center>
</td>
<td>
<center><b>Date Row (Picker)</b>
<img src="../Example/Media/RowGifs/EurekaDatePickerRow.gif" height="220" width="210"/>
<br>
picker一直显示
</center>
</td>
</tr>
</table>

有三种风格（Normal、Inline和Picker），Eureka还包括：

+ **DateRow**
+ **TimeRow**
+ **DateTimeRow**
+ **CountDownRow**

### Option Rows

Option Rows关联着用户必须选择的一系列选项。

```swift
<<< ActionSheetRow<String>() {
                $0.title = "ActionSheetRow"
                $0.selectorTitle = "Pick a number"
                $0.options = ["One","Two","Three"]
                $0.value = "Two"    // initially selected
            }
```

<table>
<tr>
<td width="25%">
<center><b>Alert Row</b><br>
<img src="../Example/Media/RowStatics/AlertRow.jpeg"/>
<br>
通过Alert的方式显示。
</center>
</td>
<td width="25%">
<center><b>ActionSheet Row</b><br>
<img src="../Example/Media/RowStatics/ActionSheetRow.jpeg"/>
<br>
通过action sheet的方式显示。
</center>
</td>
<td width="25%">
<center><b>Push Row</b><br>
<img src="../Example/Media/RowStatics/PushRow.jpeg"/>
<br>
push到一个新的controller。
</center>
</td>
<td width="25%">
<center><b>Multiple Selector Row</b><br>
<img src="../Example/Media/RowStatics/MultipleSelectorRow.jpeg"/>
<br>
像PushRow一样，但是允许多选。
</center>
</td>
</tr>
</table>

<table>
    <tr>
        <td><center><b>Segmented Row</b><br>
        <img src="../Example/Media/RowStatics/SegmentedRow.png"/>
        </center>
        </td>
        <td><center><b>Segmented Row (w/Title)</b><br>
        <img src="../Example/Media/RowStatics/SegmentedRowWithTitle.png"/>
        </center>
        </td>
        <td><center><b>Picker Row</b><br>
        <img src="../Example/Media/RowStatics/PickerRow.png"/>
        <br>通过picker view来显示通用类型选项
        <br><b>(也有Picker内联Row)</b>
        </center>
        </td>
    </tr>
</table>

### 建立自己的自定义row?
让我们知道它，我们会跟高兴的在这提到它。:)

* **LocationRow** (在示例程序中作为自定义row)

<img src="../Example/Media/EurekaLocationRow.gif" width="300" alt="Screenshot of Location Row"/>

## 安装

#### CocoaPods

[CocoaPods](https://cocoapods.org/) 是一个管理Cocoa项目的依赖。

在项目中的`Podfile`文件指定Eureka:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

pod 'Eureka'
```

然后运行下面的命令:

```bash
$ pod install
```

#### Carthage

[Carthage](https://github.com/Carthage/Carthage) 是一个简单的、分散的Cocoa依赖管理器。

在项目中的`Cartfile`文件文件指定Eureka:

```ogdl
github "xmartlabs/Eureka" ~> 4.0
```

#### 手动集成框架

* 在项目的根目录运行下列代码克隆Eureka，作为一个git [submodule](http://git-scm.com/docs/git-submodule)。

```bash
$ git submodule add https://github.com/xmartlabs/Eureka.git
```

* 克隆完成后，打开Eureka文件夹，然后把`Eureka.xcodeproj`拖动到Xcode项目的Project Navigator中

* 在Project Navigator选中`Eureka.xcodeproj`，检查deployment target是否跟应用的匹配

* 在Project Navigator选中你自己的项目，选择自己应用的target，然后选择在"General"选项卡，在`Embedded Binaries`点击加号

* 选择`Eureka.framework`，大功告成。

## 参与其中

* 如果你想贡献，请随时提交pull request。
* 如果你有新功能要求，请开一个issue。
* 如果你找到了一个bug，在提交新的issue之前，请先查看旧的issues。
* 如果你需要帮助，或者询问常见的问题，使用[StackOverflow]。（Tag `eureka-forms`）

**在贡献之前，请先查看[CONTRIBUTING](../CONTRIBUTING.md)文件了解更多信息。**

如果你在你的项目中使用了**Eureka**，我们很想听到这个消息。可以在[twitter]给我发消息。

## 作者

* [Martin Barreto](https://github.com/mtnBarreto) ([@mtnBarreto](https://twitter.com/mtnBarreto))
* [Mathias Claassen](https://github.com/mats-claassen) ([@mClaassen26](https://twitter.com/mClaassen26))

## 常见问题解答

#### 如果通过tag获取Row

我们可以通过调用`Form`暴露的下列方法来获取特定的row：

```swift
public func rowBy<T: Equatable>(tag: String) -> RowOf<T>?
public func rowBy<Row: RowType>(tag: String) -> Row?
public func rowBy(tag: String) -> BaseRow?
```

例如:

```swift
let dateRow : DateRow? = form.rowBy(tag: "dateRowTag")
let labelRow: LabelRow? = form.rowBy(tag: "labelRowTag")

let dateRow2: Row<DateCell>? = form.rowBy(tag: "dateRowTag")

let labelRow2: BaseRow? = form.rowBy(tag: "labelRowTag")
```

#### 如果使用tag获取Section

```swift
let section: Section?  = form.sectionBy(tag: "sectionTag")
```

#### 如果使用dictionary来设置form的值

调用`Form`暴露的`setValues(values: [String: Any?])`方法.

例如:

```swift
form.setValues(["IntRowTag": 8, "TextRowTag": "Hello world!", "PushRowTag": Company(name:"Xmartlabs")])
```

`"IntRowTag"`、 `"TextRowTag"`、 `"PushRowTag"` 是row tag (每个都唯一地标识一个row)， `8`、 `"Hello world!"`、 `Company(name:"Xmartlabs")` 是对应的要赋给row的值。

row的value类型必须匹配dictionary中对应值的类型，否则会将nil赋给row的value。

如果form已经显示了，我们必须刷新已经显示的rows，可以通过调用`tableView.reloadData()`来刷新table view，或者调用已经显示的row的`updateCell()`方法。

#### 更改hidden或者disable condition后，Row没有更新

在设置了一个condition之后，这个condition不会自动执行，如果你想要马上执行，你可以调用`.evaluateHidden()` 或者 `.evaluateDisabled()`。

这些方法仅仅在row被添加到form时和row改变时调用。如果这个condition被更改了，但是这个row处于显示状态，必须手动执行。

#### 除非onCellHighlight也被定义了，否则onCellUnHighlight不会被调用

查看这个[issue](https://github.com/xmartlabs/Eureka/issues/96).

#### 如更新 Section header/footer

* 设置新的 header/footer ....

```swift
section.header = HeaderFooterView(title: "Header title \(variable)") // 使用 String interpolation
//或者
var header = HeaderFooterView<UIView>(.class) // 使用任何view类型更灵活地设置header
header.height = { 60 }  // 可以指高度
header.onSetupView = { view, section in  // 每次view即将显示时，onSetupView被调用
    view.backgroundColor = .orange
}
section.header = header
```

* 刷新Section

```swift
section.reload()
```

#### 如何自定义Selector 和 MultipleSelector 选项的cells

`selectableRowSetup`、`selectableRowCellUpdate` 和 `selectableRowCellSetup` 可以自定义 SelectorViewController 和 MultipleSelectorViewController的可选cells.

```swift
let row = PushRow<Emoji>() {
              $0.title = "PushRow"
              $0.options = [💁🏻, 🍐, 👦🏼, 🐗, 🐼, 🐻]
              $0.value = 👦🏼
              $0.selectorTitle = "Choose an Emoji!"
          }.onPresent { from, to in
              to.dismissOnSelection = false
              to.dismissOnChange = false
              to.selectableRowSetup = { row in
                  row.cellProvider = CellProvider<ListCheckCell<Emoji>>(nibName: "EmojiCell", bundle: Bundle.main)
              }
              to.selectableRowCellUpdate = { cell, row in
                  cell.textLabel?.text = "Text " + row.selectableValue!  // 自定义
                  cell.detailTextLabel?.text = "Detail " +  row.selectableValue!
              }
          }

```

#### 不想使用Eureka提供的自定义操作符？

正如我们所说的，`Form`和`Section`遵循`MutableCollection`和`RangeReplaceableCollection`。一个Form是一个Sections的集合，一个Sections是一个Rows的集合。

`RangeReplaceableCollection` 协议扩展提供了很多方法来改变集合。

```swift
extension RangeReplaceableCollection {
    public mutating func append(_ newElement: Self.Element)
    public mutating func append<S>(contentsOf newElements: S) where S : Sequence, Self.Element == S.Element
    public mutating func insert(_ newElement: Self.Element, at i: Self.Index)
    public mutating func insert<S>(contentsOf newElements: S, at i: Self.Index) where S : Collection, Self.Element == S.Element
    public mutating func remove(at i: Self.Index) -> Self.Element
    public mutating func removeSubrange(_ bounds: Range<Self.Index>)
    public mutating func removeFirst(_ n: Int)
    public mutating func removeFirst() -> Self.Element
    public mutating func removeAll(keepingCapacity keepCapacity: Bool)
    public mutating func reserveCapacity(_ n: Self.IndexDistance)
}
```

上面的方法在内部用来实现自定义的操作：

```swift
public func +++(left: Form, right: Section) -> Form {
    left.append(right)
    return left
}

public func +=<C : Collection>(inout lhs: Form, rhs: C) where C.Element == Section {
    lhs.append(contentsOf: rhs)
}

public func <<<(left: Section, right: BaseRow) -> Section {
    left.append(right)
    return left
}

public func +=<C : Collection>(inout lhs: Section, rhs: C) where C.Element == BaseRow {
    lhs.append(contentsOf: rhs)
}
```

你可以在[这里](https://github.com/xmartlabs/Eureka/blob/master/Source/Core/Operators.swift)看到剩下的自定义操作符是如何实现的。

是否要用自定义的操作符，完全由你自己决定。

<!--- In file -->
[要求]: #要求

[使用]: #使用
[如何创建表格]: #如何创建表格
[获取行的值]: #获取行的值
[操作符]: #操作符
[callbacks的使用]: #callbacks的使用
[Section Header和Footer]: #section-header-footer
[动态地隐藏和显示row(或者Sections)]: #hide-show-rows
[列表类型的sections]: #列表类型的sections
[有多个值的sections]: #有多个值的sections
[验证]: #验证
[滑动操作]: #滑动操作

[自定义row]: #自定义row
[简单的自定义rows]: #简单的自定义rows
[自定义内联rows]: #自定义内联rows
[自定义Presenter rows]: #presenter-rows
[row目录]: #row目录

[安装]: #安装
[常见问题解答]: #常见问题解答


<!--- In Project -->
[CustomCellsController]: ../Example/Example/ViewController.swift
[FormViewController]: ../Example/Source/Controllers.swift

<!--- External -->
[XLForm]: https://github.com/xmartlabs/XLForm
[DSL]: https://en.wikipedia.org/wiki/Domain-specific_language
[StackOverflow]: http://stackoverflow.com/questions/tagged/eureka-forms
[our blog post]: http://blog.xmartlabs.com/2015/09/29/Introducing-Eureka-iOS-form-library-written-in-pure-Swift/
[twitter]: https://twitter.com/xmartlabs
[EurekaCommunity]: https://github.com/EurekaCommunity

# 捐赠Eureka

所以我们可以让Eureka变得更好！<br><br>
[<img src="../donate.png"/>](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=HRMAH7WZ4QQ8E)

# 更改日志

可以在[CHANGELOG.md](../CHANGELOG.md)文件中查看。
