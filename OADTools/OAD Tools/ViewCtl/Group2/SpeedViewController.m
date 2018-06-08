//
//  SpeedViewController.m
//  OAD Tools
//
//  Created by linkiing on 2018/6/7.
//  Copyright © 2018年 linkiing. All rights reserved.
//

#import "SpeedViewController.h"
#import "SpeedTableViewCell.h"
#import "Constant.h"

@interface SpeedViewController ()<UITableViewDataSource,UITableViewDelegate,SpeedResponseDelegate>

@property (nonatomic, strong) Bluemanager *bluemanager;
@property (strong, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation SpeedViewController

#pragma mark - Initialize
- (void)InitializeData{
    self.title = @"设置";
    _bluemanager = [Bluemanager shareInstance];
    UINib *nib = [UINib nibWithNibName:@"SpeedTableViewCell" bundle:[NSBundle mainBundle]];
    [_tableview registerNib:nib forCellReuseIdentifier:@"cell"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self InitializeData];
}
#pragma mark - SpeedResponseDelegate
- (void)speedResponse:(NSInteger)speedIndex{
    _bluemanager.speedOADIndex = speedIndex;
}
#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 32;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cell";
    SpeedTableViewCell *cell = [_tableview dequeueReusableCellWithIdentifier:cellId];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.speedIndex = _bluemanager.speedOADIndex;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

@end
