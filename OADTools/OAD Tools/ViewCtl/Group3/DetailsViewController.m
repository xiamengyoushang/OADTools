//
//  DetailsViewController.m
//  OAD Tools
//
//  Created by linkiing on 2018/6/7.
//  Copyright © 2018年 linkiing. All rights reserved.
//

#import "DetailsViewController.h"
#import "Constant.h"

@interface DetailsViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) Bluemanager *bluemanager;
@property (strong, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation DetailsViewController

#pragma mark - Initialize
- (void)InitializeData{
    self.title = @"详细信息";
    _bluemanager = [Bluemanager shareInstance];
    _tableview.indicatorStyle = UIScrollViewIndicatorStyleWhite;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self InitializeData];
}
#pragma mark -UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 2){
        return 0.1;
    }
    return 10;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 2) {
        return 10;
    }
    return 0.1;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_detailsdictionary.count == 0){
        return 0;
    }
    if (section == 0){
        return 4;
    } else if (section ==1){
        return 1;
    }
    return [[_detailsdictionary objectForKey:@"new_features"] count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] ;
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
    if (indexPath.section == 0){
        if (indexPath.row == 0){
            cell.textLabel.text = _bluemanager.peripheral.deviceName;
        } else if (indexPath.row == 1){
            cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@",@"类型",[_detailsdictionary objectForKey:@"IC"]];
        } else if (indexPath.row == 2){
            cell.textLabel.text = [NSString stringWithFormat:@"%@ : v%@",@"版本",[_detailsdictionary objectForKey:@"version"]];
        } else if(indexPath.row == 3){
            cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@",@"时间",[_detailsdictionary objectForKey:@"update_time"]];
        }
    } else if (indexPath.section == 1){
        cell.textLabel.text = @"日志 :";
    } else {
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.text = [NSString stringWithFormat:@"%@",[[[_detailsdictionary objectForKey:@"new_features"] objectAtIndex:indexPath.row] objectForKey:@"feature"]];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2){
        NSString *lenghString = [NSString stringWithFormat:@"%@",[[[_detailsdictionary objectForKey:@"new_features"] objectAtIndex:indexPath.row] objectForKey:@"feature"]];
        CGSize maxSize = CGSizeMake(SCREEN_WIDTH-30, MAXFLOAT);
        NSDictionary *attribute = @{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:17]};
        CGSize labelSize = [lenghString boundingRectWithSize:maxSize options:\
                            NSStringDrawingTruncatesLastVisibleLine |
                            NSStringDrawingUsesLineFragmentOrigin |
                            NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        return labelSize.height+12;
    }
    return 32;
}

@end
