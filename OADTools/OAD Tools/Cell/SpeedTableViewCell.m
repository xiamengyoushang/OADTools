//
//  SpeedTableViewCell.m
//  OAD Tools
//
//  Created by linkiing on 2018/6/7.
//  Copyright © 2018年 linkiing. All rights reserved.
//

#import "SpeedTableViewCell.h"

@interface SpeedTableViewCell()

@property (strong, nonatomic) IBOutlet UILabel *speedLabel;
@property (strong, nonatomic) IBOutlet UISlider *speedSlider;

@end
@implementation SpeedTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setSpeedIndex:6];
}
- (void)setSpeedIndex:(NSInteger)speedIndex{
    _speedIndex = speedIndex;
    _speedLabel.text = [NSString stringWithFormat:@"%ld",(long)speedIndex];
    _speedSlider.value = speedIndex;
}
#pragma mark - UIButton
- (IBAction)clickSubSpeedBtn:(UIButton *)sender {
    NSInteger index = _speedIndex;
    index--;
    if (index<6) {
        index = 6;
    }
    [self setSpeedIndex:index];
    if (_delegate&&[_delegate respondsToSelector:@selector(speedResponse:)]) {
        [_delegate speedResponse:index];
    }
}
- (IBAction)clickAddSpeedBtn:(UIButton *)sender {
    NSInteger index = _speedIndex;
    index++;
    if (index>60) {
        index = 60;
    }
    [self setSpeedIndex:index];
    if (_delegate&&[_delegate respondsToSelector:@selector(speedResponse:)]) {
        [_delegate speedResponse:index];
    }
}
#pragma mark - UISlider
- (IBAction)clickSpeedSlider:(UISlider *)sender {
    NSInteger index = (NSInteger)sender.value;
    [self setSpeedIndex:index];
    if (_delegate&&[_delegate respondsToSelector:@selector(speedResponse:)]) {
        [_delegate speedResponse:index];
    }
}


@end
