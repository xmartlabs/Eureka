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

#import "GooglePlacesDemos/Samples/Autocomplete/AutocompleteModalViewController.h"

#import <GooglePlaces/GooglePlaces.h>

@interface AutocompleteModalViewController ()<GMSAutocompleteViewControllerDelegate>
@end

@implementation AutocompleteModalViewController

+ (NSString *)demoTitle {
  return NSLocalizedString(
      @"Demo.Title.Autocomplete.FullScreen",
      @"Title of the full-screen autocomplete demo for display in a list or nav header");
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];

  // Configure the UI. Tell our superclass we want a button and a result view below that.
  UIButton *button =
      [self createShowAutocompleteButton:@selector(showAutocompleteWidgetButtonTapped)];
  [self addResultViewBelow:button];
}

#pragma mark - Actions

- (IBAction)showAutocompleteWidgetButtonTapped {
  // When the button is pressed modally present the autocomplete view controller.
  GMSAutocompleteViewController *autocompleteViewController =
      [[GMSAutocompleteViewController alloc] init];
  autocompleteViewController.delegate = self;
  [self presentViewController:autocompleteViewController animated:YES completion:nil];
}

#pragma mark - GMSAutocompleteViewControllerDelegate

- (void)viewController:(GMSAutocompleteViewController *)viewController
    didAutocompleteWithPlace:(GMSPlace *)place {
  // Dismiss the view controller and tell our superclass to populate the result view.
  [viewController dismissViewControllerAnimated:YES completion:nil];
  [self autocompleteDidSelectPlace:place];
}

- (void)viewController:(GMSAutocompleteViewController *)viewController
    didFailAutocompleteWithError:(NSError *)error {
  // Dismiss the view controller and notify our superclass of the failure.
  [viewController dismissViewControllerAnimated:YES completion:nil];
  [self autocompleteDidFail:error];
}

- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
  // Dismiss the controller and show a message that it was canceled.
  [viewController dismissViewControllerAnimated:YES completion:nil];
  [self autocompleteDidCancel];
}

- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
