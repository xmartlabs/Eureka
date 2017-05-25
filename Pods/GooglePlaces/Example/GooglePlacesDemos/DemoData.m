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

#import "GooglePlacesDemos/DemoData.h"

#import "GooglePlacesDemos/Support/BaseDemoViewController.h"
#import "GooglePlacesDemos/Samples/Autocomplete/AutocompleteModalViewController.h"
#import "GooglePlacesDemos/Samples/Autocomplete/AutocompletePushViewController.h"
#import "GooglePlacesDemos/Samples/Autocomplete/AutocompleteWithCustomColors.h"
#import "GooglePlacesDemos/Samples/Autocomplete/AutocompleteWithSearchDisplayController.h"
#import "GooglePlacesDemos/Samples/Autocomplete/AutocompleteWithSearchViewController.h"
#import "GooglePlacesDemos/Samples/Autocomplete/AutocompleteWithTextFieldController.h"
#import "GooglePlacesDemos/Samples/PhotosViewController.h"

@implementation Demo {
  Class _viewControllerClass;
}

- (instancetype)initWithViewControllerClass:(Class)viewControllerClass {
  if ((self = [self init])) {
    _title = [viewControllerClass demoTitle];
    _viewControllerClass = viewControllerClass;
  }
  return self;
}

- (UIViewController *)createViewControllerForSplitView:
    (UISplitViewController *)splitViewController {
  // Construct the demo view controller.
  UIViewController *demoViewController = [[_viewControllerClass alloc] init];

  // Check whether displayModeButtonItem is available (iOS 8+), if not
  // MainSplitViewControllerBehaviorManager will implement a fallback for iOS 7.
  if ([splitViewController respondsToSelector:@selector(displayModeButtonItem)]) {
    // Configure its left bar button item to display the displayModeButtonItem provided by the
    // splitViewController.
    demoViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
    demoViewController.navigationItem.leftItemsSupplementBackButton = YES;
  }

  // Wrap the demo in a navigation controller.
  UINavigationController *navigationController =
      [[UINavigationController alloc] initWithRootViewController:demoViewController];

  return navigationController;
}

@end

@implementation DemoSection

- (instancetype)initWithTitle:(NSString *)title demos:(NSArray<Demo *> *)demos {
  if ((self = [self init])) {
    _title = [title copy];
    _demos = [demos copy];
  }
  return self;
}

@end

@implementation DemoData

- (instancetype)init {
  if ((self = [super init])) {
    NSArray<Demo *> *autocompleteDemos = @[
      [[Demo alloc] initWithViewControllerClass:[AutocompleteWithCustomColors class]],
      [[Demo alloc] initWithViewControllerClass:[AutocompleteModalViewController class]],
      [[Demo alloc] initWithViewControllerClass:[AutocompletePushViewController class]],
      [[Demo alloc] initWithViewControllerClass:[AutocompleteWithSearchDisplayController class]],
      [[Demo alloc] initWithViewControllerClass:[AutocompleteWithSearchViewController class]],
      [[Demo alloc] initWithViewControllerClass:[AutocompleteWithTextFieldController class]],
    ];

    NSArray<Demo *> *otherDemos = @[
      [[Demo alloc] initWithViewControllerClass:[PhotosViewController class]],
    ];


    _sections = @[
      [[DemoSection alloc]
          initWithTitle:NSLocalizedString(@"Demo.Section.Title.Autocomplete",
                                          @"Title of the autocomplete demo section")
                  demos:autocompleteDemos],
      [[DemoSection alloc]
          initWithTitle:NSLocalizedString(@"Demo.Section.Title.Programmatic",
                                          @"Title of the 'Programmatic' demo section")
                  demos:otherDemos],
    ];
  }
  return self;
}

- (Demo *)firstDemo {
  return _sections[0].demos[0];
}

@end
