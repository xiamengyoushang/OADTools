//
//  OADLibManager.h
//  OAD Tools
//
//  Created by linkiing on 2018/6/7.
//  Copyright © 2018年 linkiing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

//获取设备信息
#define GETRESPONSEDEVICEINFOMATION @"GETRESPONSEDEVICEINFOMATION"
//获取升级进度和响应
#define GETRESPONSEDEVICEPROGRESS   @"GETRESPONSEDEVICEPROGRESS"

typedef enum{
    OAD_MODE_SPEED = 0,    //OAD极速模式
    OAD_MODE_SAFETY,       //OAD安全模式
}OAD_MODE;

typedef enum{
    OAD_Noremal = 0,       //正常升级
    OAD_IMAGEB_Destroy,    //需要破坏B镜像
    OAD_Firmware_Error,    //固件异常
    OAD_NotConnected,      //设备未连接
    OAD_Request_Failed,    //请求升级失败
    OAD_Latest_Version,    //已是最新版本
}OAD_Response;

@interface OADLibManager : NSObject

//升级模式
@property (nonatomic, assign) OAD_MODE  oad_mode;
//待升级镜像的信息
@property (nonatomic, strong) NSMutableDictionary *localImageDictionary;

/*!
 @method
 @abstract OAD管理类单例
 @discussion OAD管理类单例
 */
+ (id)shareInstance;

/*!
 @method
 @abstract 清除本地固件
 @discussion 清除本地缓存的Json和固件
 */
+ (void)clearLocalFirmwareCache;

/*!
 @method
 @abstract 激活设备通道
 @discussion 激活设备通道
 @param peripheral      蓝牙外设
 */
+ (void)activateDeviceCharacteristic:(CBPeripheral *)peripheral;

/*!
 @method
 @abstract 接收蓝牙代理数据
 @discussion 接收蓝牙代理数据
 @param peripheral      蓝牙外设
 @param characteristic  设备通道
 */
+ (void)didUpdateOADDataForCharacteristic:(CBPeripheral *)peripheral andCharacteristic:(CBCharacteristic *)characteristic;

/*!
 @method
 @abstract 破坏镜像
 @discussion 对2540、2541的B镜像进行破坏
 @param peripheral      蓝牙外设
 */
- (void)destroyImage_OADLib:(CBPeripheral *)peripheral;

/*!
 @method
 @abstract 获取设备信息
 @discussion 获取设备芯片类型、镜像、版本
 @param peripheral      蓝牙外设
 */
- (void)initCheckDeviceInfomation:(CBPeripheral *)peripheral;

/*!
 @method
 @abstract 初始化Library并获取服务器升级信息
 @discussion 校对本地及服务器升级信息并配置本地固件
 @param requestDictionary    服务器最新升级信息
 @param downloadProgress     固件下载进度Block
 @param versionCompletion    版本校对进度Block
 */
- (void)initLocalLibraryAndCheckServer:(NSDictionary *)requestDictionary andProgress:(void (^)(BOOL isDownload))downloadProgress andVersionBlock:(void (^)(id version))versionCompletion;

/*!
 @method
 @abstract 开启固件升级
 @discussion 该方法主要用于启动升级进程并设置一些必要的升级参数
 @param peripheral      蓝牙外设
 @param updateSpeed     升级速度
 @param isCheck         是否开启最新版本校对
 @result OAD_Response   返回请求响应
 */
- (OAD_Response)startDeviceOADFirmwareUpgrade:(CBPeripheral *)peripheral andSpeed:(NSInteger)updateSpeed andVersionCheck:(BOOL)isCheck;

@end
