//
//  GMSPlacePickerConfig.h
//  Google Places API for iOS
//
//  Copyright 2016 Google Inc.
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://developers.google.com/maps/terms
//

#if __has_feature(modules)
@import GoogleMapsBase;
#else
#import <GoogleMapsBase/GoogleMapsBase.h>
#endif
#if __has_feature(modules)
@import GooglePlaces;
#else
#import <GooglePlaces/GooglePlaces.h>
#endif

NS_ASSUME_NONNULL_BEGIN


/**
 * Configuration object used to change the behavior of the place picker.
 */
@interface GMSPlacePickerConfig : NSObject

/**
 * The initial viewport that the place picker map should show. If this is nil, a sensible default
 * will be chosen based on the user's location.
 */
@property(nonatomic, strong, readonly, nullable) GMSCoordinateBounds *viewport;

/**
 * Initialize the configuration.
 */
- (instancetype)initWithViewport:(nullable GMSCoordinateBounds *)viewport;

@end

NS_ASSUME_NONNULL_END
