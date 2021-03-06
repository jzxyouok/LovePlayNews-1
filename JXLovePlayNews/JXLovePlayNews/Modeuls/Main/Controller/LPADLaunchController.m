//
//  LPADLaunchController.m
//  LovePlayNews
//
//  Created by tany on 16/9/1.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "LPADLaunchController.h"
#import "LPADLaunchView.h"
#import "UIImage+TYLaunchImage.h"
#import <YYWebImage.h>

@interface LPADLaunchController ()

@property (nonatomic, weak) LPADLaunchView *adLaunchView;

@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation LPADLaunchController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self addADLaunchView];
    
    [self loadData];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _adLaunchView.frame = self.view.bounds;
}

- (void)addADLaunchView
{
    LPADLaunchView *adLaunchView = [[LPADLaunchView alloc]init];
    adLaunchView.skipBtn.hidden = YES;
    adLaunchView.launchImageView.image = [UIImage ty_getLaunchImage];
    [adLaunchView.skipBtn addTarget:self action:@selector(skipADAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:adLaunchView];
    _adLaunchView = adLaunchView;
}


#pragma mark - 加载数据
- (void)loadData
{
    [self showADImageWithURL:[NSURL URLWithString:@"https://gss0.bdstatic.com/94o3dSag_xI4khGkpoWK1HF6hhy/baike/w%3D268%3Bg%3D0/sign=dd3eafa23e01213fcf3349da6cdc51ec/8b82b9014a90f60323a3073c3e12b31bb051edbe.jpg"]];
}


#pragma mark - private

- (void)showADImageWithURL:(NSURL *)url
{
    __weak typeof(self) weakSelf = self;
    [_adLaunchView.adImageView yy_setImageWithURL:url placeholder:nil options:YYWebImageOptionSetImageWithFadeAnimation completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
        // 启动倒计时
        [weakSelf scheduledGCDTimer];
    }];
}

- (void)showSkipBtnTitleTime:(int)timeLeave
{
    NSString *timeLeaveStr = [NSString stringWithFormat:@"跳过 %ds",timeLeave];
    [_adLaunchView.skipBtn setTitle:timeLeaveStr forState:UIControlStateNormal];
    
    _adLaunchView.skipBtn.hidden = NO;
}

- (void)scheduledGCDTimer
{
    [self cancleGCDTimer];
    __block int timeLeave = 3; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    __typeof (self) __weak weakSelf = self;
    dispatch_source_set_event_handler(_timer, ^{
        if(timeLeave <= 0){ //倒计时结束，关闭
            dispatch_source_cancel(weakSelf.timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //关闭界面
                [weakSelf dismissController];
            });
        }else{
            int curTimeLeave = timeLeave;
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面
                [weakSelf showSkipBtnTitleTime:curTimeLeave];
                
            });
            --timeLeave;
        }
    });
    dispatch_resume(_timer);
}

- (void)cancleGCDTimer
{
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

#pragma mark - action

- (void)skipADAction
{
    [self dismissController];
}

- (void)dismissController
{
    
    [self cancleGCDTimer];
    
    [UIView animateWithDuration:0.6 delay:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.view.transform = CGAffineTransformMakeScale(1.1, 1.1);
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self cancleGCDTimer];
}

@end
