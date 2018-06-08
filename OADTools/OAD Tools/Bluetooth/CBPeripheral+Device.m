//
//  CBPeripheral+Device.m
//  OAD Tools
//
//  Created by linkiing on 2018/6/7.
//  Copyright © 2018年 linkiing. All rights reserved.
//

#import "CBPeripheral+Device.h"
#import <objc/runtime.h>

@implementation CBPeripheral (Device)

- (void)setDeviceName:(NSString *)deviceName{
    SEL key = @selector(deviceName);
    objc_setAssociatedObject(self, key, deviceName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString *)deviceName{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDeviceRssi:(NSString *)deviceRssi{
    SEL key = @selector(deviceRssi);
    objc_setAssociatedObject(self, key, deviceRssi, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString *)deviceRssi{
    return objc_getAssociatedObject(self, _cmd);
}

@end
