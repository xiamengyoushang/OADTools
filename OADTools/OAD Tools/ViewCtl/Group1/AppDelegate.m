//
//  AppDelegate.m
//  OAD Tools
//
//  Created by linkiing on 2018/6/7.
//  Copyright © 2018年 linkiing. All rights reserved.
//

#import "AppDelegate.h"
#import "Bluemanager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    Bluemanager *bluemanager = [Bluemanager shareInstance];
    NSArray *settingArray = [[NSUserDefaults standardUserDefaults] objectForKey:OADSETTINGINFOMATION];
    if (settingArray.count == 2) {
        bluemanager.requestOADUrl = settingArray.firstObject;
        bluemanager.speedOADIndex = [settingArray.lastObject integerValue];
    }
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:255.0/255.0 green:102.0/255.0 blue:0.0/255.0 alpha:1], NSForegroundColorAttributeName, [UIFont fontWithName:@"Helvetica-Bold" size:20],NSFontAttributeName,nil]];
    return YES;
}


@end
