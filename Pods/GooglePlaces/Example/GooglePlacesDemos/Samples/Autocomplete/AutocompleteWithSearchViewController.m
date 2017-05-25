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

#import "GooglePlacesDemos/Samples/Autocomplete/AutocompleteWithSearchViewController.h"

#import <GooglePlaces/GooglePlaces.h>

@interface AutocompleteWithSearchViewController ()<GMSAutocompleteResultsViewControllerDelegate>
@end

@implementation AutocompleteWithSearchViewController {
  UISearchController *_searchController;
  GMSAutocompleteResultsViewController *_acViewController;
}

+ (NSString *)demoTitle {
  return NSLocalizedString(
      @"Demo.Title.Autocomplete.UISearchController",
      @"Title of the UISearchController autocomplete demo for display in a list or nav header");
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];

  _acViewController = [[GMSAutocompleteResultsViewController alloc] init];
  _acViewController.delegate = self;

  _searchController =
      [[UISearchController alloc] initWithSearchResultsController:_acViewController];
  _searchController.hidesNavigationBarDuringPresentation = NO;
  _searchController.dimsBackgroundDuringPresentation = YES;

  _searchController.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  _searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;

  [_searchController.searchBar sizeToFit];
  self.navigationItem.titleView = _searchController.searchBar;
  self.definesPresentationContext = YES;

  // Work around a UISearchController bug that doesn't reposition the table view correctly when
  // rotating to landscape.
  self.edgesForExtendedLayout = UIRectEdgeAll;
  self.extendedLayoutIncludesOpaqueBars = YES;

  _searchController.searchResultsUpdater = _acViewController;
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    _searchController.modalPresentationStyle = UIModalPresentationPopover;
  } else {
    _searchController.modalPresentationStyle = UIModalPresentationFullScreen;
  }

  if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0) {
    NSString *message = NSLocalizedString(
        @"Demo.Content.iOSVersionNotSupported",
        @"Error message to display when a demo is not available on the current version of iOS");
    [super showCustomMessageInResultPane:message];
  }

  [self addResultViewBelow:nil];
}

#pragma mark - GMSAutocompleteResultsViewControllerDelegate

- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
 didAutocompleteWithPlace:(GMSPlace *)place {
  // Display the results and dismiss the search controller.
  [_searchController setActive:NO];
  [self autocompleteDidSelectPlace:place];
}

- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
    didFailAutocompleteWithError:(NSError *)error {
  // Display the error and dismiss the search controller.
  [_searchController setActive:NO];
  [self autocompleteDidFail:error];
}

// Show and hide the network activity indicator when we start/stop loading results.

- (void)didRequestAutocompletePredictionsForResultsController:
    (GMSAutocompleteResultsViewController *)resultsController {
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictionsForResultsController:
    (GMSAutocompleteResultsViewController *)resultsController {
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
