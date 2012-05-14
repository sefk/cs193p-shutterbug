//
//  PhotoViewController.m
//  Shutterbug
//
//  Created by Sef Kloninger on 5/11/12.
//  Copyright (c) 2012 Peek 222 Software. All rights reserved.
//

#import "PhotoViewController.h"
#import "FlickrFetcher.h"

@interface PhotoViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end


@implementation PhotoViewController

@synthesize scrollView;
@synthesize imageView;

@synthesize photoInfo = _photoInfo;
- (void) setPhotoInfo:(NSDictionary *)newPhotoInfo
{
    if (_photoInfo != newPhotoInfo) {
        _photoInfo = newPhotoInfo;
        [self.imageView setNeedsDisplay];
        [self.scrollView setNeedsDisplay];
    }
}


// 
// Setup Methods
//

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // ANYTHING?
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    // since this is potentially expensive, wait until the last minute to
    // kick off the call.  Maybe not visible, not needed?
    [self loadPhoto];
}

- (void)viewDidUnload
{
    self.scrollView = nil;
    self.imageView = nil;
    [super viewDidUnload];
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
    
    if (!photoURL || [[photoURL absoluteString] length] == 0) {
        NSLog(@"loadPhoto: photo couldn't get URL for photo: %@", self.photoInfo);
        return;  // TODO: segue back?  some UI for "can't load\" ?
    }

    dispatch_queue_t fetchQueue = dispatch_queue_create("load photo queue", NULL);
    dispatch_async(fetchQueue, ^{
        NSData * photoData = [NSData dataWithContentsOfURL:photoURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = [UIImage imageWithData:photoData]; 
            self.scrollView.contentSize = self.imageView.image.size;
            self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
            float xzoom = (scrollView.bounds.size.width / self.imageView.image.size.width);
            float yzoom = (scrollView.bounds.size.height / self.imageView.image.size.height);
            self.scrollView.zoomScale = 
//              (xzoom < yzoom) ? xzoom : yzoom;  // smaller zoom to show whole pic with borders
                (xzoom < yzoom) ? yzoom : xzoom;  // larger zoom to fill screen
            [self.scrollView flashScrollIndicators];
        });
    });
    dispatch_release(fetchQueue);
}


//
// Scroll View Delegate
//

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
