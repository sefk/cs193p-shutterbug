//
//  PlacesTableViewController.m
//  Shutterbug
//
//  Created by Sef Kloninger on 5/10/12.
//  Copyright (c) 2012 Peek 222 Software. All rights reserved.
//

#import "PlacesTableViewController.h"
#import "FlickrFetcher.h"
#import "CountryList.h"

@interface PlacesTableViewController ()

// model is a list Country Classes.  Each of these has the country name (corresponds to one
// section in the table view) and an ordered list of cities.
@property (nonatomic, strong) NSArray * placesList;
@end







@implementation PlacesTableViewController

@synthesize placesList = _places;

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
    return YES;
}


#pragma mark - Get Data For View

#define FLICKR_DICT_KEY_CITY    @"_content.city"
#define FLICKR_DICT_KEY_STATE   @"_content.state"
#define FLICKR_DICT_KEY_COUNTRY @"_content.country"
#define UNKNOWN_STRING          @"Unknown"

+ (NSArray *)parseAndSortFlickrPlaces:(NSArray *)fromFlickr
{
    NSMutableArray * listParsedAndSorted = [[NSMutableArray alloc] init];
    NSMutableArray * listCountryLists = [[NSMutableArray alloc] init];
    
    [fromFlickr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        assert([obj isKindOfClass:[NSDictionary class]]);
        NSMutableDictionary * thisEntry = [obj mutableCopy];
        
        // split on comma, remove whitespace, and then insert new keys for three parts
        [thisEntry setValue:UNKNOWN_STRING forKey:FLICKR_DICT_KEY_CITY];
        [thisEntry setValue:UNKNOWN_STRING forKey:FLICKR_DICT_KEY_STATE];
        [thisEntry setValue:UNKNOWN_STRING forKey:FLICKR_DICT_KEY_COUNTRY];
        
        NSArray * locationParts = [[thisEntry objectForKey:@"_content"] componentsSeparatedByString:@", "];
        switch ([locationParts count]) {
            case 0:    // shouldn't happen, if no commas, resulting list should have one entry
                break;
            case 1:    // no commas, just use as city
                [thisEntry setValue:[locationParts objectAtIndex:0] forKey:FLICKR_DICT_KEY_CITY];
                break;
            case 2:    // two commas, assume no state, just city+country
                [thisEntry setValue:[locationParts objectAtIndex:0] forKey:FLICKR_DICT_KEY_CITY];
                [thisEntry setValue:[locationParts objectAtIndex:1] forKey:FLICKR_DICT_KEY_COUNTRY];
                break;
            default:   // three or more commas, use first three
                [thisEntry setValue:[locationParts objectAtIndex:0] forKey:FLICKR_DICT_KEY_CITY];
                [thisEntry setValue:[locationParts objectAtIndex:1] forKey:FLICKR_DICT_KEY_STATE];
                [thisEntry setValue:[locationParts objectAtIndex:2] forKey:FLICKR_DICT_KEY_COUNTRY];
        }
        
        
        [listParsedAndSorted addObject:thisEntry];
    }];
     
    // now sort by country, city, state (in that order)
    [listParsedAndSorted sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSComparisonResult result;
        
        assert([obj1 isKindOfClass:[NSDictionary class]]);
        NSDictionary * dict1 = obj1;
        assert([obj2 isKindOfClass:[NSDictionary class]]);
        NSDictionary * dict2 = obj2;

        result = [[dict1 valueForKey:FLICKR_DICT_KEY_COUNTRY] localizedCaseInsensitiveCompare:[dict2 valueForKey:FLICKR_DICT_KEY_COUNTRY]];
        if (result == NSOrderedSame) {
            result = [[dict1 valueForKey:FLICKR_DICT_KEY_CITY] localizedCaseInsensitiveCompare:[dict2 valueForKey:FLICKR_DICT_KEY_CITY]];
        }
        if (result == NSOrderedSame) {
            result = [[dict1 valueForKey:FLICKR_DICT_KEY_STATE] localizedCaseInsensitiveCompare:[dict2 valueForKey:FLICKR_DICT_KEY_STATE]];
        }
                                             
        return result;        
    }];
    
    // split into list of countries (sections) that each has a list of cities
    __block NSString * priorCountry = nil; // figure out if new
    __block CountryList * workingCountryList = [[CountryList alloc] init];
    
    [listParsedAndSorted enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        assert([obj isKindOfClass:[NSDictionary class]]);
        NSDictionary * locationDict = obj;

        NSString * currentCountryName = [locationDict valueForKey:FLICKR_DICT_KEY_COUNTRY];
        
        if (priorCountry && [currentCountryName localizedCaseInsensitiveCompare:priorCountry] != NSOrderedSame) {
            [listCountryLists addObject:[workingCountryList copy]];
            workingCountryList = [[CountryList alloc] init];
        }
        workingCountryList.countryName = currentCountryName;
        [workingCountryList.cities addObject:[locationDict copy]];
        priorCountry = currentCountryName;
    }];
    [listCountryLists addObject:[workingCountryList copy]];
    
    return listCountryLists;
}



- (void) getTopPlaces
{
    dispatch_queue_t fetchQueue = dispatch_queue_create("fetch queue", NULL);
    dispatch_async(fetchQueue, ^{
        NSArray * newPlaces = [FlickrFetcher topPlaces];
        NSArray * parsedPlaces = [PlacesTableViewController parseAndSortFlickrPlaces:newPlaces];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.placesList = parsedPlaces;
        });
    });
    dispatch_release(fetchQueue);
}



#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.placesList count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self.placesList objectAtIndex:section] countryName];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CountryList * thisCountry = [self.placesList objectAtIndex:section];
    return [thisCountry.cities count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CityCellPrototype";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
    CountryList * thisCountry = [self.placesList objectAtIndex:indexPath.section];
    NSArray * cityList = thisCountry.cities;
    NSDictionary * thisCityState = [cityList objectAtIndex:indexPath.row];
    cell.textLabel.text = [thisCityState valueForKey:FLICKR_DICT_KEY_CITY];
    cell.detailTextLabel.text = [thisCityState valueForKey:FLICKR_DICT_KEY_STATE];

    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}



@end
