//
//  ViewController.m
//  OAD Tools
//
//  Created by linkiing on 2018/6/7.
//  Copyright © 2018年 linkiing. All rights reserved.
//

#import "ViewController.h"
#import "SettingViewController.h"
#import "OADViewController.h"
#import "BlueTableViewCell.h"
#import "Constant.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSTimer *scanTimer;
@property (nonatomic, strong) Bluemanager *bluemanager;
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic, strong) NSMutableDictionary *requrstdictionary;

@end

@implementation ViewController

#pragma mark - Initialize
- (void)InitializeData{
    self.title = @"蓝牙设备";
    _bluemanager = [Bluemanager shareInstance];
    _requrstdictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbg"] forBarMetrics:UIBarMetricsDefault];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(clickSettingItem:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self action:@selector(clickRefreshListItem:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    UINib *nib = [UINib nibWithNibName:@"BlueTableViewCell" bundle:[NSBundle mainBundle]];
    [_tableview registerNib:nib forCellReuseIdentifier:@"cell"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationSevrvices) name:DIDDISCOVERSERVICES object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self InitializeData];
    NSLog(@"唯一识别符: %@",[[NSBundle mainBundle] bundleIdentifier]);
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getOADWebRequestJsonData];
    [self cancelBluetoothAndClearDeviceCache];
    _scanTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(scanTimeRun) userInfo:nil repeats:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_scanTimer invalidate];
    _scanTimer = nil;
}
- (void)getOADWebRequestJsonData{
    [_requrstdictionary removeAllObjects];
    if (_bluemanager.requestOADUrl.length) {
        NSURL *url = [[NSURL alloc] initWithString:_bluemanager.requestOADUrl];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        request.timeoutInterval = 2.0;
        request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data != nil){
                id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                if ([[result valueForKey:@"appurl"] length]) {
                    [self->_requrstdictionary setDictionary:result];
                }
            }
        }];
        [dataTask resume];
    }
}
- (void)cancelBluetoothAndClearDeviceCache{
    [_bluemanager cancelToBluetooth];
    [_bluemanager.peripherals removeAllObjects];
    [_tableview reloadData];
    [_bluemanager scanToBluetooth];
}
#pragma mark -NSTimer
- (void)scanTimeRun{
    if (_bluemanager.lastrefreshcount != _bluemanager.peripherals.count) {
        _bluemanager.lastrefreshcount = _bluemanager.peripherals.count;
        [_tableview reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else{
        [_tableview reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
}
#pragma mark - UIBarButtonItem
- (void)clickSettingItem:(UIBarButtonItem *)item{
    SettingViewController *settingctl = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:settingctl animated:YES];
}
- (void)clickRefreshListItem:(UIBarButtonItem *)item{
    [self cancelBluetoothAndClearDeviceCache];
}
#pragma mark - NSNotificationCenter
- (void)notificationSevrvices{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_bluemanager.peripheral.state == 2) {
            [WKProgressHUD dismissAll:YES];
            OADViewController *oadctl = [[OADViewController alloc] init];
            oadctl.requrstdictionary = self->_requrstdictionary;
            [self.navigationController pushViewController:oadctl animated:YES];
        }
    });
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
    return _bluemanager.peripherals.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cell";
    BlueTableViewCell *cell = [_tableview dequeueReusableCellWithIdentifier:cellId];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CBPeripheral *peripheral = [_bluemanager.peripherals objectAtIndex:indexPath.row];
    cell.devicelistLabel.text = peripheral.deviceName;
    NSInteger deviceRssi = peripheral.deviceRssi.integerValue;
    if (deviceRssi>-40&&deviceRssi<=0) {
        cell.signalImageview.image = [UIImage imageNamed:@"signal_5"];
    }else if (deviceRssi>-50&&deviceRssi<=-40){
        cell.signalImageview.image = [UIImage imageNamed:@"signal_4"];
    }else if (deviceRssi>-60&&deviceRssi<=-50){
        cell.signalImageview.image = [UIImage imageNamed:@"signal_3"];
    }else if (deviceRssi>-70&&deviceRssi<=-60){
        cell.signalImageview.image = [UIImage imageNamed:@"signal_2"];
    }else if (deviceRssi>-80&&deviceRssi<=-70){
        cell.signalImageview.image = [UIImage imageNamed:@"signal_1"];
    }else{
        cell.signalImageview.image = [UIImage imageNamed:@"signal_0"];
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_bluemanager.requestOADUrl.length) {
        if (_requrstdictionary.count) {
            _bluemanager.peripheral = [_bluemanager.peripherals objectAtIndex:indexPath.row];
            [_bluemanager connectToBluetooth];
            [WKProgressHUD showInView:self.navigationController.view withText:nil animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [WKProgressHUD dismissAll:YES];
            });
        } else {
            [self getOADWebRequestJsonData];
            [WKProgressHUD popMessage:@"未检测到网络数据" inView:self.navigationController.view duration:1.0 animated:YES];
        }
    } else {
        [WKProgressHUD popMessage:@"未检测到固件URL" inView:self.navigationController.view duration:1.0 animated:YES];
    }
}

@end
