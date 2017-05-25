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

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import "GoogleMapsDemos/Samples/MyLocationViewController.h"

#import <GoogleMaps/GoogleMaps.h>

@implementation MyLocationViewController {
  GMSMapView *_mapView;
  BOOL _firstLocationUpdate;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                          longitude:151.2086
                                                               zoom:12];

  _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
  _mapView.settings.compassButton = YES;
  _mapView.settings.myLocationButton = YES;

  // Listen to the myLocation property of GMSMapView.
  [_mapView addObserver:self
             forKeyPath:@"myLocation"
                options:NSKeyValueObservingOptionNew
                context:NULL];

  self.view = _mapView;

  // Ask for My Location data after the map has already been added to the UI.
  dispatch_async(dispatch_get_main_queue(), ^{
    _mapView.myLocationEnabled = YES;
  });
}

- (void)dealloc {
  [_mapView removeObserver:self
                forKeyPath:@"myLocation"
                   context:NULL];
}

#pragma mark - KVO updates

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if (!_firstLocationUpdate) {
    // If the first location update has not yet been recieved, then jump to that
    // location.
    _firstLocationUpdate = YES;
    CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
    _mapView.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                     zoom:14];
  }
}

@end
