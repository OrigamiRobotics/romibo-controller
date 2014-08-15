//
//  TagLocationManager.m
//  ProximityApp
//
//  Copyright (c) 2012 Nordic Semiconductor. All rights reserved.
//

#import "TagLocationManager.h"

@implementation TagLocationManager 
{
    CLLocationManager* lm;
}
@synthesize tagArray = _tagArray;
@synthesize lastLocation = _lastLocation;

static TagLocationManager* sharedLocationManager;

+ (TagLocationManager*) sharedInstance
{
    if (sharedLocationManager == nil)
    {
        sharedLocationManager = [[TagLocationManager alloc] init];
    }
    return sharedLocationManager;
}

- (TagLocationManager*) init
{
    if(self = [super init]) {
        self.tagArray = [[NSMutableArray alloc] init];
        lm = [[CLLocationManager alloc] init];
        lm.delegate = self;
    }
    return self;
}

- (void) startMonitoringForTag:(id)tag
{
    [self.tagArray addObject:tag];
    if ([self.tagArray count] > 0)
    {
        [lm startUpdatingLocation];
    }
}

- (void) stopMonitoringForTag:(id) tag
{
    [self.tagArray removeObject:tag];
    if ([self.tagArray count] == 0)
    {
        [lm stopUpdatingLocation];
    }
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"Location updated: %@", newLocation);
    self.lastLocation = newLocation;
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location manager errored: %@", error);
}

@end
