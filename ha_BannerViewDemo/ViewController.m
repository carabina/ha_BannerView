//
//  ViewController.m
//  ha_BannerView
//
//  Created by hahand on 2017/12/26.
//  Copyright © 2017年 hahand. All rights reserved.
//

#import "ViewController.h"
#import "ha_BannerView.h"
#import "CustomPage.h"

@interface ViewController ()<ha_BannerViewDelegate>

@property (nonatomic, strong) IBOutlet ha_BannerView *bannerV;
@property (nonatomic, strong) IBOutlet UIPageControl *pageCtrl;


@property (nonatomic, copy) NSArray *images;
@property (nonatomic, copy) NSArray *strings;
@property (nonatomic, copy) NSArray *strings2;
@property (nonatomic, copy) NSArray *urls;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.strings = @[@"Page0",@"Page1",@"Page2",@"Page3",@"Page4",@"Page5"];
    self.strings2 = @[@"Baidu",@"Sohu",@"360",@"163",@"BiliBili"];
    
    self.urls = @[@"http://www.baidu.com",
                  @"http://www.sohu.com",
                  @"http://www.360.com",
                  @"http://www.163.com",
                  @"http://www.bilibili.com"];
#define _IM(XX) [UIImage imageNamed:XX]
    self.images =
  @[_IM(@"box1_91*91"),
    _IM(@"women1_91*91"),
    _IM(@"lion1_91*91"),
    _IM(@"light1_91*91"),
    _IM(@"tree1_91*91")];
    
    //********************************
    //TODO: 代码创建 初始化
//    self.bannerV = [ha_BannerView bannerWithDirection:ha_BannerViewScrollDirectionVertical andPage:^ha_BannerViewPage *() {
//        return [ha_BannerViewPage pageWithType:ha_BannerViewTypeLocalImage];
//    }];
//    self.bannerV.frame = CGRectMake(10, 20, 300, 50);
//    [self.view addSubview:self.bannerV];
    //********************************
    
    self.bannerV.delegate = self;
    self.bannerV.direction = ha_BannerViewScrollDirectionHorizontal;
    self.bannerV.pageBlock = ^ha_BannerViewPage *{
        return [CustomPage page];
    };
    
    //自动循环
    self.bannerV.autoCycleScroll = YES;
    //自动循环方向
    self.bannerV.ha_autoCycleDirectionReversed = YES;
    //自动循环间隔
    self.bannerV.durationOfCycle = 3.0;
    //是否开启循环
    self.bannerV.cycleScrollEnabled = YES;
    
    [self.bannerV setUp];
}

- (IBAction)reloadDataSouce: (UIButton *)sender {
  
}

#pragma mark - ha_BannerViewDelegate

- (NSUInteger)ha_numbersOfPagesInBannerView:(ha_BannerView *)bannerView {
    self.pageCtrl.numberOfPages = 5;
    return self.pageCtrl.numberOfPages;
}

- (UIImage *)ha_bannerView:(ha_BannerView *)bannerView localImageForPageAtIndex:(NSUInteger)index {
    return self.images[index];
}

static BOOL changeText = NO;
- (NSString *)ha_bannerView:(ha_BannerView *)bannerView textForPageAtIndex:(NSUInteger)index {
    return changeText ? self.strings[index] : self.strings2[index];
}

- (NSURL *)ha_bannerView:(ha_BannerView *)bannerView requestURLForPageAtIndex:(NSUInteger)index {
    return  [NSURL URLWithString:self.urls[index]];
}

//- (NSString *)ha_bannerView:(ha_BannerView *)bannerView htmlStringForPageAtIndex:(NSUInteger)index {
//
//}

- (void)ha_bannerView:(ha_BannerView *)bannerView pageIndexDidChanged:(NSUInteger)index {
    NSLog(@"IndexChanged -> %ld",(long)index);
    self.pageCtrl.currentPage = index;
}

- (void)ha_bannerViewPageDidSelected:(ha_BannerView *)bannerView atIndex:(NSUInteger)index {
    NSLog(@"PageSelected -> %ld",(long)index);
}


@end
