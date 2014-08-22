//
//  TagController.m
//  ProximityApp
//
//  Copyright (c) 2012 Nordic Semiconductor. All rights reserved.
//

#import "ProximityTag.h"
//#import "SharedUI.h"
#import "ConnectionManager.h"

@implementation ProximityTag {
    NSTimer *rssiTimer;
    NSTimer *readTimer;

    CBService *immediateAlertService;
    CBCharacteristic *immediateAlertAlertLevelCharacteristic;
    
    CBService *linkLossService;
    CBCharacteristic *linkLossAlertLevelCharacteristic;
    
    CBService *batteryService;
    CBCharacteristic *batteryLevelCharacteristic;


}

@synthesize delegate = _delegate;
@synthesize state = _state;
@synthesize peripheral = _peripheral;
@synthesize peripheralCFUUIDRef = _peripheralCFUUIDRef;
@synthesize name = _name;

@synthesize linkLossAlertLevelOnTag = _linkLossAlertLevelOnTag;
@synthesize linkLossAlertLevelOnPhone = _linkLossAlertLevelOnPhone;

@synthesize rangeMonitoringIsEnabled = _rangeMonitoringIsEnabled;
@synthesize rssiLevel = _rssiLevel;
@synthesize rssiThreshold = _rssiThreshold;

@synthesize batteryLevel = _batteryLevel;

@synthesize lastSeenLocation = _lastSeenLocation;
@synthesize locationTrackingIsEnabled = _locationTrackingIsEnabled;

@synthesize hasBeenBonded = _hasBeenBonded;


+ (CBUUID*) linkLossServiceUUID
{
    return [CBUUID UUIDWithString:@"1803"];
}

+ (CBUUID*) findMeServiceUUID
{
    return [CBUUID UUIDWithString:@"1802"];
}

+ (CBUUID*) alertLevelCharacteristicUUID
{
    return [CBUUID UUIDWithString:@"2A06"];
}

+ (CBUUID*) batteryServiceUUID
{
    return [CBUUID UUIDWithString:@"180F"];
}

+ (CBUUID*) batteryLevelCharacteristicUUID
{
    return [CBUUID UUIDWithString:@"2A19"];
}


+ (CBUUID*) romiboServiceUUID
{
    return [CBUUID UUIDWithString:romibo_service_ID];
}

+ (CBUUID*) romiboWriteCharacteristicUUID
{
    return [CBUUID UUIDWithString:romibo_characteristic_Write_ID];
}

+ (CBUUID*) romiboNotifyCharacteristicUUID
{
    return [CBUUID UUIDWithString:romibo_characteristic_Notify_ID];
}

- (id) init
{
    if (self = [super init]) {        
        _linkLossAlertLevelOnTag = PROXIMITY_TAG_ALERT_LEVEL_HIGH;
        _linkLossAlertLevelOnPhone = PROXIMITY_TAG_ALERT_LEVEL_MILD;
        _rssiThreshold = -50.0f;
        _hasBeenBonded = NO;
        
        _state = PROXIMITY_TAG_STATE_UNINITIALIZED;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *) decoder
{
    if (self = [super init]) {
        _peripheralCFUUIDRef = CFUUIDCreateFromString(NULL, (__bridge_retained CFStringRef) [decoder decodeObjectForKey:@"UUIDString"]);
        _name = [decoder decodeObjectForKey:@"name"];
        _linkLossAlertLevelOnTag =     (int)[decoder decodeIntegerForKey:@"linkLossAlertLevelOnTag"];
        _linkLossAlertLevelOnPhone =   (int)[decoder decodeIntegerForKey:@"linkLossAlertLevelOnPhone"];
        _rangeMonitoringIsEnabled =         [decoder decodeBoolForKey:@"rangeMonitoringIsEnabled"];
        _rssiThreshold =             (float)[decoder decodeDoubleForKey:@"RSSIThreshold"];
        _locationTrackingIsEnabled =        [decoder decodeBoolForKey:@"locationTrackingIsEnabled"];
        _lastSeenLocation =                 [decoder decodeObjectForKey:@"lastSeenLocation"];
        _hasBeenBonded =                    [decoder decodeBoolForKey:@"hasBeenBonded"];
        
        NSLog(@"Initializing tag %@ with RSSI-threshold %f and link loss alert %d", _name, _rssiThreshold, _linkLossAlertLevelOnTag);
        
        _state = PROXIMITY_TAG_STATE_DISCONNECTED;
    }
    return self;
}

- (void) setState:(ProximityTagState) newState
{
    NSLog(@"Set state of %@ to %d", self.name, newState);
    switch (newState)
    {
        case PROXIMITY_TAG_STATE_BONDING:
            break;
            
        case PROXIMITY_TAG_STATE_BONDED:
            self.hasBeenBonded = YES;
            [self startRangeMonitoringIfEnabled];
            [self startLocationMonitoringIfEnabled];
            break;
            
        case PROXIMITY_TAG_STATE_DISCONNECTED:
        case PROXIMITY_TAG_STATE_LINK_LOST:
            self.rssiLevel = 0;
            [self stopRangeMonitoring];
            [self stopLocationMonitoring];

            // Only store the location if we are currently bonded (i.e. the link was lost now, and we are not just initializing this object)
            if ([self isBonded])
            {
                [self storeLocationIfEnabled];
 //               [SharedUI showOutOfRangeDialog:self.linkLossAlertLevelOnPhone forTag:self];
            } 
            // If the tag has never been bonded, and then disconnected, this indicates a failed connect.
            else if (!self.hasBeenBonded)
            {
//                [SharedUI showFailedConnectDialog:self];
            }
            break;
            
        case PROXIMITY_TAG_STATE_CLOSE:
            [self startLocationMonitoringIfEnabled];
            break;
            
        case PROXIMITY_TAG_STATE_REMOTE:
            [self stopLocationMonitoring];
            [self storeLocationIfEnabled];
//            [SharedUI showOutOfRangeDialog:self.linkLossAlertLevelOnPhone forTag:self];
            break;
            
        default:
            break;
    }
    _state = newState;
    [self.delegate didUpdateData:self];
}

- (void) setPeripheral:(CBPeripheral*)peripheral
{
    _peripheral = peripheral;
    _peripheral.delegate = self;

    self.rssiLevel = (float)[[_peripheral RSSI] doubleValue];
    
    if (!self.name && [_peripheral name])
    {
        self.name = [_peripheral name];
    }
}

- (void) writeLinkLossAlertLevelToTag:(ProximityTagAlertLevel) linkLossAlertLevel
{
    [self.peripheral writeValue:[NSData dataWithBytes:&linkLossAlertLevel length:1] forCharacteristic:linkLossAlertLevelCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void) writeImmediateAlertLevelToTag:(ProximityTagAlertLevel) immediateAlertLevel
{
    [self.peripheral writeValue:[NSData dataWithBytes:&immediateAlertLevel length:1] forCharacteristic:immediateAlertAlertLevelCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

- (bool) findTag:(ProximityTagAlertLevel) level
{
    if(immediateAlertAlertLevelCharacteristic != nil) {
        NSLog(@"Writes alert %d to tag...", level);
        [self writeImmediateAlertLevelToTag:level];
        return YES;
    }
    NSLog(@"Couldn´t write to alert level.");
    return NO;
}

- (void) setLinkLossAlertLevelOnTag:(ProximityTagAlertLevel)linkLossAlertLevel
{
    _linkLossAlertLevelOnTag = linkLossAlertLevel;
    
    if (self.isBonded)
    {
        [self writeLinkLossAlertLevelToTag:linkLossAlertLevel];
    }
}

- (void) setLocationTrackingIsEnabled:(BOOL)locationTrackingIsEnabled
{
    _locationTrackingIsEnabled = locationTrackingIsEnabled;
    
    if (self.locationTrackingIsEnabled)
    {
        [self startLocationMonitoringIfEnabled];
    } 
    else 
    {
        [self stopLocationMonitoring];
    }
    
}

- (void) setRangeMonitoringIsEnabled:(BOOL)rangeMonitoringIsEnabled
{
    _rangeMonitoringIsEnabled = rangeMonitoringIsEnabled;
    
    if (self.rangeMonitoringIsEnabled)
    {
        [self startRangeMonitoring];
    } 
    else 
    {
        [self stopRangeMonitoring];
    }
    
}

- (void) encodeWithCoder:(NSCoder *) encoder
{
    // Trying to save a tag without UUID will fail. Assert to be able to know what happens from crash log.
    assert(self.peripheral.identifier != nil);
    
    NSString* uuidString = [self.peripheral.identifier UUIDString];

    [encoder encodeObject:uuidString forKey:@"UUIDString"];
    
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeInteger:self.linkLossAlertLevelOnTag forKey:@"linkLossAlertLevelOnTag"];
    [encoder encodeInteger:self.linkLossAlertLevelOnPhone forKey:@"linkLossAlertLevelOnPhone"];
    [encoder encodeDouble:self.rssiThreshold forKey:@"RSSIThreshold"];
    [encoder encodeBool:self.rangeMonitoringIsEnabled forKey:@"rangeMonitoringIsEnabled"];
    [encoder encodeBool:self.locationTrackingIsEnabled forKey:@"locationTrackingIsEnabled"];
    [encoder encodeObject:self.lastSeenLocation forKey:@"lastSeenLocation"];
    [encoder encodeBool:self.hasBeenBonded forKey:@"hasBeenBonded"];
}

- (void) didConnect
{
    [self setState:PROXIMITY_TAG_STATE_BONDING];
    NSLog(@"Did connect to %@. Starting service discovery.", self.name);
    
    if (!self.name && [self.peripheral name])
    {
        self.name = [self.peripheral name];
    }
    
    self.peripheralCFUUIDRef = (__bridge CFUUIDRef)self.peripheral.identifier;
    
    [self.peripheral readRSSI];
    
    [self.peripheral discoverServices:nil];
}

- (void) didDisconnect
{
    [self setState:PROXIMITY_TAG_STATE_LINK_LOST];
    
    NSLog(@"Did disconnect %@.", self.name);
}

- (void) startRangeMonitoringIfEnabled
{
    if (self.rangeMonitoringIsEnabled)
    {
        [self startRangeMonitoring];
    }
}

- (void) startRangeMonitoring
{
    if (![self isConnected])
    {
        NSLog(@"Can not start monitoring range of a not connected device, %@", self.name);
        return;
    }
    NSLog(@"Starting range monitoring of %@", self.name);
    [rssiTimer invalidate];
    rssiTimer = [NSTimer timerWithTimeInterval:1.0 target:_peripheral selector:@selector(readRSSI)    userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:rssiTimer forMode:NSRunLoopCommonModes];
    
    
    [readTimer invalidate];
    readTimer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(readLinkLossAlert) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:readTimer forMode:NSRunLoopCommonModes];
}        

- (void) stopRangeMonitoring
{
    NSLog(@"Stopping range monitoring of %@", self.name);
    [rssiTimer invalidate];
    [readTimer invalidate];
}

- (void) handleRSSIReading
{
    if(self.rssiLevel == 0) {
        self.rssiLevel = [[self.peripheral RSSI] floatValue];
        if (self.rssiLevel > self.rssiThreshold) 
        {
            [self setState:PROXIMITY_TAG_STATE_CLOSE];
        }
        else 
        {
            [self setState:PROXIMITY_TAG_STATE_REMOTE];
        }
    }
    
    float requiredRSSIChange = (float)(0.15 * ABS(self.rssiThreshold));
    NSLog(@"RSSI: %f, change: %f, limit: %f, current location: %@", self.rssiLevel, requiredRSSIChange, self.rssiThreshold, self.lastSeenLocation);
    
    if ((self.rssiLevel < (self.rssiThreshold - requiredRSSIChange)) && 
        (self.state != PROXIMITY_TAG_STATE_REMOTE))
    {
        if(self.state == PROXIMITY_TAG_STATE_REMOTING)
        {
            [self setState:PROXIMITY_TAG_STATE_REMOTE];
            [self findTag:PROXIMITY_TAG_ALERT_LEVEL_HIGH];
        } 
        else if (self.state != PROXIMITY_TAG_STATE_REMOTING)
        {
            [self setState:PROXIMITY_TAG_STATE_REMOTING];
        } 
        else 
        {
            [self setState:PROXIMITY_TAG_STATE_CLOSE];
        }
    } 
    else if ((self.rssiLevel > (self.rssiThreshold + requiredRSSIChange)) &&
             (self.state != PROXIMITY_TAG_STATE_CLOSE))
    {
        if (self.state == PROXIMITY_TAG_STATE_CLOSING)
        {
            [self setState:PROXIMITY_TAG_STATE_CLOSE];
            [self findTag:PROXIMITY_TAG_ALERT_LEVEL_NONE];
        }
        else if (self.state != PROXIMITY_TAG_STATE_CLOSING)
        {
            [self setState:PROXIMITY_TAG_STATE_CLOSING];
        } 
        else 
        {
            [self setState:PROXIMITY_TAG_STATE_REMOTE];
        }
    }
    [self.delegate didUpdateData:self];
}

- (void) startLocationMonitoringIfEnabled
{
    if (self.locationTrackingIsEnabled && self.isConnected)
    {
        [self startLocationMonitoring];
    }
}

- (void) startLocationMonitoring
{
    [[TagLocationManager sharedInstance] startMonitoringForTag:self];
}

- (void) stopLocationMonitoring
{
    self.lastSeenLocation = nil;
    [[TagLocationManager sharedInstance] stopMonitoringForTag:self];
}

- (void) storeLocationIfEnabled
{
    if (self.locationTrackingIsEnabled)
    {
        self.lastSeenLocation = [[TagLocationManager sharedInstance] lastLocation];
    }
}

- (void) readLinkLossAlert
{
    [_peripheral readValueForCharacteristic:linkLossAlertLevelCharacteristic];
}

- (void) peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error 
{
    self.rssiLevel = [[peripheral RSSI] floatValue];
    NSLog(@"%@ did update RSSI: %f", self.name, self.rssiLevel);
    if (self.rangeMonitoringIsEnabled && self.isBonded)
    {
        [self handleRSSIReading];
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"Did discover services on %@", [peripheral name]);
    for(CBService *s in [peripheral services]) {
        
        NSLog(@"service UUID: %@", s.UUID.UUIDString);
        if([[s UUID] isEqual:ProximityTag.findMeServiceUUID])
            immediateAlertService = s;
        
        if([[s UUID] isEqual:ProximityTag.linkLossServiceUUID]) 
            linkLossService = s;
        
        if([[s UUID] isEqual:ProximityTag.batteryServiceUUID])
            batteryService = s;
            
        if([[s UUID] isEqual:ProximityTag.romiboServiceUUID])
            self.romiboService = s;
        
        [peripheral discoverCharacteristics:nil forService:s];  // Look for ALL characteristics.
//        [peripheral discoverCharacteristics:[NSArray arrayWithObject:ProximityTag.alertLevelCharacteristicUUID] forService:s];
    }
}


/****
 typedef enum {
 CBCharacteristicPropertyBroadcast = 0x01,
 CBCharacteristicPropertyRead = 0x02,
 CBCharacteristicPropertyWriteWithoutResponse = 0x04,
 CBCharacteristicPropertyWrite = 0x08,
 CBCharacteristicPropertyNotify = 0x10,
 CBCharacteristicPropertyIndicate = 0x20,
 CBCharacteristicPropertyAuthenticatedSignedWrites = 0x40,
 CBCharacteristicPropertyExtendedProperties = 0x80,
 CBCharacteristicPropertyNotifyEncryptionRequired = 0x100,
 CBCharacteristicPropertyIndicateEncryptionRequired = 0x200,
 } CBCharacteristicProperties;

****/


- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"Did discover characteristics for service %@ on peripheral %@", service, peripheral);
    NSLog(@"characteristics num: %lu array: %@", (unsigned long)service.characteristics.count, [service characteristics]);
    for(CBCharacteristic *c in [service characteristics]) 
    {
        NSLog(@"  in loop, characteristic c: %@", c);
        CBUUID * characteristic_UUID = c.UUID;
        
        NSLog(@"   characteristic UUID: %@", characteristic_UUID);
        
        CBCharacteristicProperties properties = c.properties;
        
        NSMutableString * propertiesStr = [NSMutableString stringWithString:@"Properties "];
        
        //  TODO: For DRY's sake, replace all the ifs below with reference to this dictionary,
        // NSMutableString *propertiesStr = @"Properties ";
        // NSDictionary *propertiesStrForCharacteristicProperty = @{
        //     NSV(CBCharacteristicPropertyBroadcast): @" - Broadcast",
        //     NSV(CBCharacteristicPropertyRead): @" - Read",
        //     NSV(CBCharacteristicPropertyWriteWithoutResponse): @" - Write without response",
        //     NSV(CBCharacteristicPropertyWrite): @" - Write",
        //     NSV(CBCharacteristicPropertyNotify): @" - Notify",
        //     NSV(CBCharacteristicPropertyIndicate): @" - Indicate",
        //     NSV(CBCharacteristicPropertyAuthenticatedSignedWrites): @" - Authenticated Signed Writes",
        //     NSV(CBCharacteristicPropertyExtendedProperties): @" - Extended Properties",
        //     NSV(CBCharacteristicPropertyNotifyEncryptionRequired): @" - Notify Encryption Required",
        //     NSV(CBCharacteristicPropertyIndicateEncryptionRequired): @" - Indicate Encryption Required",
        // };
        // int anInt =0;
        // for (NSValue *key in propertiesStrForCharacteristicProperty){
        //     NSString *propStr = propertiesStrForCharacteristicProperty[key];
        //     if (properties | [key getValue:(void *)&anInt]){
        //         [propertiesStr appendString:propStr];
        //     }
        // }
        // FIXME: test that this behavior ( if (properties & prop)  )
        // behvaes identically to previous behavior ( if (properties | prop == prop))
        // -ETJ 21 Aug 2014
        if (properties & CBCharacteristicPropertyBroadcast)                  [propertiesStr appendString:@" - Broadcast"];
        if (properties & CBCharacteristicPropertyRead)                       [propertiesStr appendString:@" - Read"];
        if (properties & CBCharacteristicPropertyWriteWithoutResponse)       [propertiesStr appendString:@" - Write without response"];
        if (properties & CBCharacteristicPropertyWrite)                      [propertiesStr appendString:@" - Write"];
        if (properties & CBCharacteristicPropertyNotify)                     [propertiesStr appendString:@" - Notify"];
        if (properties & CBCharacteristicPropertyIndicate)                   [propertiesStr appendString:@" - Indicate"];
        if (properties & CBCharacteristicPropertyExtendedProperties)         [propertiesStr appendString:@" - Extended Properties"];
        if (properties & CBCharacteristicPropertyAuthenticatedSignedWrites)  [propertiesStr appendString:@" - Authenticated Signed Writes"];
        if (properties & CBCharacteristicPropertyNotifyEncryptionRequired)   [propertiesStr appendString:@" - Notify Encryption Required"];
        if (properties & CBCharacteristicPropertyIndicateEncryptionRequired) [propertiesStr appendString:@" - Indicate Encryption Required"];
        NSLog(@"    %@  properties: 0x%x", propertiesStr, (int)properties);

        
        if([service isEqual:batteryService] &&
           [[c UUID] isEqual:ProximityTag.batteryLevelCharacteristicUUID])
        {
            batteryLevelCharacteristic = c;
            
            [peripheral setNotifyValue:YES forCharacteristic:batteryLevelCharacteristic];
            [peripheral readValueForCharacteristic:batteryLevelCharacteristic];
        }
        
        if ([service isEqual:self.romiboService]) {
            if ([c.UUID isEqual:ProximityTag.romiboWriteCharacteristicUUID]) {
                self.romibo_characteristic_write = c;
            }
            else if ([c.UUID isEqual:ProximityTag.romiboNotifyCharacteristicUUID]) {
                self.romibo_characteristic_notify = c;
            }
        }
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"Did update value for characteristic %@, new value: %@, error: %@", characteristic, [characteristic value], error);
    
    if ([characteristic isEqual:batteryLevelCharacteristic]) 
    {
        self.batteryLevel = *(NSUInteger*) [[batteryLevelCharacteristic value] bytes];
        [self.delegate didUpdateData:self];
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) 
    {
        NSLog(@"Failed to write value for characteristic %@, reason: %@", characteristic, error);
    }
    else 
    {   
        // NSLog(@"Did write value for characteristic %@, new value: %@", characteristic, [characteristic value]);
        
        // If we have successfully written something, bonding has been successful
        if (self.state == PROXIMITY_TAG_STATE_BONDING)
        {
            [self setState:PROXIMITY_TAG_STATE_BONDED];
        }
    }
}


- (NSString*) connectionImageNameBasedOnRSSI
{
    NSString *connectionImageName;
    if (!self.isConnected)
        connectionImageName = @"BLUETOOTH-ICON-fade.png";
    else 
        connectionImageName = @"BLUETOOTH-ICON-white.png";
    
    return connectionImageName;
}

- (BOOL) isConnected
{
    // If we are initialized, not disconnected and not link lost, we are connected
    return self.state != PROXIMITY_TAG_STATE_UNINITIALIZED &&
        self.state != PROXIMITY_TAG_STATE_DISCONNECTED &&
        self.state != PROXIMITY_TAG_STATE_LINK_LOST;
}

- (BOOL) isBonded
{
    // If we are connected and not bonding, we are bonded
    return self.isConnected && (self.state != PROXIMITY_TAG_STATE_BONDING);
}

@end
