//
//  Constant.h
//  OAD Tools
//
//  Created by linkiing on 2018/6/7.
//  Copyright © 2018年 linkiing. All rights reserved.
//

#ifndef Constant_h
#define Constant_h

#import "Bluemanager.h"
#import "WKProgressHUD.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define DEVICE_ISIPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define SYSTEM_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define kDevice_Is_iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#endif /* Constant_h */
