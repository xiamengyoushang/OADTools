//
//  SpeedTableViewCell.h
//  OAD Tools
//
//  Created by linkiing on 2018/6/7.
//  Copyright © 2018年 linkiing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SpeedResponseDelegate <NSObject>

- (void)speedResponse:(NSInteger)speedIndex;

@end
@interface SpeedTableViewCell : UITableViewCell

@property (nonatomic, assign) NSInteger speedIndex;
@property (nonatomic, weak)id<SpeedResponseDelegate>delegate;

@end
