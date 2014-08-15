//
//  ConnectionManager.h
//  ProximityApp
//
//  Copyright (c) 2012 Nordic Semiconductor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "ProximityTag.h"
//#import "ProximityTagStorage.h"

extern NSString * romibo_service_ID;
extern NSString * romibo_characteristic_Write_ID;
extern NSString * romibo_characteristic_Notify_ID;


@protocol ConnectionManagerDelegate <ProximityTagDelegate>
- (void) isBluetoothEnabled:(bool) enabled;
- (void) didDiscoverTag:(ProximityTag*) tag;

@end

@interface ConnectionManager : NSObject <CBCentralManagerDelegate>

@property id<ConnectionManagerDelegate> delegate;
@property (nonatomic, strong)   ProximityTag * connectToTag;
@property (nonatomic, strong)   CBPeripheral * connectedPeripheral;

+ (ConnectionManager*) sharedInstance;

- (void) startScanForTags;
- (void) stopScanForTags;
- (void) retrieveKnownPeripherals;
- (void) disconnectTag:(ProximityTag*) tag;

@end
