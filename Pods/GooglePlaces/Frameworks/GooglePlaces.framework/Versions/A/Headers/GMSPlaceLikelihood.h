//
//  GMSPlaceLikelihood.h
//  Google Places API for iOS
//
//  Copyright 2016 Google Inc.
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://developers.google.com/maps/terms
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class GMSPlace;

/**
 * Represents a |GMSPlace| and the relative likelihood of the place being the best match within the
 * list of returned places for a single request. For more information about place likelihoods, see
 * |GMSPlaceLikelihoodList|.
 */
@interface GMSPlaceLikelihood : NSObject<NSCopying>

/**
 * The place contained in this place likelihood.
 */
@property(nonatomic, strong, readonly) GMSPlace *place;

/**
 * Returns a value from 0.0 to 1.0 indicating the confidence that the user is at this place. The
 * larger the value the more confident we are of the place returned. For example, a likelihood of
 * 0.75 means that the user is at least 75% likely to be at this place.
 */
@property(nonatomic, assign, readonly) double likelihood;

- (instancetype)initWithPlace:(GMSPlace *)place likelihood:(double)likelihood;

@end

NS_ASSUME_NONNULL_END
