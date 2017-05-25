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

/// A simple UIButton subclass which displays a rounded border.
class RoundedButton: UIButton {
  override var bounds: CGRect {
    didSet(oldBounds) {
      // Whenever the bounds change.
      if oldBounds.height != bounds.height {
        // Update the layer appearance.
        layer.cornerRadius = bounds.size.height/2

        // And notify the autolayout engine that our intrinsic width has changed.
        invalidateIntrinsicContentSize()
      }
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.style()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.style()
  }

  private func style() {
    // We want a 1px thin white border.
    layer.borderWidth = 1
    layer.borderColor = UIColor.white.cgColor
  }

  /// Expand the default intrinsicContentSize so that the corners look nice.
  override var intrinsicContentSize: CGSize {
    var size = super.intrinsicContentSize
    // Add some padding to the left and right
    size.width += bounds.height
    return size
  }
}
