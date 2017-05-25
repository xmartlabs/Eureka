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

#import <UIKit/UIKit.h>

/**
 * A class which manages the behavior of a |UISplitViewController| to achieve the UX we want for
 * this demo app. Specifically it tells the |UISplitViewController| to display the list of demos on
 * first launch if there is not enough space to have two panes, instead of just the first demo in
 * the list. After first launch if the device transitions from regular to compact it will instead
 * show the demo which is currently open.
 */
@interface MainSplitViewControllerBehaviorManager : NSObject<UISplitViewControllerDelegate>

// Bar button item for use on iOS 7 where displayModeButtonItem is not available.
@property(nonatomic, readonly) UIBarButtonItem *iOS7DisplayModeButtonItem;

@end
