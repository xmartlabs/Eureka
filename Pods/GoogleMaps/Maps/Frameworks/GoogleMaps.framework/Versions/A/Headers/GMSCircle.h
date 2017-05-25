//
//  GMSCircle.h
//  Google Maps SDK for iOS
//
//  Copyright 2013 Google Inc.
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://developers.google.com/maps/terms
//

#import <GoogleMaps/GMSOverlay.h>

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * A circle on the Earth's surface (spherical cap).
 */
@interface GMSCircle : GMSOverlay

/** Position on Earth of circle center. */
@property(nonatomic, assign) CLLocationCoordinate2D position;

/** Radius of the circle in meters; must be positive. */
@property(nonatomic, assign) CLLocationDistance radius;

/**
 * The width of the circle's outline in screen points. Defaults to 1. As per GMSPolygon, the width
 * does not scale when the map is zoomed.
 *
 * Setting strokeWidth to 0 results in no stroke.
 */
@property(nonatomic, assign) CGFloat strokeWidth;

/** The color of this circle's outline. The default value is black. */
@property(nonatomic, strong, nullable) UIColor *strokeColor;

/**
 * The interior of the circle is painted with fillColor. The default value is nil, resulting in no
 * fill.
 */
@property(nonatomic, strong, nullable) UIColor *fillColor;

/**
 * Convenience constructor for GMSCircle for a particular position and radius. Other properties will
 * have default values.
 */
+ (instancetype)circleWithPosition:(CLLocationCoordinate2D)position
                            radius:(CLLocationDistance)radius;

@end

NS_ASSUME_NONNULL_END
