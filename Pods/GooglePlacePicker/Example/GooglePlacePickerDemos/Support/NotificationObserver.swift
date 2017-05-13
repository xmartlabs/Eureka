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

import Foundation

/// A small class for managing the lifecycle of a NSNotificationCenter registration. When the class
/// is deinited it will automatically unregister from the NSNotificationCenter.
class NotificationObserver<T: AnyObject>: NSObject {
  private weak var target: T?
  private let action: (T) -> (NSNotification) -> Void

  /// Create a new NotificationObserver with the specified notification name, target and action. The
  /// method action on target will be called with a NSNotification object anytime a notification
  /// is fired.
  ///
  /// The target is be weakly referenced and therefore instances of this class can safely be
  /// stored in instance variables, and do not need to be nilled out.
  ///
  /// - parameter name The name of the notification to listen for.
  /// - parameter target The object to call the method on whenever the notification is posted.
  /// - parameter action The method to call.
  init(name: NSNotification.Name, target: T, action: @escaping (T) -> (NSNotification) -> Void) {
    self.target = target
    self.action = action

    super.init()

    let sel = #selector(self.notificationFired(notification:))
    NotificationCenter.default.addObserver(self, selector: sel, name: name, object: nil)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  func notificationFired(notification: NSNotification) {
    guard let target = target else {
      // May as well deregister from notifications if our target has gone away.
      NotificationCenter.default.removeObserver(self)
      return
    }

    action(target)(notification)
  }
}
