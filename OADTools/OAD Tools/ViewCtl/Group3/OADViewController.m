//
//  OADViewController.m
//  OAD Tools
//
//  Created by linkiing on 2018/6/7.
//  Copyright © 2018年 linkiing. All rights reserved.
//

#import "OADViewController.h"
#import "DetailsViewController.h"
#import "ProgressView.h"
#import "Constant.h"

@interface OADViewController ()

@property (nonatomic, assign) BOOL isUpdating;

@property (nonatomic, strong) Bluemanager *bluemanager;
@property (nonatomic, strong) OADLibManager *oadLibmanager;

@property (strong, nonatomic) IBOutlet UILabel *deviceLabel;
@property (strong, nonatomic) IBOutlet UILabel *serverLabel;
@property (strong, nonatomic) IBOutlet UIButton *startUpdateBtn;
@property (strong, nonatomic) IBOutlet ProgressView *progressView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentctl;

@end

@implementation OADViewController

#pragma mark - Initialize
- (void)InitializeData{
    //UI相关
    _progressView.width = 2;
    _progressView.arcFinishColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1];
    _progressView.arcUnfinishColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1];
    _progressView.arcBackColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1];
    _progressView.centerColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1];
    _progressView.percent = 0.0;
    
    _segmentctl.layer.borderWidth = 1;
    _segmentctl.layer.borderColor = [UIColor whiteColor].CGColor;
    NSDictionary* selectedTextAttributes = @{
                                             NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:16],
                                             NSForegroundColorAttributeName: [UIColor blackColor]};
    [_segmentctl setTitleTextAttributes:selectedTextAttributes forState:UIControlStateSelected];
    NSDictionary* unselectedTextAttributes = @{
                                               NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:16],
                                               NSForegroundColorAttributeName: [UIColor whiteColor]};
    [_segmentctl setTitleTextAttributes:unselectedTextAttributes forState:UIControlStateNormal];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(clickBackItem:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    //配置相关
    _isUpdating = NO;
    _startUpdateBtn.enabled = NO;
    _bluemanager = [Bluemanager shareInstance];
    _oadLibmanager = [OADLibManager shareInstance];
    _oadLibmanager.oad_mode =  OAD_MODE_SPEED;
    //获取设备信息
    [_oadLibmanager initCheckDeviceInfomation:_bluemanager.peripheral];
    //获取升级信息
    [_oadLibmanager initLocalLibraryAndCheckServer:_requrstdictionary andProgress:^(BOOL isDownload) {
        [WKProgressHUD showInView:self.navigationController.view withText:nil animated:YES];
    } andVersionBlock:^(id version) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (version) {
                self->_serverLabel.text = [NSString stringWithFormat:@"%@: %@",@"最新服务器版本",version];
            } else {
                self->_serverLabel.text = [NSString stringWithFormat:@"%@",@"未获取到服务器版本"];
            }
            [WKProgressHUD dismissAll:YES];
        });
    }];
    if (_bluemanager.peripheral.state == 2) {
        self.title = @"已连接";
    } else {
        self.title = @"未连接";
    }
    [_bluemanager.peripheral addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
    //接收设备信息的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationDeviceInfo:) name:GETRESPONSEDEVICEINFOMATION object:nil];
    //接收升级进度的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationDeviceProgress:) name:GETRESPONSEDEVICEPROGRESS object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self InitializeData];
}
#pragma mark - UIButton
- (void)clickBackItem:(UIBarButtonItem *)item{
    if (_isUpdating == YES) {
        [self popViewControllerAndRefreshOADState:@"退出升级?" andType:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (IBAction)clickDetailsBtn:(UIButton *)sender {
    DetailsViewController *detailctl = [[DetailsViewController alloc] init];
    detailctl.detailsdictionary = _oadLibmanager.localImageDictionary;
    [self.navigationController pushViewController:detailctl animated:YES];
}
- (IBAction)clickStartOADBtn:(UIButton *)sender {
    if (_isUpdating == YES) {
        [self popViewControllerAndRefreshOADState:@"退出升级?" andType:YES];
    } else {
        OAD_Response response = [_oadLibmanager startDeviceOADFirmwareUpgrade:_bluemanager.peripheral andSpeed:_bluemanager.speedOADIndex andVersionCheck:NO];
        switch (response) {
            case OAD_Noremal:
                _isUpdating = YES;
                break;
            case OAD_IMAGEB_Destroy:
                [self destroyDeviceBIMAGE];
                break;
            case OAD_Firmware_Error:
                [self popViewControllerAndRefreshOADState:@"固件异常" andType:NO];
                break;
            case OAD_NotConnected:
                [self popViewControllerAndRefreshOADState:@"设备未连接" andType:NO];
                break;
            case OAD_Request_Failed:
                [self popViewControllerAndRefreshOADState:@"请求升级失败" andType:NO];
                break;
            case OAD_Latest_Version:
                [self popViewControllerAndRefreshOADState:@"已是最新版本" andType:NO];
                break;
        }
    }
}
#pragma mark - UISegmentedControl
- (IBAction)clickChooseUpdateMode:(UISegmentedControl *)sender {
    if (_isUpdating == NO){
        if (sender.selectedSegmentIndex == 0){
            _oadLibmanager.oad_mode = OAD_MODE_SPEED;
        } else {
            _oadLibmanager.oad_mode = OAD_MODE_SAFETY;
        }
    } else {
        sender.selectedSegmentIndex = 1-sender.selectedSegmentIndex;
    }
}
#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqual:@"state"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[change objectForKey:@"new"] integerValue] == 2){
                self.title = @"已连接";
            } else {
                self.title = @"未连接";
            }
        });
    }
}
#pragma mark - NSNotificationCenter
- (void)notificationDeviceInfo:(NSNotification *)notification{
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_startUpdateBtn.enabled = YES;
        NSString *deviceInfo=(NSString *)[notification object];
        self->_deviceLabel.text = [NSString stringWithFormat:@"设备信息: %@",deviceInfo];
    });
}
- (void)notificationDeviceProgress:(NSNotification *)notification{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *progressArray = (NSArray *)[notification object];
        NSInteger progress_state = [progressArray.firstObject integerValue];
        CGFloat progress_Index=[progressArray.lastObject floatValue];
        if (progress_state == 0) {
            self->_progressView.percent = progress_Index;
        } else if (progress_state == 1){
            [self popViewControllerAndRefreshOADState:@"升级成功" andType:NO];
        } else if (progress_state == 2){
            [self popViewControllerAndRefreshOADState:@"升级失败" andType:NO];
        } else if (progress_state == 3){
            [self popViewControllerAndRefreshOADState:@"升级异常" andType:NO];
        }
    });
}
- (void)destroyDeviceBIMAGE{
    UIAlertController *alertctl = [UIAlertController alertControllerWithTitle:@"破坏当前B镜像?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertctl addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}]];
    [alertctl addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self->_oadLibmanager destroyImage_OADLib:self->_bluemanager.peripheral];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self popViewControllerAndRefreshOADState:@"请重启蓝牙重新连接升级A镜像" andType:NO];
        });
    }]];
    [self presentViewController:alertctl animated:YES completion:nil];
}
- (void)popViewControllerAndRefreshOADState:(NSString *)titleMessage andType:(BOOL)isAddCancel{
    UIAlertController *alertctl = [UIAlertController alertControllerWithTitle:titleMessage message:nil preferredStyle:UIAlertControllerStyleAlert];
    if (isAddCancel) {
        [alertctl addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}]];
    }
    [alertctl addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self->_bluemanager cancelToBluetooth];
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:alertctl animated:YES completion:nil];
}
- (void)dealloc{
    [_bluemanager.peripheral removeObserver:self forKeyPath:@"state"];
}

@end
