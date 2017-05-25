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

#import "GooglePlacesDemos/Samples/Autocomplete/AutocompleteWithCustomColors.h"

#import <GooglePlaces/GooglePlaces.h>

/** Height of buttons in this controller's UI */
static const CGFloat kButtonHeight = 44.0f;

/**
 * Simple subclass of GMSAutocompleteViewController solely for the purpose of localising appearance
 * proxy changes to this part of the demo app.
 */
@interface GMSStyledAutocompleteViewController : GMSAutocompleteViewController
@end

@implementation GMSStyledAutocompleteViewController
@end

@interface AutocompleteWithCustomColors ()<GMSAutocompleteViewControllerDelegate>
@end

@implementation AutocompleteWithCustomColors {
  UIButton *_brownThemeButton;
  UIButton *_blackThemeButton;
  UIButton *_blueThemeButton;
  UIButton *_hotDogThemeButton;

  UIColor *_backgroundColor;
  UIColor *_darkBackgroundColor;
  UIColor *_primaryTextColor;
  UIColor *_highlightColor;
  UIColor *_secondaryColor;
  UIColor *_separatorColor;
  UIColor *_tintColor;
  UIColor *_searchBarTintColor;
  UIColor *_selectedTableCellBackgroundColor;
}

+ (NSString *)demoTitle {
  return NSLocalizedString(
      @"Demo.Title.Autocomplete.Styling",
      @"Title of the Styling autocomplete demo for display in a list or nav header");
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = [UIColor whiteColor];

  NSString *titleYellowAndBrown =
      NSLocalizedString(@"Demo.Content.Autocomplete.Styling.Colors.YellowAndBrown",
                        @"Button title for the 'Yellow and Brown' styled autocomplete widget.");
  NSString *titleWhiteOnBlack =
      NSLocalizedString(@"Demo.Content.Autocomplete.Styling.Colors.WhiteOnBlack",
                        @"Button title for the 'WhiteOnBlack' styled autocomplete widget.");
  NSString *titleBlueColors =
      NSLocalizedString(@"Demo.Content.Autocomplete.Styling.Colors.BlueColors",
                        @"Button title for the 'BlueColors' styled autocomplete widget.");
  NSString *titleHotDogStand =
      NSLocalizedString(@"Demo.Content.Autocomplete.Styling.Colors.HotDogStand",
                        @"Button title for the 'Hot Dog Stand' styled autocomplete widget.");

  CGFloat nextControlY = 70.0f;
  _brownThemeButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [_brownThemeButton setTitle:titleYellowAndBrown forState:UIControlStateNormal];
  _brownThemeButton.frame = CGRectMake(0, nextControlY, self.view.bounds.size.width, kButtonHeight);
  _brownThemeButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [_brownThemeButton addTarget:self
                        action:@selector(didTapButton:)
              forControlEvents:UIControlEventTouchUpInside];
  nextControlY += kButtonHeight;

  _blackThemeButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [_blackThemeButton setTitle:titleWhiteOnBlack forState:UIControlStateNormal];
  _blackThemeButton.frame = CGRectMake(0, nextControlY, self.view.bounds.size.width, kButtonHeight);
  _blackThemeButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [_blackThemeButton addTarget:self
                        action:@selector(didTapButton:)
              forControlEvents:UIControlEventTouchUpInside];
  nextControlY += kButtonHeight;

  _blueThemeButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [_blueThemeButton setTitle:titleBlueColors forState:UIControlStateNormal];
  _blueThemeButton.frame = CGRectMake(0, nextControlY, self.view.bounds.size.width, kButtonHeight);
  _blueThemeButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [_blueThemeButton addTarget:self
                       action:@selector(didTapButton:)
             forControlEvents:UIControlEventTouchUpInside];
  nextControlY += kButtonHeight;

  _hotDogThemeButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [_hotDogThemeButton setTitle:titleHotDogStand forState:UIControlStateNormal];
  _hotDogThemeButton.frame =
      CGRectMake(0, nextControlY, self.view.bounds.size.width, kButtonHeight);
  _hotDogThemeButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [_hotDogThemeButton addTarget:self
                         action:@selector(didTapButton:)
               forControlEvents:UIControlEventTouchUpInside];

  [self.view addSubview:_brownThemeButton];
  [self.view addSubview:_blackThemeButton];
  [self.view addSubview:_blueThemeButton];
  [self.view addSubview:_hotDogThemeButton];

  [self addResultViewBelow:_hotDogThemeButton];

  self.definesPresentationContext = YES;
}

- (void)didTapButton:(UIButton *)button {
  if (button == _brownThemeButton) {
    _backgroundColor = [UIColor colorWithRed:215.0f / 255.0f
                                       green:204.0f / 255.0f
                                        blue:200.0f / 255.0f
                                       alpha:1.0f];
    _selectedTableCellBackgroundColor = [UIColor colorWithRed:236.0f / 255.0f
                                                        green:225.0f / 255.0f
                                                         blue:220.0f / 255.0f
                                                        alpha:1.0f];
    _darkBackgroundColor =
        [UIColor colorWithRed:93.0f / 255.0f green:64.0f / 255.0f blue:55.0f / 255.0f alpha:1.0f];
    _primaryTextColor = [UIColor colorWithWhite:0.33f alpha:1.0f];

    _highlightColor =
        [UIColor colorWithRed:255.0f / 255.0f green:235.0f / 255.0f blue:0.0f / 255.0f alpha:1.0f];
    _secondaryColor = [UIColor colorWithWhite:114.0f / 255.0f alpha:1.0f];
    _tintColor = [UIColor colorWithRed:219 / 255.0f green:207 / 255.0f blue:28 / 255.0f alpha:1.0f];
    _searchBarTintColor = [UIColor yellowColor];
    _separatorColor = [UIColor colorWithWhite:182.0f / 255.0f alpha:1.0f];
  } else if (button == _blueThemeButton) {
    _backgroundColor = [UIColor colorWithRed:225.0f / 255.0f
                                       green:241.0f / 255.0f
                                        blue:252.0f / 255.0f
                                       alpha:1.0f];
    _selectedTableCellBackgroundColor = [UIColor colorWithRed:213.0f / 255.0f
                                                        green:219.0f / 255.0f
                                                         blue:230.0f / 255.0f
                                                        alpha:1.0f];
    _darkBackgroundColor = [UIColor colorWithRed:187.0f / 255.0f
                                           green:222.0f / 255.0f
                                            blue:248.0f / 255.0f
                                           alpha:1.0f];
    _primaryTextColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
    _highlightColor =
        [UIColor colorWithRed:76.0f / 255.0f green:175.0f / 255.0f blue:248.0f / 255.0f alpha:1.0f];
    _secondaryColor = [UIColor colorWithWhite:0.5f alpha:0.65f];
    _tintColor =
        [UIColor colorWithRed:0 / 255.0f green:142 / 255.0f blue:248.0f / 255.0f alpha:1.0f];
    _searchBarTintColor = _tintColor;
    _separatorColor = [UIColor colorWithWhite:0.5f alpha:0.65f];
  } else if (button == _blackThemeButton) {
    _backgroundColor = [UIColor colorWithWhite:0.25f alpha:1.0f];
    _selectedTableCellBackgroundColor = [UIColor colorWithWhite:0.35f alpha:1.0f];
    _darkBackgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    _primaryTextColor = [UIColor whiteColor];
    _highlightColor = [UIColor colorWithRed:0.75f green:1.0f blue:0.75f alpha:1.0f];
    _secondaryColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
    _tintColor = [UIColor whiteColor];
    _searchBarTintColor = _tintColor;
    _separatorColor = [UIColor colorWithRed:0.5f green:0.75f blue:0.5f alpha:0.30f];
  } else if (button == _hotDogThemeButton) {
    _backgroundColor = [UIColor yellowColor];
    _selectedTableCellBackgroundColor = [UIColor whiteColor];
    _darkBackgroundColor = [UIColor redColor];
    _primaryTextColor = [UIColor blackColor];
    _highlightColor = [UIColor redColor];
    _secondaryColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
    _tintColor = [UIColor redColor];
    _searchBarTintColor = [UIColor whiteColor];
    _separatorColor = [UIColor redColor];
  }
  [self presentAutocompleteController];
}

- (void)presentAutocompleteController {
  // Use UIAppearance proxies to change the appearance of UI controls in
  // GMSAutocompleteViewController. Here we use appearanceWhenContainedIn to localise changes to
  // just this part of the Demo app. This will generally not be necessary in a real application as
  // you will probably want the same theme to apply to all elements in your app.
  UIActivityIndicatorView *appearence = [UIActivityIndicatorView
      appearanceWhenContainedIn:[GMSStyledAutocompleteViewController class], nil];
  [appearence setColor:_primaryTextColor];

  [[UINavigationBar appearanceWhenContainedIn:[GMSStyledAutocompleteViewController class], nil]
      setBarTintColor:_darkBackgroundColor];
  [[UINavigationBar appearanceWhenContainedIn:[GMSStyledAutocompleteViewController class], nil]
      setTintColor:_searchBarTintColor];

  // Color of typed text in search bar.
  NSDictionary *searchBarTextAttributes = @{
    NSForegroundColorAttributeName : _searchBarTintColor,
    NSFontAttributeName : [UIFont systemFontOfSize:[UIFont systemFontSize]]
  };
  [[UITextField appearanceWhenContainedIn:[GMSStyledAutocompleteViewController class], nil]
      setDefaultTextAttributes:searchBarTextAttributes];

  // Color of the "Search" placeholder text in search bar. For this example, we'll make it the same
  // as the bar tint color but with added transparency.
  CGFloat increasedAlpha = CGColorGetAlpha(_searchBarTintColor.CGColor) * 0.75f;
  UIColor *placeHolderColor = [_searchBarTintColor colorWithAlphaComponent:increasedAlpha];

  NSDictionary *placeholderAttributes = @{
    NSForegroundColorAttributeName : placeHolderColor,
    NSFontAttributeName : [UIFont systemFontOfSize:[UIFont systemFontSize]]
  };
  NSAttributedString *attributedPlaceholder =
      [[NSAttributedString alloc] initWithString:@"Search" attributes:placeholderAttributes];

  [[UITextField appearanceWhenContainedIn:[GMSStyledAutocompleteViewController class], nil]
      setAttributedPlaceholder:attributedPlaceholder];

  // Change the background color of selected table cells.
  UIView *selectedBackgroundView = [[UIView alloc] init];
  selectedBackgroundView.backgroundColor = _selectedTableCellBackgroundColor;
  id tableCellAppearance =
      [UITableViewCell appearanceWhenContainedIn:[GMSStyledAutocompleteViewController class], nil];
  [tableCellAppearance setSelectedBackgroundView:selectedBackgroundView];

  // Depending on the navigation bar background color, it might also be necessary to customise the
  // icons displayed in the search bar to something other than the default. The
  // setupSearchBarCustomIcons method contains example code to do this.

  GMSAutocompleteViewController *acController = [[GMSStyledAutocompleteViewController alloc] init];
  acController.delegate = self;
  acController.tableCellBackgroundColor = _backgroundColor;
  acController.tableCellSeparatorColor = _separatorColor;
  acController.primaryTextColor = _primaryTextColor;
  acController.primaryTextHighlightColor = _highlightColor;
  acController.secondaryTextColor = _secondaryColor;
  acController.tintColor = _tintColor;

  [self presentViewController:acController animated:YES completion:nil];
}

/*
 * This method shows how to replace the "search" and "clear text" icons in the search bar with
 * custom icons in the case where the default gray icons don't match a custom background.
 */
- (void)setupSearchBarCustomIcons {
  id searchBarAppearanceProxy =
      [UISearchBar appearanceWhenContainedIn:[GMSStyledAutocompleteViewController class], nil];
  [searchBarAppearanceProxy setImage:[UIImage imageNamed:@"custom_clear_x_high"]
                    forSearchBarIcon:UISearchBarIconClear
                               state:UIControlStateHighlighted];
  [searchBarAppearanceProxy setImage:[UIImage imageNamed:@"custom_clear_x"]
                    forSearchBarIcon:UISearchBarIconClear
                               state:UIControlStateNormal];
  [searchBarAppearanceProxy setImage:[UIImage imageNamed:@"custom_search"]
                    forSearchBarIcon:UISearchBarIconSearch
                               state:UIControlStateNormal];
}

#pragma mark - GMSAutocompleteViewControllerDelegate

- (void)viewController:(GMSAutocompleteViewController *)viewController
    didAutocompleteWithPlace:(GMSPlace *)place {
  [self dismissViewControllerAnimated:YES completion:nil];
  [self autocompleteDidSelectPlace:place];
}

- (void)viewController:(GMSAutocompleteViewController *)viewController
    didFailAutocompleteWithError:(NSError *)error {
  [self dismissViewControllerAnimated:YES completion:nil];
  [self autocompleteDidFail:error];
}

- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
  [self dismissViewControllerAnimated:YES completion:nil];
  [self autocompleteDidCancel];
}

- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
