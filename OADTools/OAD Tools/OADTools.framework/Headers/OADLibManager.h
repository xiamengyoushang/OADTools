//
//  OADLibManager.h
//  OAD Tools
//
//  Created by linkiing on 2018/6/7.
//  Copyright © 2018年 linkiing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define GETRESPONSEDEVICEINFOMATION @"GETRESPONSEDEVICEINFOMATION"
#define GETRESPONSEDEVICEPROGRESS   @"GETRESPONSEDEVICEPROGRESS"

typedef enum{
    OAD_MODE_SPEED = 0,    //OAD极速模式
    OAD_MODE_SAFETY,       //OAD安全模式
}OAD_MODE;                 //OAD升级模式

typedef enum{
    OAD_Noremal = 0,       //正常升级
    OAD_IMAGEB_Destroy,    //需要破坏B镜像
    OAD_Firmware_Error,    //固件异常
    OAD_NotConnected,      //设备未连接
    OAD_Request_Failed,    //请求升级失败
}OAD_Response;

@interface OADLibManager : NSObject

//升级模式
@property (nonatomic, assign) OAD_MODE  oad_mode;
//待升级镜像的信息
@property (nonatomic, strong) NSMutableDictionary *localImageDictionary;

//初始化单例
+ (id)shareInstance;
//清除本地固件
+ (void)clearLocalFirmwareCache;
//激活设备通道
+ (void)activateDeviceCharacteristic:(CBPeripheral *)peripheral;
//接收蓝牙代理数据
+ (void)didUpdateOADDataForCharacteristic:(CBPeripheral *)peripheral andCharacteristic:(CBCharacteristic *)characteristic;
//破坏镜像
- (void)destroyImage_OADLib:(CBPeripheral *)peripheral;
//获取设备信息
- (void)initCheckDeviceInfomation:(CBPeripheral *)peripheral;
//获取服务器升级信息
- (void)initLocalLibraryAndCheckServer:(NSDictionary *)requestDictionary andProgress:(void (^)(BOOL isDownload))downloadProgress andVersionBlock:(void (^)(id version))versionCompletion;
//开启固件升级
- (OAD_Response)startDeviceOADFirmwareUpgrade:(CBPeripheral *)peripheral andSpeed:(NSInteger)updateSpeed;

@end
