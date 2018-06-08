//
//  CBPeripheral+Device.h
//  OAD Tools
//
//  Created by linkiing on 2018/6/7.
//  Copyright © 2018年 linkiing. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheral (Device)

@property (nonatomic, strong) NSString *deviceName;

@property (nonatomic, strong) NSString *deviceRssi;

@end
