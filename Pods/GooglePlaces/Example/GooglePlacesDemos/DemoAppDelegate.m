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

#import "GooglePlacesDemos/DemoAppDelegate.h"

#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>

#import "GooglePlacesDemos/DemoData.h"
#import "GooglePlacesDemos/DemoListViewController.h"
#import "GooglePlacesDemos/SDKDemoAPIKey.h"
#import "GooglePlacesDemos/Support/MainSplitViewControllerBehaviorManager.h"

@implementation DemoAppDelegate {
  MainSplitViewControllerBehaviorManager *_splitViewManager;
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  NSLog(@"Build version: %d", __apple_build_version__);

  // Do a quick check to see if you've provided an API key, in a real app you wouldn't need this but
  // for the demo it means we can provide a better error message.
  if (!kAPIKey.length) {
    // Blow up if APIKeys have not yet been set.
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSString *format = @"Configure APIKeys inside SDKDemoAPIKey.h for your  bundle `%@`, see "
                       @"README.GooglePlacesDemos for more information";
    @throw [NSException exceptionWithName:@"DemoAppDelegate"
                                   reason:[NSString stringWithFormat:format, bundleId]
                                 userInfo:nil];
  }

  // Provide the Places API with your API key.
  [GMSPlacesClient provideAPIKey:kAPIKey];
  // Provide the Maps API with your API key. You may not need this in your app, however we do need
  // this for the demo app as it uses Maps.
  [GMSServices provideAPIKey:kAPIKey];

  // Log the required open source licenses! Yes, just NSLog-ing them is not enough but is good for
  // a demo.
  NSLog(@"Google Maps open source licenses:\n%@", [GMSServices openSourceLicenseInfo]);
  NSLog(@"Google Places open source licenses:\n%@", [GMSPlacesClient openSourceLicenseInfo]);


  // Manually create a window. If you are using a storyboard in your own app you can ignore the rest
  // of this method.
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

  // Create our view controller with the list of demos.
  DemoData *demoData = [[DemoData alloc] init];
  DemoListViewController *masterViewController =
      [[DemoListViewController alloc] initWithDemoData:demoData];
  UINavigationController *masterNavigationController =
      [[UINavigationController alloc] initWithRootViewController:masterViewController];

  // If UISplitViewController is not available (only on iOS 7 running on an iPhone) we need to do
  // something different with our UI. On iOS 8 and later UISplitViewController is available on iPad
  // and iPhone so if you were using a UISplitViewController in your own app this check would not be
  // needed.
  if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0 &&
      [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    masterNavigationController.viewControllers = @[ masterViewController ];
    self.window.rootViewController = masterNavigationController;
  } else {
    // UISplitViewController is available, use that.

    _splitViewManager = [[MainSplitViewControllerBehaviorManager alloc] init];
    masterViewController.mainSplitViewControllerBehaviorManager = _splitViewManager;

    // Setup the split view controller.
    UISplitViewController *splitViewController = [[UISplitViewController alloc] init];
    UIViewController *detailViewController =
        [demoData.firstDemo createViewControllerForSplitView:splitViewController];
    splitViewController.delegate = _splitViewManager;
    splitViewController.viewControllers = @[ masterNavigationController, detailViewController ];
    self.window.rootViewController = splitViewController;
  }

  [self.window makeKeyAndVisible];

  return YES;
}

@end
