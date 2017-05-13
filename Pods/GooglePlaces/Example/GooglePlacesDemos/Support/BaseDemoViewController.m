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

#import "GooglePlacesDemos/Support/BaseDemoViewController.h"

@implementation BaseDemoViewController

+ (NSString *)demoTitle {
  // This should be overridden by subclasses, so should not be called.
  return nil;
}

- (instancetype)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle {
  if ((self = [super initWithNibName:name bundle:bundle])) {
    self.title = [[self class] demoTitle];
  }
  return self;
}

@end
