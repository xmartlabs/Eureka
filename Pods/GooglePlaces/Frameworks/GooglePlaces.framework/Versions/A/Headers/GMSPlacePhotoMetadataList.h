//
//  GMSPlacePhotoMetadataList.h
//  Google Places API for iOS
//
//  Copyright 2016 Google Inc.
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://developers.google.com/maps/terms
//

#import <UIKit/UIKit.h>

#import <GooglePlaces/GMSPlacePhotoMetadata.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * A list of |GMSPlacePhotoMetadata| objects.
 */
@interface GMSPlacePhotoMetadataList : NSObject

/**
 * The array of |GMSPlacePhotoMetadata| objects.
 */
@property(nonatomic, readonly, copy) NSArray<GMSPlacePhotoMetadata *> *results;

@end

NS_ASSUME_NONNULL_END
