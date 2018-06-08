//
//  OADView.h
//  Oad Library
//
//  Created by linkiing on 16/7/14.
//  Copyright © 2016年 linkiing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressView : UIView

@property (assign, nonatomic)float width;
@property (assign, nonatomic)float percent;
@property (strong, nonatomic)UIColor *centerColor;
@property (strong, nonatomic)UIColor *arcBackColor;
@property (strong, nonatomic)UIColor *arcFinishColor;
@property (strong, nonatomic)UIColor *arcUnfinishColor;

@end
