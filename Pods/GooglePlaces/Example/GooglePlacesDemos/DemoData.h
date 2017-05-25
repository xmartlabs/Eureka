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

/*
 * This file contains a set of data objects which represent the list of demos which are provided by
 * this sample app.
 */

/**
 * Represents a specific demo sample, stores the title and the name of the view controller which
 * contains the demo code.
 */
@interface Demo : NSObject

/**
 * The title of the demo. This is displayed in the list of demos.
 */
@property(nonatomic, readonly) NSString *title;

/**
 * Construct a |Demo| object with the specified view controller which contains the demo code.
 *
 * @param viewControllerClass The class of the view controller to display when the demo is selected
 * from the list.
 */
- (instancetype)initWithViewControllerClass:(Class)viewControllerClass;

/**
 * Construct and return a new UIViewController instance which contains the view to present when the
 * demo is selected from the list.
 *
 * @param splitViewController The |UISplitViewController| in which the demo will be presented. NOTE:
 * This may be nil.
 */
- (UIViewController *)createViewControllerForSplitView:(UISplitViewController *)splitViewController;

@end

/**
 * A group of demos which comprise a section in the list of demos.
 */
@interface DemoSection : NSObject

/**
 * The title of the section.
 */
@property(nonatomic, readonly) NSString *title;

/**
 * The list of demos which are contained in the section.
 */
@property(nonatomic, readonly) NSArray<Demo *> *demos;

/**
 * Initialise a |DemoSection| with the specified title and list of demos.
 *
 * @param title The title of the section.
 * @param demos The demos contained in the section.
 */
- (instancetype)initWithTitle:(NSString *)title demos:(NSArray<Demo *> *)demos;

@end

/**
 * A class which encapsulates the data required to create and display demos.
 */
@interface DemoData : NSObject

/**
 * A list of sections to display.
 */
@property(nonatomic, readonly) NSArray<DemoSection *> *sections;

/**
 * The first demo to display when launched in side-by-side mode.
 */
@property(nonatomic, readonly) Demo *firstDemo;

@end
