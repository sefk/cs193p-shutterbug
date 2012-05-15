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


@interface PhotoListTableViewController () <UIGestureRecognizerDelegate>

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

- (void)viewWillAppear:(BOOL)animated
{
    // The button in the upper right varies by the type of view, so let's get that
    // set up first
    if (self.location) {
        // photo list case -- refresh button, a system style
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] 
                       initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                       target:self
                       action:@selector(refreshPhotoList:)];
    } else {
        // photo history case -- clear all button, text
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] 
                      initWithTitle:@"Clear All"
                      style:UIBarButtonItemStylePlain
                      target:self
                      action:@selector(photoHistoryClearAll:)];
    }

    // Actually go out and fill up the view
    [self refreshPhotoList:self]; 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

         
#pragma mark - Data Fetch Methods

- (IBAction) refreshPhotoList:(id)sender
{
    if (self.location) {
        // if location set (presumably from prepareForSegue) then get photos
        // for that spot
        [self getPhotoListForLocation:self.location];
        self.navigationItem.title = [self.location objectForKey:FLICKR_DICT_KEY_CITY];
    } else {
        // no location set, just display the photo history
        [self getPhotoHistory];
        self.navigationItem.title = @"History";
    }
}

- (void) getPhotoListForLocation:(NSDictionary *)place;
{
    // replace refresh button with spinner
    UIBarButtonItem * saveTopRightButton = self.navigationItem.rightBarButtonItem;
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    UIBarButtonItem * spinnerButton = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    self.navigationItem.rightBarButtonItem = spinnerButton; 
    
    dispatch_queue_t fetchQueue = dispatch_queue_create("fetch queue", NULL);
    dispatch_async(fetchQueue, ^{
        NSArray * newPhotos = [FlickrFetcher photosInPlace:place maxResults:MAX_PHOTOS_FOR_PLACE];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photoList = newPhotos;
            self.navigationItem.rightBarButtonItem = saveTopRightButton;
        });
    });
    dispatch_release(fetchQueue);
}

- (IBAction) photoHistoryClearAll:(id)sender
{
    [self clearPhotoHistory];
    [self getPhotoHistory];
    [self.tableView reloadData];
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


#pragma mark - dealing with history

- (void) addPhotoToTopOfHistory:(NSDictionary *)photoToAdd
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    assert(defaults);
    NSArray * existingHistory = [defaults arrayForKey:NSUSERDEFAULTS_KEY_HISTORY];
    NSMutableArray * newHistory;
    if (existingHistory == nil) {
        newHistory = [[NSMutableArray alloc] init];
    } else {
        newHistory = [existingHistory mutableCopy];
    }
    [newHistory insertObject:photoToAdd atIndex:0];    // most recent at the top
    [defaults setObject:newHistory forKey:NSUSERDEFAULTS_KEY_HISTORY];
    [defaults synchronize];   
}

- (void) removePhotoHistoryItemAtPosition:(NSInteger)pos
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    assert(defaults);
    NSArray * existingHistory = [defaults arrayForKey:NSUSERDEFAULTS_KEY_HISTORY];
    NSMutableArray * newHistory = [existingHistory mutableCopy];
    [newHistory removeObjectAtIndex:pos];
    [defaults setObject:newHistory forKey:NSUSERDEFAULTS_KEY_HISTORY];
    [defaults synchronize];   
}

// This is quick enough that we don't need to bother with putting in another thread
- (void) getPhotoHistory
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

- (void) clearPhotoHistory
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    assert(defaults);
    [defaults removeObjectForKey:NSUSERDEFAULTS_KEY_HISTORY];
    [defaults synchronize];
}

                                                  
                                                  
                


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.location) {
        // if location is set then I'm a photo list viewer, not a history viewer
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        NSDictionary *selectedPhoto = [self.photoList objectAtIndex:path.row];
        [self addPhotoToTopOfHistory:selectedPhoto];
    }
    
    // Now do segue to bring up the photo viewer itself
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


#pragma mark - Table Editing

// Override to support editing the table view.

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self removePhotoHistoryItemAtPosition:[indexPath indexAtPosition:0]];
        [self getPhotoHistory];  // better as a [self.tableView reloadData] ? coudn't get working
    }    
}



@end
