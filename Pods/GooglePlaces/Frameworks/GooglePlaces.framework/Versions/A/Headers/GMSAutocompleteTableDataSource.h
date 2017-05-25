//
//  GMSAutocompleteTableDataSource.h
//  Google Places API for iOS
//
//  Copyright 2016 Google Inc.
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://developers.google.com/maps/terms
//

#import <UIKit/UIKit.h>

#if __has_feature(modules)
@import GoogleMapsBase;
#else
#import <GoogleMapsBase/GoogleMapsBase.h>
#endif
#import <GooglePlaces/GMSAutocompleteFilter.h>
#import <GooglePlaces/GMSAutocompletePrediction.h>
#import <GooglePlaces/GMSPlace.h>

NS_ASSUME_NONNULL_BEGIN

@class GMSAutocompleteTableDataSource;

/**
 * Protocol used by |GMSAutocompleteTableDataSource|, to communicate the user's interaction with the
 * data source to the application.
 */
@protocol GMSAutocompleteTableDataSourceDelegate <NSObject>

@required

/**
 * Called when a place has been selected from the available autocomplete predictions.
 * @param tableDataSource The |GMSAutocompleteTableDataSource| that generated the event.
 * @param place The |GMSPlace| that was returned.
 */
- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource
    didAutocompleteWithPlace:(GMSPlace *)place;

/**
 * Called when a non-retryable error occurred when retrieving autocomplete predictions or place
 * details. A non-retryable error is defined as one that is unlikely to be fixed by immediately
 * retrying the operation.
 * <p>
 * Only the following values of |GMSPlacesErrorCode| are retryable:
 * <ul>
 * <li>kGMSPlacesNetworkError
 * <li>kGMSPlacesServerError
 * <li>kGMSPlacesInternalError
 * </ul>
 * All other error codes are non-retryable.
 * @param tableDataSource The |GMSAutocompleteTableDataSource| that generated the event.
 * @param error The |NSError| that was returned.
 */
- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource
    didFailAutocompleteWithError:(NSError *)error;

@optional

/**
 * Called when the user selects an autocomplete prediction from the list but before requesting
 * place details. Returning NO from this method will suppress the place details fetch and
 * didAutocompleteWithPlace will not be called.
 * @param tableDataSource The |GMSAutocompleteTableDataSource| that generated the event.
 * @param prediction The |GMSAutocompletePrediction| that was selected.
 */
- (BOOL)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource
    didSelectPrediction:(GMSAutocompletePrediction *)prediction;

/**
 * Called once every time new autocomplete predictions are received.
 * @param tableDataSource The |GMSAutocompleteTableDataSource| that generated the event.
 */
- (void)didUpdateAutocompletePredictionsForTableDataSource:
    (GMSAutocompleteTableDataSource *)tableDataSource;

/**
 * Called once immediately after a request for autocomplete predictions is made.
 * @param tableDataSource The |GMSAutocompleteTableDataSource| that generated the event.
 */
- (void)didRequestAutocompletePredictionsForTableDataSource:
    (GMSAutocompleteTableDataSource *)tableDataSource;

@end


/**
 * GMSAutocompleteTableDataSource provides an interface for providing place autocomplete
 * predictions to populate a UITableView by implementing the UITableViewDataSource and
 * UITableViewDelegate protocols.
 *
 * GMSAutocompleteTableDataSource is designed to be used as the data source for a
 * UISearchDisplayController.
 *
 * NOTE: Unless iOS 7 compatibility is required, using UISearchController with
 * |GMSAutocompleteResultsViewController| instead of UISearchDisplayController is highly
 * recommended.
 *
 * Set an instance of GMSAutocompleteTableDataSource as the searchResultsDataSource and
 * searchResultsDelegate properties of UISearchDisplayController. In your implementation of
 * shouldReloadTableForSearchString, call sourceTextHasChanged with the current search string.
 *
 * Use the |GMSAutocompleteTableDataSourceDelegate| delegate protocol to be notified when a place is
 * selected from the list. Because autocomplete predictions load asynchronously, it is necessary
 * to implement didUpdateAutocompletePredictions and call reloadData on the
 * UISearchDisplayController's table view.
 *
 */
@interface GMSAutocompleteTableDataSource : NSObject <
    UITableViewDataSource, UITableViewDelegate>

/** Delegate to be notified when a place is selected or picking is cancelled. */
@property(nonatomic, weak, nullable) IBOutlet id<GMSAutocompleteTableDataSourceDelegate> delegate;

/** Bounds used to bias the autocomplete search (can be nil). */
@property(nonatomic, strong, nullable) GMSCoordinateBounds *autocompleteBounds;

/** Filter to apply to autocomplete suggestions (can be nil). */
@property(nonatomic, strong, nullable) GMSAutocompleteFilter *autocompleteFilter;

/** The background color of table cells. */
@property(nonatomic, strong) UIColor *tableCellBackgroundColor;

/** The color of the separator line between table cells. */
@property(nonatomic, strong) UIColor *tableCellSeparatorColor;

/** The color of result name text in autocomplete results */
@property(nonatomic, strong) UIColor *primaryTextColor;

/** The color used to highlight matching text in autocomplete results */
@property(nonatomic, strong) UIColor *primaryTextHighlightColor;

/** The color of the second row of text in autocomplete results. */
@property(nonatomic, strong) UIColor *secondaryTextColor;

/** The tint color applied to controls in the Autocomplete view. */
@property(nonatomic, strong, nullable) UIColor *tintColor;

/** Designated initializer */
- (instancetype)init NS_DESIGNATED_INITIALIZER;

/**
 * Notify the data source that the source text to autocomplete has changed.
 *
 * This method should only be called from the main thread. Calling this method from another thread
 * will result in undefined behavior. Calls to |GMSAutocompleteTableDataSourceDelegate| methods will
 * also be called on the main thread.
 *
 * This method is non-blocking.
 * @param text The partial text to autocomplete.
 */
- (void)sourceTextHasChanged:(nullable NSString *)text;

@end

NS_ASSUME_NONNULL_END
