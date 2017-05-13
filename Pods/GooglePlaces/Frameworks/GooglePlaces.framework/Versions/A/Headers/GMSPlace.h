//
//  GMSPlace.h
//  Google Places API for iOS
//
//  Copyright 2016 Google Inc.
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://developers.google.com/maps/terms
//

#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@class GMSAddressComponent;
@class GMSCoordinateBounds;


/** Describes the current open status of a place. */
typedef NS_ENUM(NSInteger, GMSPlacesOpenNowStatus) {
  /** The place is open now. */
  kGMSPlacesOpenNowStatusYes,
  /** The place is not open now. */
  kGMSPlacesOpenNowStatusNo,
  /** We don't know whether the place is open now. */
  kGMSPlacesOpenNowStatusUnknown,
};

typedef NS_ENUM(NSInteger, GMSPlacesPriceLevel) {
  kGMSPlacesPriceLevelUnknown = -1,
  kGMSPlacesPriceLevelFree = 0,
  kGMSPlacesPriceLevelCheap = 1,
  kGMSPlacesPriceLevelMedium = 2,
  kGMSPlacesPriceLevelHigh = 3,
  kGMSPlacesPriceLevelExpensive = 4,
};

/**
 * Represents a particular physical place. A GMSPlace encapsulates information about a physical
 * location, including its name, location, and any other information we might have about it. This
 * class is immutable.
 */
@interface GMSPlace : NSObject

/** Name of the place. */
@property(nonatomic, copy, readonly) NSString *name;

/** Place ID of this place. */
@property(nonatomic, copy, readonly) NSString *placeID;

/**
 * Location of the place. The location is not necessarily the center of the Place, or any
 * particular entry or exit point, but some arbitrarily chosen point within the geographic extent of
 * the Place.
 */
@property(nonatomic, readonly, assign) CLLocationCoordinate2D coordinate;

/**
 * Represents the open now status of the place at the time that the place was created.
 */
@property(nonatomic, readonly, assign) GMSPlacesOpenNowStatus openNowStatus;

/**
 * Phone number of this place, in international format, i.e. including the country code prefixed
 * with "+".  For example, Google Sydney's phone number is "+61 2 9374 4000".
 */
@property(nonatomic, copy, readonly, nullable) NSString *phoneNumber;

/**
 * Address of the place as a simple string.
 */
@property(nonatomic, copy, readonly, nullable) NSString *formattedAddress;

/**
 * Five-star rating for this place based on user reviews.
 *
 * Ratings range from 1.0 to 5.0.  0.0 means we have no rating for this place (e.g. because not
 * enough users have reviewed this place).
 */
@property(nonatomic, readonly, assign) float rating;

/**
 * Price level for this place, as integers from 0 to 4.
 *
 * e.g. A value of 4 means this place is "$$$$" (expensive).  A value of 0 means free (such as a
 * museum with free admission).
 */
@property(nonatomic, readonly, assign) GMSPlacesPriceLevel priceLevel;

/**
 * The types of this place.  Types are NSStrings, valid values are any types documented at
 * <https://developers.google.com/places/ios-api/supported_types>.
 */
@property(nonatomic, copy, readonly) NSArray<NSString *> *types;

/** Website for this place. */
@property(nonatomic, copy, readonly, nullable) NSURL *website;

/**
 * The data provider attribution string for this place.
 *
 * These are provided as a NSAttributedString, which may contain hyperlinks to the website of each
 * provider.
 *
 * In general, these must be shown to the user if data from this GMSPlace is shown, as described in
 * the Places API Terms of Service.
 */
@property(nonatomic, copy, readonly, nullable) NSAttributedString *attributions;

/**
 * The recommended viewport for this place. May be nil if the size of the place is not known.
 *
 * This returns a viewport of a size that is suitable for displaying this place. For example, a
 * |GMSPlace| object representing a store may have a relatively small viewport, while a |GMSPlace|
 * object representing a country may have a very large viewport.
 */
@property(nonatomic, strong, readonly, nullable) GMSCoordinateBounds *viewport;

/**
 * An array of |GMSAddressComponent| objects representing the components in the place's address.
 * These components are provided for the purpose of extracting structured information about the
 * place's address: for example, finding the city that a place is in.
 *
 * These components should not be used for address formatting. If a formatted address is required,
 * use the |formattedAddress| property, which provides a localized formatted address.
 */
@property(nonatomic, copy, readonly, nullable) NSArray<GMSAddressComponent *> *addressComponents;

@end

NS_ASSUME_NONNULL_END
