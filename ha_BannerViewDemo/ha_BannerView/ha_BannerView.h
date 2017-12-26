//
//  ha_BannerView.h
//  Objective-C Project
//
//  Created by hahand on 2017/12/20.
//  Copyright © 2017年 hahand. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ha_BannerViewPage.h"

//#define ha_bannerview_debug_mode 去除注释开启测试模式

typedef NS_ENUM(NSUInteger, ha_BannerViewScrollDirection) {
    ha_BannerViewScrollDirectionVertical = 0,
    ha_BannerViewScrollDirectionHorizontal = 1,
};

@class ha_BannerView;

@protocol ha_BannerViewDelegate <NSObject>

@required
- (NSUInteger)ha_numbersOfPagesInBannerView:(ha_BannerView *)bannerView;

@optional
//Image
- (UIImage *)ha_bannerView:(ha_BannerView *)bannerView localImageForPageAtIndex:(NSUInteger)index;
- (NSURL *)ha_bannerView:(ha_BannerView *)bannerView remoteImageURLForPageAtIndex:(NSUInteger)index;
//Text
- (NSString *)ha_bannerView:(ha_BannerView *)bannerView textForPageAtIndex:(NSUInteger)index;
//WebView
- (NSURL *)ha_bannerView:(ha_BannerView *)bannerView requestURLForPageAtIndex:(NSUInteger)index;
- (NSString *)ha_bannerView:(ha_BannerView *)bannerView htmlStringForPageAtIndex:(NSUInteger)index;
//Event
- (void)ha_bannerView:(ha_BannerView *)bannerView pageIndexDidChanged:(NSUInteger)index;
- (void)ha_bannerViewPageDidSelected:(ha_BannerView *)bannerView atIndex:(NSUInteger)index;

@end

@interface ha_BannerView : UIView

/** pageBlock 自定义page的回调，如果为 nil 则 默认框架创建 */
@property (nonatomic, copy) ha_BannerViewPage *(^pageBlock)(void);

/** 滚动方向，默认为 纵向 */
@property (nonatomic, assign) ha_BannerViewScrollDirection direction;

/** 是否允许循环，默认为 NO */
@property (nonatomic, assign) BOOL cycleScrollEnabled;
/** 是否自动循环，默认为 NO。如果设置为 YES 将打开 cycleScrollEnabled */
@property (nonatomic, assign) BOOL autoCycleScroll;
/** 自动循环滚动方向，默认为 NO，即 左->右 ，上->下 */
@property (nonatomic, assign) BOOL ha_autoCycleDirectionReversed;
/** 循环间隔 */
@property (nonatomic, assign) NSTimeInterval durationOfCycle;

@property (nonatomic, weak) id<ha_BannerViewDelegate>delegate;

/** pageBlock 用于初始化page实例 */
+ (ha_BannerView *)bannerWithDirection:(ha_BannerViewScrollDirection)direction andPage:(ha_BannerViewPage *(^)(void))pageBlock;

/** 必须手动调用才能生效 */
- (void)setUp;

/** 更新数据源, 切换 网络图片 和 网页 可能会有bug */
- (void)reloadData;


@end
