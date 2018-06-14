//
//  Bluemanager.m
//  OAD Tools
//
//  Created by linkiing on 2018/6/7.
//  Copyright © 2018年 linkiing. All rights reserved.
//

#import "Bluemanager.h"
#import <AudioToolbox/AudioToolbox.h>

static Bluemanager *bluemanager;
@implementation Bluemanager{
    dispatch_queue_t bluetooth_queue;
}
+ (id)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (bluemanager == nil) {
            bluemanager = [[Bluemanager alloc] init];
        }
    });
    return bluemanager;
}
- (id)init{
    if (self = [super init]){
        bluetooth_queue = dispatch_queue_create("BLUETOOTH", 0);
        [self searchingDevice];
    }
    return self;
}
- (void)searchingDevice{
    if(_centerManager){
        _centerManager=nil;
        _peripherals=nil;
    }
    _lastrefreshcount = 0;
    _speedOADIndex = 10;
    _requestOADUrl = nil;
    _peripherals=[[NSMutableArray alloc] initWithCapacity:0];
    _centerManager=[[CBCentralManager alloc] initWithDelegate:self queue:bluetooth_queue options:nil];
}
- (void)scanToBluetooth{
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    [_centerManager scanForPeripheralsWithServices:nil options:options];
}
- (void)stopscanBluetooth{
    [_centerManager stopScan];
}
- (void)connectToBluetooth{
    if (_peripheral){
        [_centerManager connectPeripheral:_peripheral options:nil];
    }
}
- (void)cancelToBluetooth{
    if (_peripheral){
        [_centerManager cancelPeripheralConnection:_peripheral];
    }
}
#pragma mark -CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state){
        case CBCentralManagerStatePoweredOn:
            [self scanToBluetooth];
            break;
        case CBCentralManagerStatePoweredOff:
            break;
        default:
            break;
    }
}
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    if ([advertisementData valueForKey:@"kCBAdvDataLocalName"]){
        if (RSSI.integerValue>-90 && RSSI.integerValue<0){
            peripheral.deviceName = [advertisementData valueForKey:@"kCBAdvDataLocalName"];
            peripheral.deviceRssi = [NSString stringWithFormat:@"%ld",(long)RSSI.integerValue];
            if (![_peripherals containsObject:peripheral]){
                [_peripherals addObject:peripheral];
            }
        }
    }
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    peripheral.delegate=self;
    [peripheral discoverServices:nil];
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    [self scanToBluetooth];
}
#pragma mark - CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    for(CBService *s in peripheral.services){
        [peripheral discoverCharacteristics:nil forService:s];
    }
    [OADLibManager activateDeviceCharacteristic:peripheral];
    [[NSNotificationCenter defaultCenter] postNotificationName:DIDDISCOVERSERVICES object:nil];
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    [OADLibManager didUpdateOADDataForCharacteristic:peripheral andCharacteristic:characteristic];
}
- (void)saveOADSettingInfomation{
    NSArray *settingArray = [NSArray arrayWithObjects:_requestOADUrl,[NSString stringWithFormat:@"%ld",(long)_speedOADIndex], nil];
    [[NSUserDefaults standardUserDefaults] setObject:settingArray forKey:OADSETTINGINFOMATION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
