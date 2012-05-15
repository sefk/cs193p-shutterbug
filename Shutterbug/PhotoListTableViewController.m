//
//  PhotoListTableViewController.m
//  Shutterbug
//
//  Created by Sef Kloninger on 5/11/12.
//  Copyright (c) 2012 Peek 222 Software. All rights reserved.
//

#import "PhotoListTableViewController.h"
#import "FlickrFetcher.h"
#import "PlacesTableViewController.h"
#import "PhotoViewController.h"


@interface PhotoListTableViewController ()

@property (nonatomic, strong) NSArray * photoList;

@end



@implementation PhotoListTableViewController

@synthesize photoList = _photoList;
- (void) setPhotoList:(NSArray *)newPhotoList
{
    if (newPhotoList != _photoList) {
        _photoList = newPhotoList;
        [self.tableView reloadData];
    }
}

@synthesize location = _location;
- (void) setLocation:(NSDictionary *)newLocation
{
    if (_location != newLocation) {
        _location = newLocation;
        [self.tableView reloadData];
    }
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refreshPhotoList]; 
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

         
#pragma mark - Data Fetch Methods

- (IBAction) refreshPhotoList
{
    if (self.location) {
        // if location set (presumably from prepareForSegue then get photos
        // for that spot
        [self getPhotoListForLocation:self.location];
        self.navigationItem.title = [self.location objectForKey:FLICKR_DICT_KEY_CITY];
    } else {
        // no location set, just display the photo history
        [self getPhotoListFromHistory];
        self.navigationItem.title = @"History";
    }
}

- (void) getPhotoListForLocation:(NSDictionary *)place;
{
    // replace refresh button with spinner
    UIBarButtonItem * saveRefreshButton = self.navigationItem.rightBarButtonItem;
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    UIBarButtonItem * spinnerButton = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    self.navigationItem.rightBarButtonItem = spinnerButton; 
    
    dispatch_queue_t fetchQueue = dispatch_queue_create("fetch queue", NULL);
    dispatch_async(fetchQueue, ^{
        NSArray * newPhotos = [FlickrFetcher photosInPlace:place maxResults:MAX_PHOTOS_FOR_PLACE];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photoList = newPhotos;
            self.navigationItem.rightBarButtonItem = saveRefreshButton;
        });
    });
    dispatch_release(fetchQueue);
}


// This is quick enough that we don't need to bother with putting in another thread
- (void) getPhotoListFromHistory
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    assert(defaults);
    NSArray * existingHistory = [defaults arrayForKey:NSUSERDEFAULTS_KEY_HISTORY];
    if (existingHistory == nil) {
        self.photoList = [[NSMutableArray alloc] init];
    } else {
        self.photoList = existingHistory;
    }
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.photoList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhotoCellPrototype";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary * thisPhoto = [self.photoList objectAtIndex:indexPath.row];
    NSString * photoTitle = [thisPhoto objectForKey:@"title"];
    NSString * photoDesc =  [[thisPhoto objectForKey:@"description"] objectForKey:@"_content"];
    if (photoTitle.length) {
        cell.textLabel.text = photoTitle;
        cell.detailTextLabel.text = photoDesc;
    } else if (photoDesc.length) {
        cell.textLabel.text = photoDesc;
    } else {
        cell.textLabel.text = [NSString stringWithString:UNKNOWN_STRING];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.location) {
        // Add to History
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        assert(defaults);
        NSArray * existingHistory = [defaults arrayForKey:NSUSERDEFAULTS_KEY_HISTORY];
        NSMutableArray * newHistory;
        if (existingHistory == nil) {
            newHistory = [[NSMutableArray alloc] init];
        } else {
            newHistory = [existingHistory mutableCopy];
        }
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        [newHistory addObject:[self.photoList objectAtIndex:path.row]];
        [defaults setObject:newHistory forKey:NSUSERDEFAULTS_KEY_HISTORY];
        [defaults synchronize];
    }
    
    // Segue
    [self performSegueWithIdentifier:@"ShowPhoto" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowPhoto"]) {
        PhotoViewController * destVC = segue.destinationViewController;
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        destVC.photoInfo = [self.photoList objectAtIndex:path.row];
    }
}

@end
