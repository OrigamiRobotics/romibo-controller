//
//  TagController.h
//  ProximityApp
//
//  Copyright (c) 2012 Nordic Semiconductor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "TagLocationManager.h"

typedef enum {
    PROXIMITY_TAG_ALERT_LEVEL_NONE,
    PROXIMITY_TAG_ALERT_LEVEL_MILD,
    PROXIMITY_TAG_ALERT_LEVEL_HIGH,
} ProximityTagAlertLevel;

typedef enum {
    PROXIMITY_TAG_STATE_UNINITIALIZED,
    PROXIMITY_TAG_STATE_BONDING,
    PROXIMITY_TAG_STATE_BONDED,
    PROXIMITY_TAG_STATE_CLOSING,
    PROXIMITY_TAG_STATE_CLOSE,
    PROXIMITY_TAG_STATE_REMOTING,
    PROXIMITY_TAG_STATE_REMOTE,
    PROXIMITY_TAG_STATE_LINK_LOST,
    PROXIMITY_TAG_STATE_DISCONNECTED,
} ProximityTagState;

@protocol ProximityTagDelegate
- (void) didUpdateData:(id) tag;
@optional
- (void) didFailToConnect:(id) tag;
@end

@interface ProximityTag : NSObject <CBPeripheralDelegate>
@property id<ProximityTagDelegate> delegate;
@property (nonatomic) ProximityTagState state;
@property (nonatomic, strong) CBPeripheral* peripheral;
@property CFUUIDRef peripheralCFUUIDRef;
@property NSString* name;
@property (nonatomic) ProximityTagAlertLevel linkLossAlertLevelOnTag;
@property (nonatomic) ProximityTagAlertLevel linkLossAlertLevelOnPhone;
@property float rssiLevel;
@property float rssiThreshold;
@property BOOL hasBeenBonded;

@property (nonatomic, strong) CBService *romiboService;
@property (nonatomic, strong) CBCharacteristic *romibo_characteristic_write;
@property (nonatomic, strong) CBCharacteristic *romibo_characteristic_notify;

@property NSUInteger batteryLevel;

@property (nonatomic) BOOL locationTrackingIsEnabled;
@property (nonatomic) BOOL rangeMonitoringIsEnabled;
@property CLLocation* lastSeenLocation;

+ (CBUUID*) linkLossServiceUUID;
+ (CBUUID*) findMeServiceUUID;
+ (CBUUID*) alertLevelCharacteristicUUID;
+ (CBUUID*) batteryServiceUUID;
+ (CBUUID*) batteryLevelCharacteristicUUID;
+ (CBUUID*) romiboServiceUUID;
+ (CBUUID*) romiboWriteCharacteristicUUID;
+ (CBUUID*) romiboNotifyCharacteristicUUID;

- (id) init;
- (NSString*) connectionImageNameBasedOnRSSI;
- (void) didConnect;
- (void) didDisconnect;
- (bool) findTag:(ProximityTagAlertLevel) level;
- (BOOL) isConnected;
- (BOOL) isBonded;

@end
