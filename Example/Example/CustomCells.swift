//  CustomCells.swift
//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2015 Xmartlabs ( http://xmartlabs.com )
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
    case Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
}

public class WeekDayCell : Cell<Set<WeekDay>>, CellType {
    
    @IBOutlet var sundayButton: UIButton!
    @IBOutlet var mondayButton: UIButton!
    @IBOutlet var tuesdayButton: UIButton!
    @IBOutlet var wednesdayButton: UIButton!
    @IBOutlet var thursdayButton: UIButton!
    @IBOutlet var fridayButton: UIButton!
    @IBOutlet var saturdayButton: UIButton!
        
    public override func setup() {
        height = { 60 }
        row.title = nil
        super.setup()
        selectionStyle = .None
        for subview in contentView.subviews {
            if let button = subview as? UIButton {
                button.setImage(UIImage(named: "checkedDay"), forState: UIControlState.Selected)
                button.setImage(UIImage(named: "uncheckedDay"), forState: UIControlState.Normal)
                button.adjustsImageWhenHighlighted = false
                imageTopTitleBottom(button)
            }
        }
    }
    
    public override func update() {
        row.title = nil
        super.update()
        let value = row.value
        mondayButton.selected = value?.contains(.Monday) ?? false
        tuesdayButton.selected = value?.contains(.Tuesday) ?? false
        wednesdayButton.selected = value?.contains(.Wednesday) ?? false
        thursdayButton.selected = value?.contains(.Thursday) ?? false
        fridayButton.selected = value?.contains(.Friday) ?? false
        saturdayButton.selected = value?.contains(.Saturday) ?? false
        sundayButton.selected = value?.contains(.Sunday) ?? false
        
        mondayButton.alpha = row.isDisabled ? 0.6 : 1.0
        tuesdayButton.alpha = mondayButton.alpha
        wednesdayButton.alpha = mondayButton.alpha
        thursdayButton.alpha = mondayButton.alpha
        fridayButton.alpha = mondayButton.alpha
        saturdayButton.alpha = mondayButton.alpha
        sundayButton.alpha = mondayButton.alpha
    }
    
    @IBAction func dayTapped(sender: UIButton) {
        dayTapped(sender, day: getDayFromButton(sender))
    }
    
    private func getDayFromButton(button: UIButton) -> WeekDay{
        switch button{
        case sundayButton:
            return .Sunday
        case mondayButton:
            return .Monday
        case tuesdayButton:
            return .Tuesday
        case wednesdayButton:
            return .Wednesday
        case thursdayButton:
            return .Thursday
        case fridayButton:
            return .Friday
        default:
            return .Saturday
        }
    }
    
    private func dayTapped(button: UIButton, day: WeekDay){
        button.selected = !button.selected
        if button.selected{
            row.value?.insert(day)
        }
        else{
            row.value?.remove(day)
        }
    }
    
    private func imageTopTitleBottom(button : UIButton){
        
        guard let imageSize = button.imageView?.image?.size else { return }
        let spacing : CGFloat = 3.0
        button.titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize.width, -(imageSize.height + spacing), 0.0)
        guard let titleLabel = button.titleLabel, let title = titleLabel.text else { return }
        let titleSize = title.sizeWithAttributes([NSFontAttributeName: titleLabel.font])
        button.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height + spacing), 0, 0, -titleSize.width)
    }
}

//MARK: WeekDayRow

public final class WeekDayRow: Row<Set<WeekDay>, WeekDayCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<WeekDayCell>(nibName: "WeekDaysCell")
    }
}


//MARK: FloatLabelCell

public class FloatLabelCell: Cell<String>, CellType, UITextFieldDelegate {
        
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    lazy public var floatLabelTextField: FloatLabelTextField = { [unowned self] in
        let floatTextField = FloatLabelTextField()
        floatTextField.translatesAutoresizingMaskIntoConstraints = false
        floatTextField.font = .preferredFontForTextStyle(UIFontTextStyleBody)
        floatTextField.titleFont = .boldSystemFontOfSize(11.0)
        floatTextField.clearButtonMode = .WhileEditing
        return floatTextField
        }()
    
    
    public override func setup() {
        super.setup()
        height = { 55 }
        selectionStyle = .None
        contentView.addSubview(floatLabelTextField)
        floatLabelTextField.delegate = self
        contentView.addConstraints(layoutConstraints())
    }
    
    public override func update() {
        super.update()
        textLabel?.text = nil
        floatLabelTextField.attributedPlaceholder = NSAttributedString(string: row.title ?? "", attributes: [NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        floatLabelTextField.text = row.value
        floatLabelTextField.enabled = !row.isDisabled
        floatLabelTextField.titleTextColour = .lightGrayColor()
        floatLabelTextField.alpha = row.isDisabled ? 0.6 : 1
    }
    
    public override func cellCanBecomeFirstResponder() -> Bool {
        return !row.isDisabled && floatLabelTextField.canBecomeFirstResponder()
    }
    
    public override func cellBecomeFirstResponder() -> Bool {
        return floatLabelTextField.becomeFirstResponder()
    }
    
    private func layoutConstraints() -> [NSLayoutConstraint] {
        let views = ["floatLabeledTextField": floatLabelTextField]
        let metrics = ["vMargin":8.0]
        return NSLayoutConstraint.constraintsWithVisualFormat("H:|-[floatLabeledTextField]-|", options: .AlignAllBaseline, metrics: metrics, views: views) + NSLayoutConstraint.constraintsWithVisualFormat("V:|-(vMargin)-[floatLabeledTextField]-(vMargin)-|", options: .AlignAllBaseline, metrics: metrics, views: views)
    }
}

//MARK: FloatLabelRow

public final class FloatLabelRow: Row<String, FloatLabelCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
}


//MARK: LocationRow

public final class LocationRow : SelectorRow<CLLocation, MapViewController>, RowType, PresenterRowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .Show(controllerProvider: ControllerProvider.Callback { return MapViewController(){ _ in } }, completionCallback: { vc in vc.navigationController?.popViewControllerAnimated(true) })
        displayValueFor = {
            guard let location = $0 else { return "" }
            let fmt = NSNumberFormatter()
            fmt.maximumFractionDigits = 4
            fmt.minimumFractionDigits = 4
            let latitude = fmt.stringFromNumber(location.coordinate.latitude)!
            let longitude = fmt.stringFromNumber(location.coordinate.longitude)!
            return  "\(latitude), \(longitude)"
        }
    }
}

public class MapViewController : UIViewController, TypedRowControllerType, MKMapViewDelegate {
    
    public var row: RowOf<CLLocation>!
    public var completionCallback : ((UIViewController) -> ())?
    
    lazy var mapView : MKMapView = { [unowned self] in
        let v = MKMapView(frame: self.view.bounds)
        v.autoresizingMask = UIViewAutoresizing.FlexibleWidth.union(UIViewAutoresizing.FlexibleHeight)
        return v
        }()
    
    lazy var pinView: UIImageView = { [unowned self] in
        let v = UIImageView(frame: CGRectMake(0, 0, 50, 50))
        v.image = UIImage(named: "map_pin", inBundle: NSBundle(forClass: MapViewController.self), compatibleWithTraitCollection: nil)
        v.image = v.image?.imageWithRenderingMode(.AlwaysTemplate)
        v.tintColor = self.view.tintColor
        v.backgroundColor = .clearColor()
        v.clipsToBounds = true
        v.contentMode = .ScaleAspectFit
        v.userInteractionEnabled = false
        return v
        }()
    
    let width: CGFloat = 10.0
    let height: CGFloat = 5.0
    
    lazy var ellipse: UIBezierPath = { [unowned self] in
        let ellipse = UIBezierPath(ovalInRect: CGRectMake(0 , 0, self.width, self.height))
        return ellipse
        }()
    
    
    lazy var ellipsisLayer: CAShapeLayer = { [unowned self] in
        let layer = CAShapeLayer()
        layer.bounds = CGRectMake(0, 0, self.width, self.height)
        layer.path = self.ellipse.CGPath
        layer.fillColor = UIColor.grayColor().CGColor
        layer.fillRule = kCAFillRuleNonZero
        layer.lineCap = kCALineCapButt
        layer.lineDashPattern = nil
        layer.lineDashPhase = 0.0
        layer.lineJoin = kCALineJoinMiter
        layer.lineWidth = 1.0
        layer.miterLimit = 10.0
        layer.strokeColor = UIColor.grayColor().CGColor
        return layer
        }()
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience public init(_ callback: (UIViewController) -> ()){
        self.init(nibName: nil, bundle: nil)
        completionCallback = callback
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        
        mapView.delegate = self
        mapView.addSubview(pinView)
        mapView.layer.insertSublayer(ellipsisLayer, below: pinView.layer)
        
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "tappedDone:")
        button.title = "Done"
        navigationItem.rightBarButtonItem = button
        
        if let value = row.value {
            let region = MKCoordinateRegionMakeWithDistance(value.coordinate, 400, 400)
            mapView.setRegion(region, animated: true)
        }
        else{
            mapView.showsUserLocation = true
        }
        updateTitle()
        
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let center = mapView.convertCoordinate(mapView.centerCoordinate, toPointToView: pinView)
        pinView.center = CGPointMake(center.x, center.y - (CGRectGetHeight(pinView.bounds)/2))
        ellipsisLayer.position = center
    }
    
    
    func tappedDone(sender: UIBarButtonItem){
        let target = mapView.convertPoint(ellipsisLayer.position, toCoordinateFromView: mapView)
        row.value? = CLLocation(latitude: target.latitude, longitude: target.longitude)
        completionCallback?(self)
    }
    
    func updateTitle(){
        let fmt = NSNumberFormatter()
        fmt.maximumFractionDigits = 4
        fmt.minimumFractionDigits = 4
        let latitude = fmt.stringFromNumber(mapView.centerCoordinate.latitude)!
        let longitude = fmt.stringFromNumber(mapView.centerCoordinate.longitude)!
        title = "\(latitude), \(longitude)"
    }
    
    public func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        pinAnnotationView.pinColor = MKPinAnnotationColor.Red
        pinAnnotationView.draggable = false
        pinAnnotationView.animatesDrop = true
        return pinAnnotationView
    }
    
    public func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        ellipsisLayer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
        UIView.animateWithDuration(0.2, animations: { [weak self] in
            self?.pinView.center = CGPointMake(self!.pinView.center.x, self!.pinView.center.y - 10)
            })
    }
    
    public func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        ellipsisLayer.transform = CATransform3DIdentity
        UIView.animateWithDuration(0.2, animations: { [weak self] in
            self?.pinView.center = CGPointMake(self!.pinView.center.x, self!.pinView.center.y + 10)
            })
        updateTitle()
    }
}



