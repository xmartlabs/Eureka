//  CustomCells.swift
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

import Foundation
import UIKit
import MapKit
import Eureka

//MARK: WeeklyDayCell

public enum WeekDay {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}

public class WeekDayCell : Cell<Set<WeekDay>>, CellType {

    @IBOutlet var sundayButton: UIButton!
    @IBOutlet var mondayButton: UIButton!
    @IBOutlet var tuesdayButton: UIButton!
    @IBOutlet var wednesdayButton: UIButton!
    @IBOutlet var thursdayButton: UIButton!
    @IBOutlet var fridayButton: UIButton!
    @IBOutlet var saturdayButton: UIButton!

    open override func setup() {
        height = { 60 }
        row.title = nil
        super.setup()
        selectionStyle = .none
        for subview in contentView.subviews {
            if let button = subview as? UIButton {
                button.setImage(UIImage(named: "checkedDay"), for: .selected)
                button.setImage(UIImage(named: "uncheckedDay"), for: .normal)
                button.adjustsImageWhenHighlighted = false
                imageTopTitleBottom(button)
            }
        }
    }

    open override func update() {
        row.title = nil
        super.update()
        let value = row.value
        mondayButton.isSelected = value?.contains(.monday) ?? false
        tuesdayButton.isSelected = value?.contains(.tuesday) ?? false
        wednesdayButton.isSelected = value?.contains(.wednesday) ?? false
        thursdayButton.isSelected = value?.contains(.thursday) ?? false
        fridayButton.isSelected = value?.contains(.friday) ?? false
        saturdayButton.isSelected = value?.contains(.saturday) ?? false
        sundayButton.isSelected = value?.contains(.sunday) ?? false

        mondayButton.alpha = row.isDisabled ? 0.6 : 1.0
        tuesdayButton.alpha = mondayButton.alpha
        wednesdayButton.alpha = mondayButton.alpha
        thursdayButton.alpha = mondayButton.alpha
        fridayButton.alpha = mondayButton.alpha
        saturdayButton.alpha = mondayButton.alpha
        sundayButton.alpha = mondayButton.alpha
    }

    @IBAction func dayTapped(_ sender: UIButton) {
        dayTapped(sender, day: getDayFromButton(sender))
    }

    private func getDayFromButton(_ button: UIButton) -> WeekDay{
        switch button{
        case sundayButton:
            return .sunday
        case mondayButton:
            return .monday
        case tuesdayButton:
            return .tuesday
        case wednesdayButton:
            return .wednesday
        case thursdayButton:
            return .thursday
        case fridayButton:
            return .friday
        default:
            return .saturday
        }
    }

    private func dayTapped(_ button: UIButton, day: WeekDay){
        button.isSelected = !button.isSelected
        if button.isSelected{
            row.value?.insert(day)
        }
        else{
            _ = row.value?.remove(day)
        }
    }

    private func imageTopTitleBottom(_ button : UIButton){

        guard let imageSize = button.imageView?.image?.size else { return }
        let spacing : CGFloat = 3.0
        button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -imageSize.width, bottom: -(imageSize.height + spacing), right: 0.0)
        guard let titleLabel = button.titleLabel, let title = titleLabel.text else { return }
        let titleSize = title.size(withAttributes: [.font: titleLabel.font])
        button.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0, bottom: 0, right: -titleSize.width)
    }
}

//MARK: WeekDayRow

public final class WeekDayRow: Row<WeekDayCell>, RowType {

    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<WeekDayCell>(nibName: "WeekDaysCell")
    }
}


//MARK: FloatLabelCell

public class _FloatLabelCell<T>: Cell<T>, UITextFieldDelegate, TextFieldCell where T: Equatable, T: InputTypeInitiable {

    public var textField: UITextField! { return floatLabelTextField }

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy public var floatLabelTextField: FloatLabelTextField = { [unowned self] in
        let floatTextField = FloatLabelTextField()
        floatTextField.translatesAutoresizingMaskIntoConstraints = false
        floatTextField.font = .preferredFont(forTextStyle: .body)
        floatTextField.titleFont = .boldSystemFont(ofSize: 11.0)
        floatTextField.clearButtonMode = .whileEditing
        return floatTextField
        }()


    open override func setup() {
        super.setup()
        height = { 55 }
        selectionStyle = .none
        contentView.addSubview(floatLabelTextField)
        floatLabelTextField.delegate = self
        floatLabelTextField.addTarget(self, action: #selector(_FloatLabelCell.textFieldDidChange(_:)), for: .editingChanged)
        contentView.addConstraints(layoutConstraints())
    }

    open override func update() {
        super.update()
        textLabel?.text = nil
        detailTextLabel?.text = nil
        floatLabelTextField.attributedPlaceholder = NSAttributedString(string: row.title ?? "", attributes: [.foregroundColor: UIColor.lightGray])
        floatLabelTextField.text =  row.displayValueFor?(row.value)
        floatLabelTextField.isEnabled = !row.isDisabled
        floatLabelTextField.titleTextColour = .lightGray
        floatLabelTextField.alpha = row.isDisabled ? 0.6 : 1
    }

    open override func cellCanBecomeFirstResponder() -> Bool {
        return !row.isDisabled && floatLabelTextField.canBecomeFirstResponder
    }

    open override func cellBecomeFirstResponder(withDirection direction: Direction) -> Bool {
        return floatLabelTextField.becomeFirstResponder()
    }

    open override func cellResignFirstResponder() -> Bool {
        return floatLabelTextField.resignFirstResponder()
    }

    private func layoutConstraints() -> [NSLayoutConstraint] {
        let views = ["floatLabeledTextField": floatLabelTextField]
        let metrics = ["vMargin":8.0]
        return NSLayoutConstraint.constraints(withVisualFormat: "H:|-[floatLabeledTextField]-|", options: .alignAllLastBaseline, metrics: metrics, views: views) + NSLayoutConstraint.constraints(withVisualFormat: "V:|-(vMargin)-[floatLabeledTextField]-(vMargin)-|", options: .alignAllLastBaseline, metrics: metrics, views: views)
    }

    @objc public func textFieldDidChange(_ textField : UITextField){
        guard let textValue = textField.text else {
            row.value = nil
            return
        }
        if let fieldRow = row as? FormatterConformance, let formatter = fieldRow.formatter {
            if fieldRow.useFormatterDuringInput {
                let value: AutoreleasingUnsafeMutablePointer<AnyObject?> = AutoreleasingUnsafeMutablePointer<AnyObject?>.init(UnsafeMutablePointer<T>.allocate(capacity: 1))
                let errorDesc: AutoreleasingUnsafeMutablePointer<NSString?>? = nil
                if formatter.getObjectValue(value, for: textValue, errorDescription: errorDesc) {
                    row.value = value.pointee as? T
                    if var selStartPos = textField.selectedTextRange?.start {
                        let oldVal = textField.text
                        textField.text = row.displayValueFor?(row.value)
                        if let f = formatter as? FormatterProtocol {
                            selStartPos = f.getNewPosition(forPosition: selStartPos, inTextInput: textField, oldValue: oldVal, newValue: textField.text)
                        }
                        textField.selectedTextRange = textField.textRange(from: selStartPos, to: selStartPos)
                    }
                    return
                }
            }
            else {
                let value: AutoreleasingUnsafeMutablePointer<AnyObject?> = AutoreleasingUnsafeMutablePointer<AnyObject?>.init(UnsafeMutablePointer<T>.allocate(capacity: 1))
                let errorDesc: AutoreleasingUnsafeMutablePointer<NSString?>? = nil
                if formatter.getObjectValue(value, for: textValue, errorDescription: errorDesc) {
                    row.value = value.pointee as? T
                }
                return
            }
        }
        guard !textValue.isEmpty else {
            row.value = nil
            return
        }
        guard let newValue = T.init(string: textValue) else {
            return
        }
        row.value = newValue
    }


    //Mark: Helpers

    private func displayValue(useFormatter: Bool) -> String? {
        guard let v = row.value else { return nil }
        if let formatter = (row as? FormatterConformance)?.formatter, useFormatter {
            return textField?.isFirstResponder == true ? formatter.editingString(for: v) : formatter.string(for: v)
        }
        return String(describing: v)
    }

    //MARK: TextFieldDelegate

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        formViewController()?.beginEditing(of: self)
        if let fieldRowConformance = row as? FormatterConformance, let _ = fieldRowConformance.formatter, fieldRowConformance.useFormatterOnDidBeginEditing ?? fieldRowConformance.useFormatterDuringInput {
            textField.text = displayValue(useFormatter: true)
        } else {
            textField.text = displayValue(useFormatter: false)
        }
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        formViewController()?.endEditing(of: self)
        formViewController()?.textInputDidEndEditing(textField, cell: self)
        textFieldDidChange(textField)
        textField.text = displayValue(useFormatter: (row as? FormatterConformance)?.formatter != nil)
    }
}

public class TextFloatLabelCell : _FloatLabelCell<String>, CellType {

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func setup() {
        super.setup()
        textField?.autocorrectionType = .default
        textField?.autocapitalizationType = .sentences
        textField?.keyboardType = .default
    }
}


public class IntFloatLabelCell : _FloatLabelCell<Int>, CellType {

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func setup() {
        super.setup()
        textField?.autocorrectionType = .default
        textField?.autocapitalizationType = .none
        textField?.keyboardType = .numberPad
    }
}

public class PhoneFloatLabelCell : _FloatLabelCell<String>, CellType {

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func setup() {
        super.setup()
        textField?.keyboardType = .phonePad
    }
}

public class NameFloatLabelCell : _FloatLabelCell<String>, CellType {

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func setup() {
        super.setup()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        textField.keyboardType = .asciiCapable
    }
}

public class EmailFloatLabelCell : _FloatLabelCell<String>, CellType {

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func setup() {
        super.setup()
        textField?.autocorrectionType = .no
        textField?.autocapitalizationType = .none
        textField?.keyboardType = .emailAddress
    }
}

public class PasswordFloatLabelCell : _FloatLabelCell<String>, CellType {

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func setup() {
        super.setup()
        textField?.autocorrectionType = .no
        textField?.autocapitalizationType = .none
        textField?.keyboardType = .asciiCapable
        textField?.isSecureTextEntry = true
    }
}

public class DecimalFloatLabelCell : _FloatLabelCell<Float>, CellType {

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func setup() {
        super.setup()
        textField?.keyboardType = .decimalPad
    }
}

public class URLFloatLabelCell : _FloatLabelCell<URL>, CellType {

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func setup() {
        super.setup()
        textField?.autocorrectionType = .no
        textField?.autocapitalizationType = .none
        textField?.keyboardType = .URL
    }
}

public class TwitterFloatLabelCell : _FloatLabelCell<String>, CellType {

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func setup() {
        super.setup()
        textField?.autocorrectionType = .no
        textField?.autocapitalizationType = .none
        textField?.keyboardType = .twitter
    }
}

public class AccountFloatLabelCell : _FloatLabelCell<String>, CellType {

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func setup() {
        super.setup()
        textField?.autocorrectionType = .no
        textField?.autocapitalizationType = .none
        textField?.keyboardType = .asciiCapable
    }
}



//MARK: FloatLabelRow

open class FloatFieldRow<Cell: CellType>: FormatteableRow<Cell> where Cell: BaseCell, Cell: TextFieldCell {


    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

public final class TextFloatLabelRow: FloatFieldRow<TextFloatLabelCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}
public final class IntFloatLabelRow: FloatFieldRow<IntFloatLabelCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}
public final class DecimalFloatLabelRow: FloatFieldRow<DecimalFloatLabelCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}
public final class URLFloatLabelRow: FloatFieldRow<URLFloatLabelCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}
public final class TwitterFloatLabelRow: FloatFieldRow<TwitterFloatLabelCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}
public final class AccountFloatLabelRow: FloatFieldRow<AccountFloatLabelCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}
public final class PasswordFloatLabelRow: FloatFieldRow<PasswordFloatLabelCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}
public final class NameFloatLabelRow: FloatFieldRow<NameFloatLabelCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}
public final class EmailFloatLabelRow: FloatFieldRow<EmailFloatLabelCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}
public final class PhoneFloatLabelRow: FloatFieldRow<PhoneFloatLabelCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}


//MARK: LocationRow

public final class LocationRow: OptionsRow<PushSelectorCell<CLLocation>>, PresenterRowType, RowType {
    
    public typealias PresenterRow = MapViewController
    
    /// Defines how the view controller will be presented, pushed, etc.
    public var presentationMode: PresentationMode<PresenterRow>?
    
    /// Will be called before the presentation occurs.
    public var onPresentCallback: ((FormViewController, PresenterRow) -> Void)?

    
    
    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .show(controllerProvider: ControllerProvider.callback { return MapViewController(){ _ in } }, onDismiss: { vc in _ = vc.navigationController?.popViewController(animated: true) })

        displayValueFor = {
            guard let location = $0 else { return "" }
            let fmt = NumberFormatter()
            fmt.maximumFractionDigits = 4
            fmt.minimumFractionDigits = 4
            let latitude = fmt.string(from: NSNumber(value: location.coordinate.latitude))!
            let longitude = fmt.string(from: NSNumber(value: location.coordinate.longitude))!
            return  "\(latitude), \(longitude)"
        }
    }
    
    /**
     Extends `didSelect` method
     */
    public override func customDidSelect() {
        super.customDidSelect()
        guard let presentationMode = presentationMode, !isDisabled else { return }
        if let controller = presentationMode.makeController() {
            controller.row = self
            controller.title = selectorTitle ?? controller.title
            onPresentCallback?(cell.formViewController()!, controller)
            presentationMode.present(controller, row: self, presentingController: self.cell.formViewController()!)
        } else {
            presentationMode.present(nil, row: self, presentingController: self.cell.formViewController()!)
        }
    }
    
    /**
     Prepares the pushed row setting its title and completion callback.
     */
    public override func prepare(for segue: UIStoryboardSegue) {
        super.prepare(for: segue)
        guard let rowVC = segue.destination as? PresenterRow else { return }
        rowVC.title = selectorTitle ?? rowVC.title
        rowVC.onDismissCallback = presentationMode?.onDismissCallback ?? rowVC.onDismissCallback
        onPresentCallback?(cell.formViewController()!, rowVC)
        rowVC.row = self
    }
}

public class MapViewController : UIViewController, TypedRowControllerType, MKMapViewDelegate {

    public var row: RowOf<CLLocation>!
    public var onDismissCallback: ((UIViewController) -> ())?

    lazy var mapView : MKMapView = { [unowned self] in
        let v = MKMapView(frame: self.view.bounds)
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return v
        }()

    lazy var pinView: UIImageView = { [unowned self] in
        let v = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        v.image = UIImage(named: "map_pin", in: Bundle(for: MapViewController.self), compatibleWith: nil)
        v.image = v.image?.withRenderingMode(.alwaysTemplate)
        v.tintColor = self.view.tintColor
        v.backgroundColor = .clear
        v.clipsToBounds = true
        v.contentMode = .scaleAspectFit
        v.isUserInteractionEnabled = false
        return v
        }()

    let width: CGFloat = 10.0
    let height: CGFloat = 5.0

    lazy var ellipse: UIBezierPath = { [unowned self] in
        let ellipse = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: self.width, height: self.height))
        return ellipse
        }()


    lazy var ellipsisLayer: CAShapeLayer = { [unowned self] in
        let layer = CAShapeLayer()
        layer.bounds = CGRect(x: 0, y: 0, width: self.width, height: self.height)
        layer.path = self.ellipse.cgPath
        layer.fillColor = UIColor.gray.cgColor
        layer.fillRule = .nonZero
        layer.lineCap = .butt
        layer.lineDashPattern = nil
        layer.lineDashPhase = 0.0
        layer.lineJoin = .miter
        layer.lineWidth = 1.0
        layer.miterLimit = 10.0
        layer.strokeColor = UIColor.gray.cgColor
        return layer
        }()


    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }

    convenience public init(_ callback: ((UIViewController) -> ())?){
        self.init(nibName: nil, bundle: nil)
        onDismissCallback = callback
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)

        mapView.delegate = self
        mapView.addSubview(pinView)
        mapView.layer.insertSublayer(ellipsisLayer, below: pinView.layer)

        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(MapViewController.tappedDone(_:)))
        button.title = "Done"
        navigationItem.rightBarButtonItem = button

        if let value = row.value {
            let region = MKCoordinateRegion(center: value.coordinate, latitudinalMeters: 400, longitudinalMeters: 400)
            mapView.setRegion(region, animated: true)
        }
        else{
            mapView.showsUserLocation = true
        }
        updateTitle()

    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let center = mapView.convert(mapView.centerCoordinate, toPointTo: pinView)
        pinView.center = CGPoint(x: center.x, y: center.y - (pinView.bounds.height/2))
        ellipsisLayer.position = center
    }


    @objc func tappedDone(_ sender: UIBarButtonItem){
        let target = mapView.convert(ellipsisLayer.position, toCoordinateFrom: mapView)
        row.value = CLLocation(latitude: target.latitude, longitude: target.longitude)
        onDismissCallback?(self)
    }

    func updateTitle(){
        let fmt = NumberFormatter()
        fmt.maximumFractionDigits = 4
        fmt.minimumFractionDigits = 4
        let latitude = fmt.string(from: NSNumber(value: mapView.centerCoordinate.latitude))!
        let longitude = fmt.string(from: NSNumber(value: mapView.centerCoordinate.longitude))!
        title = "\(latitude), \(longitude)"
    }

    public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        ellipsisLayer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.pinView.center = CGPoint(x: self!.pinView.center.x, y: self!.pinView.center.y - 10)
            })
    }

    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        ellipsisLayer.transform = CATransform3DIdentity
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.pinView.center = CGPoint(x: self!.pinView.center.x, y: self!.pinView.center.y + 10)
            })
        updateTitle()
    }
}

public final class ImageCheckRow<T: Equatable>: Row<ImageCheckCell<T>>, SelectableRowType, RowType {
    public var selectableValue: T?
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
}

public class ImageCheckCell<T: Equatable> : Cell<T>, CellType {

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Image for selected state
    lazy public var trueImage: UIImage = {
        return UIImage(named: "selected")!
    }()

    /// Image for unselected state
    lazy public var falseImage: UIImage = {
        return UIImage(named: "unselected")!
    }()

    public override func update() {
        super.update()
        checkImageView?.image = row.value != nil ? trueImage : falseImage
        checkImageView?.sizeToFit()
    }
    
    /// Image view to render images. If `accessoryType` is set to `checkmark`
    /// will create a new `UIImageView` and set it as `accessoryView`.
    /// Otherwise returns `self.imageView`.
    open var checkImageView: UIImageView? {
        guard accessoryType == .checkmark else {
            return self.imageView
        }
        
        guard let accessoryView = accessoryView else {
            let imageView = UIImageView()
            self.accessoryView = imageView
            return imageView
        }
        
        return accessoryView as? UIImageView
    }

    public override func setup() {
        super.setup()
        accessoryType = .none
    }

    public override func didSelect() {
        row.reload()
        row.select()
        row.deselect()
    }

}

class EmojiCell: ListCheckCell<Emoji> {}
