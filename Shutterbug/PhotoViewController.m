//
//  PhotoViewController.m
//  Shutterbug
//
//  Created by Sef Kloninger on 5/11/12.
//  Copyright (c) 2012 Peek 222 Software. All rights reserved.
//

#import "PhotoViewController.h"
#import "FlickrFetcher.h"

@interface PhotoViewController ()

@end

@implementation PhotoViewController

@synthesize photoInfo = _photoInfo;
- (void) setPhotoInfo:(NSDictionary *)newPhotoInfo
{
    if (_photoInfo != newPhotoInfo) {
        _photoInfo = newPhotoInfo;
        [self.view setNeedsDisplay];
    }
}


// 
// Setup Methods
//

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadPhoto];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
     

//
// Main Functionality
// 
     
- (void) loadPhoto
{
    NSURL * photoURL = [FlickrFetcher urlForPhoto:self.photoInfo format:FlickrPhotoFormatLarge];
    
    if (photoURL && [[photoURL absoluteString] length]) {
        dispatch_queue_t fetchQueue = dispatch_queue_create("load photo queue", NULL);
        dispatch_async(fetchQueue, ^{
            NSData * photoData = [NSData dataWithContentsOfURL:photoURL];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImageView * displayImage = self.view;
                displayImage.image = [UIImage imageWithData:photoData];
            });
        });
        dispatch_release(fetchQueue);
    }
}

@end
