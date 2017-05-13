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
import GoogleMaps

/// A view controller which displays a map which continually pans around the area specified as
/// a coordinate.
class BackgroundMapViewController: UIViewController, CAAnimationDelegate {
  // MARK: - Properties
  private var mapView: GMSMapView?
  private let zoomLevel = Float(12)
  private let animationDuration = CFTimeInterval(30)
  private var isAnimating = false
  private var reduceMotionChanged: NotificationObserver<BackgroundMapViewController>?
  private var lowPowerModeChanged: NotificationObserver<BackgroundMapViewController>?

  /// The coordinate to animate the map around.
  var coordinate = CLLocationCoordinate2D(latitude: -33.8675, longitude: 151.2070) { // Sydney
    didSet {
      updateCoordinate()
    }
  }

  // MARK: - View Controller Lifecycle

  override func loadView() {
    mapView = GMSMapView()
    view = mapView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.isUserInteractionEnabled = false
    updateCoordinate()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    // Start animating the map when it becomes visible.
    startAnimatingMap()

    if #available(iOS 8.0, *) {
      // Restart the animation whenever the 'reduce motion' setting changes. This will allow the
      // animation code to adjust for the setting. See the implementation of startAnimating() for
      // more details.
      let notificationName = NSNotification.Name.UIAccessibilityReduceMotionStatusDidChange
      reduceMotionChanged = NotificationObserver(name: notificationName, target: self,
                                                 action: type(of: self).restartAnimation)
    }

    if #available(iOS 9.0, *) {
      // Much like 'reduce motion', detect changes in 'lower power mode' and restart the animation.
      let notificationName = NSNotification.Name.NSProcessInfoPowerStateDidChange
      lowPowerModeChanged = NotificationObserver(name: notificationName, target: self,
                                                 action: type(of: self).restartAnimation)
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    // And stop it when it is no longer onscreen.
    stopAnimatingMap()

    // Stop listening for 'reduce motion' and 'low power mode' changes if we're not going to be
    // visible.
    reduceMotionChanged = nil
    lowPowerModeChanged = nil
  }

  func restartAnimation(notification: NSNotification) {
    self.stopAnimatingMap()
    self.startAnimatingMap()
  }

  // MARK: Implementation

  private func updateCoordinate() {
    if let mapView = mapView {
      // Start and stop the map animating if needed.
      let wasAnimating = isAnimating
      stopAnimatingMap()

      // Set the camera on the map to look at the specified coordinate.
      mapView.camera = GMSCameraPosition(target: coordinate, zoom: zoomLevel, bearing: 0,
                                         viewingAngle: 0)

      if wasAnimating {
        startAnimatingMap()
      }
    }
  }

  private func startAnimatingMap() {
    if #available(iOS 8.0, *) {
      // If 'reduce motion' is enabled, don't start the animation.
      if UIAccessibilityIsReduceMotionEnabled() {
        return
      }
    }

    if #available(iOS 9.0, *) {
      // If 'low power mode' is enabled, don't start the animation.
      if ProcessInfo.processInfo.isLowPowerModeEnabled {
        return
      }
    }

    isAnimating = true

    // Grab the last coordinate which the map was centered on.
    let lastCoordinate = mapView?.camera.target ?? coordinate

    // Generate a random lat,lng which is near to the specified coordinate.
    //
    // NOTE: This code is not the recommended way of picking a random coordinate, but for the
    // purposes of this demo it is sufficient. As the relationship between distance and latitude
    // varies over the surface of the earth, the amount of distance between the target coordinate
    // and the center coordinate will change significantly. Another example of how this is not
    // correct for most use-cases is that it does not handle the wrapping from -180° to +180°
    // which occurs at the antimeridian.
    let targetCoordinate = CLLocationCoordinate2D(latitude: coordinate.latitude + randomOffset(),
                                                  longitude: coordinate.longitude + randomOffset())

    // Set the target coordinate on the map layer.
    mapView?.layer.cameraLatitude = targetCoordinate.latitude
    mapView?.layer.cameraLongitude = targetCoordinate.longitude

    // Setup two explicit animations to animate from the last coordinate to the target coordinate.
    // This has to be two animations as we have to manipulate latitude and longitude separately.
    // Use the duration we specified at the top of the file, and use a nice timing function to get
    // a smoother transition when we start/stop the animation.
    let latAnimation = CABasicAnimation(keyPath: kGMSLayerCameraLatitudeKey)
    latAnimation.fromValue = lastCoordinate.latitude
    latAnimation.toValue = targetCoordinate.latitude
    latAnimation.duration = animationDuration
    latAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    let lngAnimation = CABasicAnimation(keyPath: kGMSLayerCameraLongitudeKey)
    lngAnimation.fromValue = lastCoordinate.longitude
    lngAnimation.toValue = targetCoordinate.longitude
    lngAnimation.duration = animationDuration
    lngAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)

    // Create an animation group for the two animations.
    let group = CAAnimationGroup()
    group.animations = [latAnimation, lngAnimation]
    group.duration = animationDuration
    // Set ourselves as the delegate so that we can continue with the next step in the animation
    // when this one is done.
    group.delegate = self

    // Start the animations.
    mapView?.layer.add(group, forKey: nil)
  }

  private func randomOffset() -> CLLocationDegrees {
    // Pick a random value from -0.05 to 0.05.
    return Double(arc4random()) / Double(UINT32_MAX) * 0.1 - 0.05
  }

  private func stopAnimatingMap() {
    isAnimating = false
    mapView?.layer.removeAllAnimations()
  }

  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    // Start the animation again if we're still running it.
    if isAnimating {
      startAnimatingMap()
    }
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .default
  }
}
