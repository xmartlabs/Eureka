//
//  GMSUserAddedPlace.h
//  Google Places API for iOS
//
//  Copyright 2016 Google Inc.
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://developers.google.com/maps/terms
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Represents a place constructed by a user, suitable for adding to Google's collection of places.
 *
 * All properties must be set before passing to GMSPlacesClient.addPlace, except that either website
 * _or_ phoneNumber may be nil.
 */
@interface GMSUserAddedPlace : NSObject

/** Name of the place. */
@property(nonatomic, copy, nullable) NSString *name;

/** Address of the place. */
@property(nonatomic, copy, nullable) NSString *address;

/** Location of the place. */
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;

/** Phone number of the place. */
@property(nonatomic, copy, nullable) NSString *phoneNumber;

/** List of types of the place as an array of NSStrings, like the GMSPlace.types property.
* Only <a href="/places/ios-api/supported_types#table1">table 1 types</a>
* are valid.
*/
@property(nonatomic, copy, nullable) NSArray<NSString *> *types;

/** The website for the place. */
@property(nonatomic, copy, nullable) NSString *website;

@end

NS_ASSUME_NONNULL_END
