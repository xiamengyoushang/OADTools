//
//  Bluemanager.h
//  OAD Tools
//
//  Created by linkiing on 2018/6/7.
//  Copyright © 2018年 linkiing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBPeripheral+Device.h"
#import <OADTools/OADTools.h>

#define OADSETTINGINFOMATION @"OADSETTINGINFOMATION"
#define DIDDISCOVERSERVICES  @"DIDDISCOVERSERVICES"

@interface Bluemanager : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>

//固件升级所需的URL
@property (nonatomic, strong) NSString *requestOADUrl;
//固件极速升级的速度
@property (nonatomic, assign) NSInteger speedOADIndex;
@property (nonatomic, assign) NSInteger lastrefreshcount;

@property (nonatomic, strong) CBCentralManager *centerManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) NSMutableArray *peripherals;

+ (id)shareInstance;
- (void)scanToBluetooth;
- (void)stopscanBluetooth;
- (void)connectToBluetooth;
- (void)cancelToBluetooth;
- (void)saveOADSettingInfomation;

@end
