//
//  CountryList.m
//  Shutterbug
//
//  Created by Sef Kloninger on 5/11/12.
//  Copyright (c) 2012 Peek 222 Software. All rights reserved.
//

#import "CountryList.h"

@implementation CountryList

@synthesize countryName = _countryName;

@synthesize cities = _cities;

- (NSMutableArray *)cities 
{
    if (!_cities) _cities = [[NSMutableArray alloc] init];
    return _cities;
}

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        self.countryName = name;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    CountryList * new = [[CountryList allocWithZone:zone] init];
    if (new) {
        new.countryName = [NSString stringWithString:self.countryName];
        new.cities = [[NSMutableArray allocWithZone:zone] initWithArray:self.cities copyItems:YES];
    }
    return new;
}

@end
