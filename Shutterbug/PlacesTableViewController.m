//
//  PlacesTableViewController.m
//  Shutterbug
//
//  Created by Sef Kloninger on 5/10/12.
//  Copyright (c) 2012 Peek 222 Software. All rights reserved.
//

#import "PlacesTableViewController.h"
#import "FlickrFetcher.h"

@interface PlacesTableViewController ()

@end

@implementation PlacesTableViewController

@synthesize places = _places;

- (void)setPlaces:(NSArray *)places
{
    if (places != _places) {
        _places = places;
        [self.tableView reloadData];        
    }
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // special setup here
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getTopPlaces];  // populate view w/ data from flickr

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Get Data For View

- (void) getTopPlaces
{
    dispatch_queue_t fetchQueue = dispatch_queue_create("fetch queue", NULL);
    dispatch_async(fetchQueue, ^{
        NSArray * newPlaces = [FlickrFetcher topPlaces];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.places = newPlaces;
        });
    });
    dispatch_release(fetchQueue);
}



#pragma mark - Table view data source

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhotoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSString * location;

    id thisPlace = [self.places objectAtIndex:indexPath.row];
    if ([thisPlace isKindOfClass:[NSDictionary class]]) {
        NSDictionary * placeDict = thisPlace;
        location = [placeDict valueForKey:@"_content"];
    }
    cell.textLabel.text = location;
    cell.detailTextLabel.text = location;
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}



@end
