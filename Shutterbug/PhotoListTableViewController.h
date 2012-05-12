//
//  PhotoListTableViewController.h
//  Shutterbug
//
//  Created by Sef Kloninger on 5/11/12.
//  Copyright (c) 2012 Peek 222 Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MAX_PHOTOS_FOR_PLACE 50

@interface PhotoListTableViewController : UITableViewController

- (NSArray *) getPhotoListFromHistory:(id)ignorable;
- (NSArray *) getPhotoListFromFlickrForPlace:(NSDictionary *)place;

@end
