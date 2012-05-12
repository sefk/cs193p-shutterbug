//
//  PlacesTableViewController.h
//  Shutterbug
//
//  Created by Sef Kloninger on 5/10/12.
//  Copyright (c) 2012 Peek 222 Software. All rights reserved.
//

#import <UIKit/UIKit.h>


// Putting here in public since the contents of the Flickr structure is othewise public
#define FLICKR_DICT_KEY_CITY    @"_content.city"
#define FLICKR_DICT_KEY_STATE   @"_content.state"
#define FLICKR_DICT_KEY_COUNTRY @"_content.country"

// What to display if we have no clue about City, State, or country.  User visible
// string (should be localized I guess).
#define UNKNOWN_STRING          @"Unknown"


@interface PlacesTableViewController : UITableViewController


@end
