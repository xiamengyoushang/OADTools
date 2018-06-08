//
//  SettingViewController.m
//  OAD Tools
//
//  Created by linkiing on 2018/6/7.
//  Copyright © 2018年 linkiing. All rights reserved.
//

#import "SettingViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CameraViewController.h"
#import "SpeedViewController.h"
#import "SettingTableViewCell.h"
#import "Constant.h"

@interface SettingViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) Bluemanager *bluemanager;
@property (strong, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation SettingViewController

#pragma mark - Initialize
- (void)InitializeData{
    self.title = @"设置";
    _bluemanager = [Bluemanager shareInstance];
    UINib *nib = [UINib nibWithNibName:@"SettingTableViewCell" bundle:[NSBundle mainBundle]];
    [_tableview registerNib:nib forCellReuseIdentifier:@"cell"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self InitializeData];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_bluemanager.requestOADUrl.length) {
        [_bluemanager saveOADSettingInfomation];
    }
    [_tableview reloadData];
}
#pragma mark -UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 32;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerview = [UIView new];
    headerview.backgroundColor = [UIColor clearColor];
    UIImageView *lineImageview = [[UIImageView alloc] init];
    lineImageview.frame = CGRectMake(0, 31, SCREEN_WIDTH, 1);
    lineImageview.image = [UIImage imageNamed:@"setcellline"];
    [headerview addSubview:lineImageview];
    return headerview;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cell";
    SettingTableViewCell *cell = [_tableview dequeueReusableCellWithIdentifier:cellId];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        cell.setcelltitle.text = @"获取固件URL";
        if (_bluemanager.requestOADUrl.length) {
            cell.setcellNewInfo.hidden = NO;
        } else {
            cell.setcellNewInfo.hidden = YES;
        }
    } else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            cell.setcelltitle.text = @"调整升级速度";
            if (_bluemanager.speedOADIndex != 10) {
                cell.setcellNewInfo.hidden = NO;
            } else {
                cell.setcellNewInfo.hidden = YES;
            }
        } else if (indexPath.row == 1){
            cell.setcelltitle.text = @"清除本地固件";
            cell.setcellNewInfo.hidden = YES;
        } else if (indexPath.row == 2){
            cell.setcelltitle.text = @"关于软件";
            cell.setcellNewInfo.hidden = YES;
        }
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (_bluemanager.requestOADUrl.length) {
            [self alertInfomation:indexPath.section andRow:indexPath.row andTitle:@"重新获取固件URL" andMessage:[NSString stringWithFormat:@"已保存的URL: %@",_bluemanager.requestOADUrl] andCancel:@"取消" andConfirm:@"重新获取"];
        } else {
            [self alertInfomation:indexPath.section andRow:indexPath.row andTitle:@"获取固件URL" andMessage:nil andCancel:@"取消" andConfirm:@"确认"];
        }
    } else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            SpeedViewController *speedctl = [[SpeedViewController alloc] init];
            [self.navigationController pushViewController:speedctl animated:YES];
        } else if (indexPath.row == 1){
            [self alertInfomation:indexPath.section andRow:indexPath.row andTitle:@"清除本地固件" andMessage:nil andCancel:@"取消" andConfirm:@"确认"];
        } else if (indexPath.row == 2){
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
            NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
            [self alertInfomation:indexPath.section andRow:indexPath.row andTitle:[NSString stringWithFormat:@"%@: V%@",app_Name,app_Version] andMessage:nil andCancel:@"取消" andConfirm:@"确认"];
        }
    }
}
- (void)alertInfomation:(NSInteger)sectionIndex andRow:(NSInteger)rowIndex andTitle:(NSString *)title andMessage:(NSString *)message andCancel:(NSString*)cancelTitle andConfirm:(NSString *)confirmTitle{
    UIAlertController *alertctl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertctl addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}]];
    [alertctl addAction:[UIAlertAction actionWithTitle:confirmTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (sectionIndex == 0) {
            [self enterCameraAndScanCode];
        } else if (sectionIndex == 1){
            if (rowIndex == 1){
                [OADLibManager clearLocalFirmwareCache];
            }
        }
    }]];
    [self presentViewController:alertctl animated:YES completion:nil];
}
- (void)enterCameraAndScanCode{
    CameraViewController *cameractl = [[CameraViewController alloc] init];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (status) {
            case AVAuthorizationStatusNotDetermined: {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if (granted) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [self.navigationController pushViewController:cameractl animated:YES];
                        });
                    }
                }];
                break;
            }
            case AVAuthorizationStatusAuthorized: {
                [self.navigationController pushViewController:cameractl animated:YES];
                break;
            }
            case AVAuthorizationStatusDenied: {
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"请打开相机权限" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action){}];
                [alertC addAction:alertA];
                [self presentViewController:alertC animated:YES completion:nil];
                break;
            }
            default:
                break;
        }
        return;
    }
}

@end
