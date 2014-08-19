//
//  TagLocationManager.h
//  ProximityApp
//
//  Copyright (c) 2012 Nordic Semiconductor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class ProximityTag;

@interface TagLocationManager : NSObject <CLLocationManagerDelegate>
@property (nonatomic, strong) NSMutableArray* tagArray;
@property (nonatomic, copy) CLLocation* lastLocation;

+ (TagLocationManager*) sharedInstance;

- (void) startMonitoringForTag:(ProximityTag*) tag;
- (void) stopMonitoringForTag:(ProximityTag*) tag;

@end
