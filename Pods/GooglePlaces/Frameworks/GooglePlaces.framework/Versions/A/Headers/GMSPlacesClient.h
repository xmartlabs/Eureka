//
//  GMSPlacesClient.h
//  Google Places API for iOS
//
//  Copyright 2016 Google Inc.
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://developers.google.com/maps/terms
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

#import <GooglePlaces/GMSPlace.h>
#import <GooglePlaces/GMSPlacesErrors.h>
#import <GooglePlaces/GMSUserAddedPlace.h>


@class GMSAutocompleteFilter;
@class GMSAutocompletePrediction;
@class GMSPlaceLikelihoodList;
@class GMSPlacePhotoMetadata;
@class GMSPlacePhotoMetadataList;

NS_ASSUME_NONNULL_BEGIN

/**
 * @relates GMSPlacesClient
 * Callback type for receiving place details lookups. If an error occurred,
 * |result| will be nil and |error| will contain information about the error.
 * @param result The |GMSPlace| that was returned.
 * @param error The error that occurred, if any.
 */
typedef void (^GMSPlaceResultCallback)(GMSPlace *_Nullable result, NSError *_Nullable error);

/**
 * @relates GMSPlacesClient
 * Callback type for receiving place likelihood lists. If an error occurred, |likelihoodList| will
 * be nil and |error| will contain information about the error.
 * @param likelihoodList The list of place likelihoods.
 * @param error The error that occurred, if any.
 */
typedef void (^GMSPlaceLikelihoodListCallback)(GMSPlaceLikelihoodList *_Nullable likelihoodList,
                                               NSError *_Nullable error);

/**
 * @relates GMSPlacesClient
 * Callback type for receiving autocompletion results. |results| is an array of
 * GMSAutocompletePredictions representing candidate completions of the query.
 * @param results An array of |GMSAutocompletePrediction|s.
 * @param error The error that occurred, if any.
 */
typedef void (^GMSAutocompletePredictionsCallback)(
    NSArray<GMSAutocompletePrediction *> *_Nullable results, NSError *_Nullable error);

/**
 * @relates GMSPlacesClient
 * Callback type for receiving place photos results. If an error occurred, |photos| will be nil and
 * |error| will contain information about the error.
 * @param photos The result containing |GMSPlacePhotoMetadata| objects.
 * @param error The error that occurred, if any.
 */
typedef void (^GMSPlacePhotoMetadataResultCallback)(
    GMSPlacePhotoMetadataList *_Nullable photos, NSError *_Nullable error);

/**
 * @relates GMSPlacesClient
 * Callback type for receiving |UIImage| objects from a |GMSPlacePhotoMetadata| object. If an error
 * occurred, |photo| will be nil and |error| will contain information about the error.
 * @param photo The |UIImage| which was loaded.
 * @param error The error that occurred, if any.
 */
typedef void (^GMSPlacePhotoImageResultCallback)(UIImage *_Nullable photo,
                                                 NSError *_Nullable error);

/**
 * Main interface to the Places API. Used for searching and getting details about places. This class
 * should be accessed through the [GMSPlacesClient sharedClient] method.
 *
 * GMSPlacesClient methods should only be called from the main thread. Calling these methods from
 * another thread will result in an exception or undefined behavior. Unless otherwise specified, all
 * callbacks will be invoked on the main thread.
 */
@interface GMSPlacesClient : NSObject

/**
 * Provides the shared instance of GMSPlacesClient for the Google Places API for iOS, creating it if
 * necessary.
 *
 * If your application often uses methods of GMSPlacesClient it may want to hold onto this object
 * directly, as otherwise your connection to Google may be restarted on a regular basis.
 */
+ (instancetype)sharedClient;

/**
 * Provides your API key to the Google Places API for iOS. This key is generated for your
 * application via the Google APIs Console, and is paired with your application's bundle ID to
 * identify it. This should be called exactly once by your application, e.g., in application:
 * didFinishLaunchingWithOptions:.
 *
 * @return YES if the APIKey was successfully provided.
 */
+ (BOOL)provideAPIKey:(NSString *)key;

/**
 * Returns the open source software license information for the Google Places API for iOS. This
 * information must be made available within your application.
 */
+ (NSString *)openSourceLicenseInfo;

/**
 * Returns the version for this release of the Google Places API for iOS.
 */
+ (NSString *)SDKVersion;

/**
 * Report that the device is at a particular place.
 */
- (void)reportDeviceAtPlaceWithID:(NSString *)placeID;

/**
 * Get details for a place. This method is non-blocking.
 * @param placeID The place ID to lookup.
 * @param callback The callback to invoke with the lookup result.
 */
- (void)lookUpPlaceID:(NSString *)placeID callback:(GMSPlaceResultCallback)callback;

/**
 * Gets the metadata for up to 10 photos associated with a place.
 *
 * Photos are sourced from a variety of locations, including business owners and photos contributed
 * by Google+ users. In most cases, these photos can be used without attribution, or will have the
 * required attribution included as a part of the image. However, you must use the |attributions|
 * property in the response to retrieve any additional attributions required, and display those
 * attributions in your application wherever you display the image. A maximum of 10 photos is
 * returned.
 *
 * Multiple calls of this method will probably return the same photos each time. However, this is
 * not guaranteed because the underlying data may have changed.
 *
 * This method performs a network lookup.
 *
 * @param placeID The place ID for which to lookup photos.
 * @param callback The callback to invoke with the lookup result.
 */
- (void)lookUpPhotosForPlaceID:(NSString *)placeID
                      callback:(GMSPlacePhotoMetadataResultCallback)callback;

/**
 * Loads the image for a specific photo at its maximum size.
 *
 * Image data may be cached. If the requested photo does not exist in the cache then a network
 * lookup will be performed.
 *
 * @param photo The photo for which to load a |UIImage|.
 * @param callback The callback to invoke with the loaded |UIImage|.
 */
- (void)loadPlacePhoto:(GMSPlacePhotoMetadata *)photo
              callback:(GMSPlacePhotoImageResultCallback)callback;

/**
 * Loads the image for a specific photo, scaled to fit the given maximum dimensions.
 *
 * The image will be scaled to fit within the given dimensions while maintaining the aspect ratio of
 * the original image. This scaling is performed server-side.
 *
 * If the scale parameter is not 1.0 maxSize will be multiplied by this value and the returned
 * UIImage will be set to have the specified scale. This parameter should be set to the screen scale
 * if you are loading images for display on screen.
 *
 * Image data may be cached. If the requested photo does not exist in the cache then a network
 * lookup will be performed.
 *
 * NOTE: After applying the scale factor the dimensions in maxSize will be rounded up to the nearest
 * integer before use. If an image is requested which is larger than the maximum size available a
 * smaller image may be returned.
 *
 * @param photo The photo for which to load a |UIImage|.
 * @param maxSize The maximum size of the image.
 * @param scale The scale to load the image at.
 * @param callback The callback to invoke with the loaded |UIImage|.
 */
- (void)loadPlacePhoto:(GMSPlacePhotoMetadata *)photo
     constrainedToSize:(CGSize)maxSize
                 scale:(CGFloat)scale
              callback:(GMSPlacePhotoImageResultCallback)callback;

/**
 * Returns an estimate of the place where the device is currently known to be located.
 *
 * Generates a place likelihood list based on the device's last estimated location. The supplied
 * callback will be invoked with this likelihood list upon success and an NSError upon an error.
 *
 * NOTE: This method requires that your app has permission to access the devices location. Before
 * calling this make sure to request access to the users location using [CLLocationManager
 * requestWhenInUseAuthorization] or [CLLocationManager requestAlwaysAuthorization]. If you do call
 * this method and your app does not have the correct authorization status, the callback will be
 * called with an error.
 *
 * @param callback The callback to invoke with the place likelihood list.
 */
- (void)currentPlaceWithCallback:(GMSPlaceLikelihoodListCallback)callback;

/**
 * Autocompletes a given text query. Results may optionally be biased towards a certain location.
 * The supplied callback will be invoked with an array of autocompletion predictions upon success
 * and an NSError upon an error.
 * @param query The partial text to autocomplete.
 * @param bounds The bounds used to bias the results. This is not a hard restrict - places may still
 *               be returned outside of these bounds. This parameter may be nil.
 * @param filter The filter to apply to the results. This parameter may be nil.
 * @param callback The callback to invoke with the predictions.
 */
- (void)autocompleteQuery:(NSString *)query
                   bounds:(nullable GMSCoordinateBounds *)bounds
                   filter:(nullable GMSAutocompleteFilter *)filter
                 callback:(GMSAutocompletePredictionsCallback)callback;

/**
 * Add a place. The |place| must have all its fields set, except that website or phoneNumber may be
 * nil.
 * @param place The details of the place to be added.
 * @param callback The callback to invoke with the place that was added.
 */
- (void)addPlace:(GMSUserAddedPlace *)place
        callback:(GMSPlaceResultCallback)callback;

@end

NS_ASSUME_NONNULL_END
