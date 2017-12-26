//
//  ha_BannerViewPage.m
//  Objective-C Project
//
//  Created by hahand on 2017/12/22.
//  Copyright © 2017年 hahand. All rights reserved.
//

#import "ha_BannerViewPage.h"

@implementation ha_BannerViewPage

+ (ha_BannerViewPage *)pageWithType:(ha_BannerViewType)type {
    ha_BannerViewPage *page = [[NSBundle mainBundle] loadNibNamed:@"ha_BannerViewPage" owner:nil options:nil].firstObject;
    page.type = type;
    return page;
}

- (void)setType:(ha_BannerViewType)type {
    _type = type;
    self.textLabel.hidden = !(type | ha_BannerViewTypeText);
    self.imageView.hidden =
    !(type | ha_BannerViewTypeLocalImage ||
    type | ha_BannerViewTypeRemoteImage);
    self.webView.hidden = !(type | ha_BannerViewTypeWebView);
}

@end
