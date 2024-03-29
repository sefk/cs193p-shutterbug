//
//  CountryList.h
//  Shutterbug
//
//  Created by Sef Kloninger on 5/11/12.
//  Copyright (c) 2012 Peek 222 Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountryList : NSObject

@property (nonatomic, strong) NSMutableArray * cities;
@property (nonatomic, strong) NSString * countryName;

- (id)initWithName:(NSString *)name;

@end
