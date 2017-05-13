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

#import "GooglePlacesDemos/Samples/Autocomplete/AutocompleteBaseViewController.h"

@implementation AutocompleteBaseViewController {
  UITextView *_textView;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // Configure a background color.
  self.view.backgroundColor = [UIColor whiteColor];

  // Create a text view.
  _textView = [[UITextView alloc] init];
  _textView.editable = NO;
  _textView.translatesAutoresizingMaskIntoConstraints = NO;
}

- (UIButton *)createShowAutocompleteButton:(SEL)selector {
  // Create a button to show the autocomplete widget.
  UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
  [button setTitle:NSLocalizedString(@"Demo.Content.Autocomplete.ShowWidgetButton",
                                     @"Button title for 'show autocomplete widget'")
          forState:UIControlStateNormal];
  [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
  button.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:button];
  // Position the button from the top of the view.
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.topLayoutGuide
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1
                                                         constant:8]];
  // Centre it horizontally.
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.view
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1
                                                         constant:0]];

  return button;
}

- (void)addResultViewBelow:(UIView *)view {
  NSAssert(_textView.superview == nil, @"%s should not be called twice", sel_getName(_cmd));
  [self.view addSubview:_textView];
  // Position it horizontally so it fills the parent.
  [self.view
      addConstraints:[NSLayoutConstraint
                         constraintsWithVisualFormat:@"H:|-(0)-[_textView]-(0)-|"
                                             options:0
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(_textView)]];
  // If we have a view place it below that.
  if (view) {
    [self.view addConstraints:[NSLayoutConstraint
                                  constraintsWithVisualFormat:@"V:[view]-[_textView]-(0)-|"
                                                      options:0
                                                      metrics:nil
                                                        views:NSDictionaryOfVariableBindings(
                                                                  view, _textView)]];
  } else {
    // Otherwise make it fill the parent vertically.
    [self.view
        addConstraints:[NSLayoutConstraint
                           constraintsWithVisualFormat:@"V:|-(0)-[_textView]-(0)-|"
                                               options:0
                                               metrics:nil
                                                 views:NSDictionaryOfVariableBindings(_textView)]];
  }
}

- (void)autocompleteDidSelectPlace:(GMSPlace *)place {
  NSMutableAttributedString *text =
      [[NSMutableAttributedString alloc] initWithString:[place description]];
  if (place.attributions) {
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n"]];
    [text appendAttributedString:place.attributions];
  }
  _textView.attributedText = text;
}

- (void)autocompleteDidFail:(NSError *)error {
  NSString *formatString =
      NSLocalizedString(@"Demo.Content.Autocomplete.FailedErrorMessage",
                        @"Format string for 'autocomplete failed with error' message");
  _textView.text = [NSString stringWithFormat:formatString, error];
}

- (void)autocompleteDidCancel {
  _textView.text = NSLocalizedString(@"Demo.Content.Autocomplete.WasCanceledMessage",
                                     @"String for 'autocomplete canceled message'");
}

- (void)showCustomMessageInResultPane:(NSString *)message {
  _textView.text = message;
}

@end
