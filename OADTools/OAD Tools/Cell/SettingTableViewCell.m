//
//  SettingTableViewCell.m
//  SNLights
//
//  Created by linkiing on 17/3/13.
//  Copyright © 2017年 linkiing. All rights reserved.
//

#import "SettingTableViewCell.h"

@implementation SettingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _setcellNewInfo.layer.cornerRadius = 4;
    _setcellNewInfo.layer.masksToBounds = YES;
}

@end
