//
//  CustomPage.m
//  ha_BannerViewDemo
//
//  Created by 聂鼎 on 2017/12/26.
//  Copyright © 2017年 hahand. All rights reserved.
//

#import "CustomPage.h"

@implementation CustomPage

+ (CustomPage *)page {
    CustomPage *page = [NSBundle.mainBundle loadNibNamed:@"CustomPage" owner:nil options:nil].firstObject;
    page.type = ha_BannerViewTypeText | ha_BannerViewTypeWebView;
    
    return page;
}

@end
