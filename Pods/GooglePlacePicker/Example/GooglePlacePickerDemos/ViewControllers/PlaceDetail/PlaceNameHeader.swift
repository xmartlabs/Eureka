/*
 * Copyright 2016 Google Inc. All rights reserved.
 *
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
 * file except in compliance with the License. You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

import UIKit

/// The view which displays the name of a |GMSPlace|.
class PlaceNameHeader: UITableViewHeaderFooterView {
  static let nib = { UINib(nibName: "PlaceNameHeader", bundle: nil) }()
  static let reuseIdentifier = "PlaceNameHeader"
  @IBOutlet private weak var placeNameLabel: UILabel!
  @IBOutlet private weak var topConstraint: NSLayoutConstraint!
  @IBOutlet weak var leadingConstraint: NSLayoutConstraint!

  // Override the textLabel property so that |UITableView| automatically knows how to set the text.
  override var textLabel: UILabel? {
    get {
      return placeNameLabel
    }
  }

  var compact = false {
    didSet {
      topConstraint.constant = compact ? 9 : 29
    }
  }

  override func awakeFromNib() {
    // Create a background view for the header.
    let background = UIView(frame: bounds)

    // Place a drop shadow at the top edge so that we nicely overlay the photo & map.
    let shadow = ShadowLineView()
    shadow.shadowOpacity = 0.6
    shadow.shadowSize = 3
    shadow.enableShadow = true
    shadow.shadowColor = Colors.blue2
    shadow.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 0)
    shadow.autoresizingMask = [.flexibleBottomMargin, .flexibleWidth]
    background.addSubview(shadow)

    // Add the solid color we want on top of the drop shadow to hide all but the top edge of it.
    let color = UIView(frame: background.bounds)
    color.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    color.backgroundColor = Colors.blue2
    background.addSubview(color)

    // Set it as the background.
    backgroundView = background

    if #available(iOS 8.0, *) {
    } else {
      placeNameLabel.font = UIFont.systemFont(ofSize: 20)
    }
  }
}
