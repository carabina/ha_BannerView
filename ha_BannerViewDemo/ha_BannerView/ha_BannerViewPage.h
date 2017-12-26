//
//  ha_BannerViewPage.h
//  Objective-C Project
//
//  Created by hahand on 2017/12/22.
//  Copyright © 2017年 hahand. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, ha_BannerViewType) {
    ha_BannerViewTypeLocalImage = 1 << 0,
    ha_BannerViewTypeRemoteImage = 1 << 1,
    ha_BannerViewTypeText = 1 << 2,
    ha_BannerViewTypeWebView = 1 << 3,
};

@interface ha_BannerViewPage : UIView

/** 【type】 NS_OPTIONS 支持叠加使用
 * @LocalImage for image
 * @Text 纯文字轮播，一般用于文字广播
 * @LocalImage|Text 图文同时显示，文字一般作为标题
 * @RemoteImage 请求网络图片，
 * @LocalImage|RemoteImage 【LocalImage】作为 【placeholder】先加载，然后再网络请求【RemoteImage】
 * @WebView 网页控件，如果两个代理方法都遵守了，则 url 方法的返回值将作为 html 方法的 baseUrl 进行调用
 */
@property (nonatomic, assign) ha_BannerViewType type;

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *textLabel;
@property (nonatomic, strong) IBOutlet UIWebView *webView;

+ (ha_BannerViewPage *)pageWithType:(ha_BannerViewType)type;

@end
