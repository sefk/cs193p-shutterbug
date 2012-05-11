//
//  PlacesTableViewController.h
//  Shutterbug
//
//  Created by Sef Kloninger on 5/10/12.
//  Copyright (c) 2012 Peek 222 Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlacesTableViewController : UITableViewController


// model is a list of lists
// first list - CountryLists
@property (nonatomic, strong) NSArray * places;

@end
