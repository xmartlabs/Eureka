//
//  GMSAutocompleteMatchFragment.h
//  Google Places API for iOS
//
//  Copyright 2016 Google Inc.
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://developers.google.com/maps/terms
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * This class represents a matched fragment of a string. This is a contiguous range of characters
 * in a string, suitable for highlighting in an autocompletion UI.
 */
@interface GMSAutocompleteMatchFragment : NSObject

/**
 * The offset of the matched fragment. This is an index into a string. The character at this index
 * is the first matched character.
 */
@property(nonatomic, readonly) NSUInteger offset;

/**
 * The length of the matched fragment.
 */
@property(nonatomic, readonly) NSUInteger length;

@end

NS_ASSUME_NONNULL_END
