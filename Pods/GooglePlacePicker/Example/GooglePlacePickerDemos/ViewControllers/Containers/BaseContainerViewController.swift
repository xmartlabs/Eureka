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

/// Base view controller for the two container view controllers in the demo. This class monitors the
/// current traitCollection and provides a property |actualTraitCollection| which can be used to
/// access the most recent trait collection.
class BaseContainerViewController: UIViewController {
  private var _actualTraitCollection: AnyObject? = nil

  @available(iOS 8.0, *)
  /// Retrieve the most recent trait collection. This will usually be the same as |traitCollection|
  /// but will differ during trait transitions. During a trait transition |traitCollection| will
  /// still have the old value of the trait collection, whereas |actualTraitCollection| will store
  /// the value of the new trait collection.
  internal var actualTraitCollection: UITraitCollection {
    get {
      if let collection = _actualTraitCollection as? UITraitCollection {
        return collection
      }
      return traitCollection
    }
  }

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @available(iOS 8.0, *)
  /// Monitor for trait collection changes so |actualTraitCollection| can be kept up to date.
  override func willTransition(to newCollection: UITraitCollection,
                               with coordinator: UIViewControllerTransitionCoordinator) {
    _actualTraitCollection = newCollection
    super.willTransition(to: newCollection, with: coordinator)
  }
}
