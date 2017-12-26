//
//  ha_BannerView.m
//  Objective-C Project
//
//  Created by hahand on 2017/12/20.
//  Copyright © 2017年 hahand. All rights reserved.
//
/** Banner的主界面, 只包含 scrollView. 页面指示器 必须自己实现
 *  Banner 提供 翻页回调, 点击回调
 *  Banner 支持自定义 Page, 必须为h_BannerViewPage或者子类型, 支持 XIB 或者 代码 初始化
 */
#define BanW (self.bounds.size.width)
#define BanH (self.bounds.size.height)
#define BanS (self.bounds.size)

#import "ha_BannerView.h"
#import "ha_BannerViewPage.h"

@interface ha_BannerView()<UIScrollViewDelegate, UIWebViewDelegate>
{
    /** YES：向下或右划（展示前面内容）
         NO：向上或左划（展示后面内容）*/
    BOOL _loadPrevious;
    NSUInteger _numbersOfPage;  //总页数
    NSUInteger _currentPageIndex; //当前页码
    
    NSTimer *_timer; //定时器
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray<ha_BannerViewPage *>*pages;
@property (nonatomic, strong) UITapGestureRecognizer *tap;

@end

@implementation ha_BannerView

#pragma mark - Public

+ (ha_BannerView *)bannerWithDirection:(ha_BannerViewScrollDirection)direction andPage:(ha_BannerViewPage *(^)(void))pageBlock {
    ha_BannerView *banner = ha_BannerView.alloc.init;
    banner.frame = CGRectMake(0, 0, 320, 120); //默认尺寸,防止忘记设frame
    banner.direction = direction;
    banner.pageBlock = pageBlock;
    
    [banner reloadData];
    return banner;
}

- (void)setUp {
    
    [self clearScrollView];
    self.userInteractionEnabled = YES;
    self.scrollView.userInteractionEnabled = YES;
    
    //加载scrollView
    [self addSubview:self.scrollView];
    [self sendSubviewToBack:self.scrollView];
    
#define __CONS(ATT) [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttribute##ATT relatedBy:NSLayoutRelationEqual toItem:self.scrollView.superview attribute:NSLayoutAttribute##ATT multiplier:1 constant:0]
    [self addConstraints:@[__CONS(Top),__CONS(Width),__CONS(Left),__CONS(Height)]];
//    [self layoutIfNeeded];
//    [self setNeedsUpdateConstraints];
    
    self.scrollView.contentSize = self.correctScrollViewContentSize;
    
    _numbersOfPage = [self.delegate ha_numbersOfPagesInBannerView:self];
    //没有 page 时 直接返回
    if (_numbersOfPage == 0) {
        return;
    }
    //一般情况 最大 3 页, 循环时强制为 3
    CGFloat pageCount = self.cycleScrollEnabled == YES ? 3 : _numbersOfPage;
    
    CGFloat unitWidth = BanW;
    CGFloat unitHeight = BanH;
    for (int i = 0; i < pageCount; i++) {
        CGFloat x = self.direction ? i * unitWidth : 0;
        CGFloat y = self.direction ? 0 : i * unitHeight;
        //如果block没设置，则使用默认page
        ha_BannerViewPage *page = self.pageBlock ?
        self.pageBlock() : [ha_BannerViewPage
         pageWithType:ha_BannerViewTypeLocalImage];

        page.frame = CGRectMake(x, y, unitWidth, unitHeight);
        page.tag = 500 + i;
        page.webView.delegate = self;
        
#ifdef ha_bannerview_debug_mode
        page.layer.borderColor = UIColor.redColor.CGColor;
        page.layer.borderWidth = 3;
#endif
        [self.scrollView addSubview:page]; //加到视图
        [_pages addObject:page]; //加到数组
    }
    
    [self.scrollView addGestureRecognizer:self.tap];//添加手势
    [self pagesReloadData];//加载数据
    [self setUpTimer];//开启定时器
}

- (void)reloadData {
    //对齐 偏移, 刷新数据源
    [self pagesReloadData];
    [self refreshPagesFrame];
    self.scrollView.contentSize = [self correctScrollViewContentSize];
    self.scrollView.contentOffset = [self correctScrollViewOffsetPoint];
}

#pragma mark - Private

- (void)clearScrollView {
    for (UIView *subv in self.scrollView.subviews.reverseObjectEnumerator.allObjects) {
        [subv removeFromSuperview];
    }
    self.scrollView = nil;

    [self.pages removeAllObjects];
    _numbersOfPage = 0;
    _currentPageIndex = 0;
}

- (void)setUpTimer {
    if (self.cycleScrollEnabled && self.autoCycleScroll && _timer == nil) {
        if (_durationOfCycle == 0) {
            _durationOfCycle = 5.0;
        }
        _timer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:_durationOfCycle] interval:_durationOfCycle target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

- (void)removeTimer {
    [_timer invalidate];
    _timer = nil;
}

//返回正确页码，防止数组越界
- (NSUInteger)safetyPageIndex:(NSInteger)unsafetyNumber {
    if (_numbersOfPage == 0) {
        return 0;
    }
    NSInteger minUnsafeInt = (unsafetyNumber + 100 * _numbersOfPage) % _numbersOfPage;
    if (minUnsafeInt < 0) {
        minUnsafeInt = _numbersOfPage - 1;
    }
    if (minUnsafeInt > _numbersOfPage - 1) {
        minUnsafeInt = 0;
    }
    return minUnsafeInt;
}

//根据滚动方向不同，offsetPoint 偏移不同
- (CGPoint)correctScrollViewOffsetPoint {
    CGPoint offsetPoint = CGPointZero;
    if (self.direction == ha_BannerViewScrollDirectionVertical) {
        offsetPoint = self.cycleScrollEnabled ?
        CGPointMake(0, BanH) :
        CGPointMake(0, BanH * _currentPageIndex);
    } else
    if (self.direction == ha_BannerViewScrollDirectionHorizontal) {
        offsetPoint = self.cycleScrollEnabled ?
        CGPointMake(BanW, 0) :
        CGPointMake(BanW * _currentPageIndex, 0);
    }
    return offsetPoint;
}
//根据滚动方向不同，contentSize 尺寸不同
- (CGSize)correctScrollViewContentSize {
    CGSize contentSize = self.bounds.size;
    if (self.direction == ha_BannerViewScrollDirectionVertical) {
        contentSize = CGSizeMake(BanW, self.pages.count * BanH);
    } else
    if (self.direction == ha_BannerViewScrollDirectionHorizontal) {
        contentSize = CGSizeMake(self.pages.count * BanW, BanH);
    }
    return contentSize;
}

#pragma mark Refresh
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self refreshPagesFrame];
    self.scrollView.contentSize = self.correctScrollViewContentSize;
    self.scrollView.contentOffset = self.correctScrollViewOffsetPoint;
}

//页面位置更新
- (void)refreshPagesFrame {
    for (int i = 0; i < self.pages.count; i++ ) {
        ha_BannerViewPage *page = self.pages[i];
        CGFloat x = self.direction ? i * BanW : 0;
        CGFloat y = self.direction ? 0 : i * BanH;
        page.frame = CGRectMake(x, y, BanW, BanH);
    }
}
//页面数据更新
- (void)pagesReloadData {
    for (int i = 0; i < self.pages.count; i++) {
        ha_BannerViewPage *page = self.pages[i];
        NSUInteger dataIndex = [self safetyPageIndex: _currentPageIndex - 1 + i];
        //无循环 的情况
        if (self.cycleScrollEnabled == NO) {
            dataIndex = [self safetyPageIndex: _currentPageIndex + i];
        }
        //文本数据
        if ([self.delegate respondsToSelector:@selector(ha_bannerView:textForPageAtIndex:)]) {
            page.textLabel.text = [self.delegate ha_bannerView:self textForPageAtIndex:dataIndex];
        }
        //本地图片
        UIImage *localImage = nil;
        if ([self.delegate respondsToSelector:@selector(ha_bannerView:localImageForPageAtIndex:)]) {
            localImage = [self.delegate ha_bannerView:self localImageForPageAtIndex:dataIndex];
            page.imageView.image = localImage;
        }
        //网络图片
        if ([self.delegate respondsToSelector:@selector(ha_bannerView:remoteImageURLForPageAtIndex:)]) {
            NSURL *url = [self.delegate ha_bannerView:self remoteImageURLForPageAtIndex:dataIndex];
            //TODO:网络图片下载使用 YYImage， 请自行添加库 或 修改源码
            [page.imageView performSelector:@selector(yy_setImageWithURL:placeholder:) withObject:url withObject:localImage];
        }
        //网络请求
        NSURL *url = nil;
        void(^loadH5)(UIWebView *,NSString *, NSURL *) = ^(UIWebView *l_webV ,NSString *l_h5, NSURL *l_url) {
            [l_webV stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML='';"];
            [l_webV loadHTMLString:l_h5 baseURL:l_url];
        };
        if ([self.delegate respondsToSelector:@selector(ha_bannerView:requestURLForPageAtIndex:)]) {
            NSURL *url = [self.delegate ha_bannerView:self requestURLForPageAtIndex:dataIndex];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            //如果已经请求则不刷新
            NSUInteger length = page.webView.request.URL.absoluteString.length;
            if (length == 0) {
                [page.webView loadRequest:request];
            } else if (length > 0) {
                //循环下只加载新网页，
                if (_cycleScrollEnabled) {
                    if (i == 0 && _loadPrevious) {
                        loadH5(page.webView,@"",nil);//先清屏
                        [page.webView loadRequest:request];
                    }
                    if (i == 2 && !_loadPrevious) {
                        loadH5(page.webView,@"",nil);//先清屏
                        [page.webView loadRequest:request];
                    }
                }
            }
            
        }
        
        //加载H5，则之前的请求为 baseURL
        if ([self.delegate respondsToSelector:@selector(ha_bannerView:htmlStringForPageAtIndex:)]) {
            NSString *h5 = [self.delegate ha_bannerView:self htmlStringForPageAtIndex:dataIndex];
            

            //如果已经请求则不刷新
            NSUInteger length = page.webView.request.URL.absoluteString.length;
            
            if (length == 0) {
                loadH5(page.webView,h5,nil);
            } else if (length > 0) {
                //循环下只加载新网页，
                if (_cycleScrollEnabled) {
                    if (i == 0 && _loadPrevious) {
                        loadH5(page.webView,h5,nil);
                    }
                    if (i == 2 && !_loadPrevious) {
                        loadH5(page.webView,h5,nil);
                    }
                }
            }
            [page.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML='';"];
            [page.webView loadHTMLString:h5 baseURL:url];
        }
    }
}
//滚动到边界时要 重新布局 并 刷新数据
- (void)refreshScrollView {
    NSUInteger tmpPageIndex = _currentPageIndex;
    
    if (self.pages.count <= 1) { return; }
    
    self.scrollView.contentSize = [self correctScrollViewContentSize];
    self.scrollView.contentOffset = [self correctScrollViewOffsetPoint];
    
    if (_loadPrevious == YES) {
        _currentPageIndex = [self safetyPageIndex:_currentPageIndex - 1];
        ha_BannerViewPage *lastPage = self.pages.lastObject;
        [self.pages removeObject:lastPage];
        [self.pages insertObject:lastPage atIndex:0];
    }
    if (_loadPrevious == NO) {
        _currentPageIndex = [self safetyPageIndex:_currentPageIndex + 1];
        ha_BannerViewPage *firstPage = self.pages.firstObject;
        [self.pages removeObject:firstPage];
        [self.pages insertObject:firstPage atIndex:self.pages.count];
    }
    //页码更新回调
    if (tmpPageIndex != _currentPageIndex) {
        if ([self.delegate respondsToSelector:@selector(ha_bannerView:pageIndexDidChanged:)]) {
            [self.delegate ha_bannerView:self pageIndexDidChanged:_currentPageIndex];
        }
    }
    
    [self pagesReloadData];
    [self refreshPagesFrame];
}

#pragma mark - Event

- (void)scrollViewTapped:(UITapGestureRecognizer *)sender event:(UIControlEvents)event {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ha_bannerViewPageDidSelected:atIndex:)]) {
        [self.delegate ha_bannerViewPageDidSelected:self atIndex: _currentPageIndex];
    }
}
- (void)timerFired:(id)sender {
    if (_timer && self.autoCycleScroll) {
        CGPoint prePageOffset = CGPointZero;
        CGPoint nextPageOffset = self.direction ?
        CGPointMake(2 * BanW, 0) : CGPointMake(0, 2 * BanH);
        CGPoint correctPageOffset = self.ha_autoCycleDirectionReversed ? prePageOffset : nextPageOffset;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.scrollView setContentOffset:correctPageOffset animated:YES];
        });
    }
}

#pragma mark - Getter & Setter

- (NSMutableArray<ha_BannerViewPage *>*)pages {
    if (_pages == nil) {
        _pages = @[].mutableCopy;
    }
    return _pages;
}

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.backgroundColor = UIColor.grayColor;
        _scrollView.bounces = NO;
        _scrollView.clipsToBounds = YES;
        _scrollView.userInteractionEnabled = YES;
        _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    }
#ifdef ha_bannerview_debug_mode
    _scrollView.clipsToBounds = NO;
    _scrollView.alpha = 0.5;
    _scrollView.layer.borderColor = UIColor.blueColor.CGColor;
    _scrollView.layer.borderWidth = 5;
#endif
    
    return _scrollView;
}

- (ha_BannerViewPage *(^)(void))pageBlock {
    if (_pageBlock) {
        return _pageBlock;
    }
    return ^ha_BannerViewPage *(void) {
        return [ha_BannerViewPage
                 pageWithType:ha_BannerViewTypeLocalImage];
    };
}

- (UITapGestureRecognizer *)tap {
    if (_tap == nil) {
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped:event:)];
    }
    return _tap;
}

- (void)setDelegate:(id<ha_BannerViewDelegate>)delegate {
    if (delegate == nil || _delegate != delegate) {
        [self clearScrollView];
//        self.scrollView.tag = 888;
    }
    _delegate = delegate;
}

- (void)setAutoCycleScroll:(BOOL)autoCycleScroll {
    _autoCycleScroll = autoCycleScroll;
    if (_autoCycleScroll) {
        self.cycleScrollEnabled = YES;
        [_timer setFireDate:[NSDate distantPast]];
    }
}

- (void)setDurationOfCycle:(NSTimeInterval)durationOfCycle {
    _durationOfCycle = durationOfCycle;
    if (self.autoCycleScroll == YES) {
        [self removeTimer];
        [self setUpTimer];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //到首页了
    BOOL isFirstPage =
    (self.direction == ha_BannerViewScrollDirectionVertical
     && scrollView.contentOffset.y <= 0) ||
    (self.direction == ha_BannerViewScrollDirectionHorizontal
     && scrollView.contentOffset.x <= 0);
    //到末页了
    BOOL isLastPage =
    (self.direction == ha_BannerViewScrollDirectionVertical
    && scrollView.contentOffset.y >= 2 * BanH) ||
    (self.direction == ha_BannerViewScrollDirectionHorizontal
     && scrollView.contentOffset.x >= 2 * BanW);
    
    if (isFirstPage) {
        _loadPrevious = YES;
    }
    if (isLastPage) {
        _loadPrevious = NO;
    }
    //循环时 在循环方法里刷新页数
    if (self.cycleScrollEnabled) {
        if (isFirstPage || isLastPage) {
            [self refreshScrollView];
        }
    } else
    {
        //不循环时，直接刷新页数
        CGFloat offset = self.direction ? self.scrollView.contentOffset.x : self.scrollView.contentOffset.y;
        CGFloat unitL = self.direction ? BanW : BanH;
        //距离差一页时才更新
        NSUInteger tmpIndex = _currentPageIndex;
        if (offset - _currentPageIndex * unitL >= unitL) {
            tmpIndex = _currentPageIndex + 1 > _numbersOfPage ? _currentPageIndex : _currentPageIndex + 1;
        } else
        if (_currentPageIndex * unitL - offset >= unitL) {
            tmpIndex = _currentPageIndex - 1 <= 0 ? 0 : _currentPageIndex - 1;
        }
        //只有页数变动才提示
        if (_currentPageIndex != tmpIndex) {
            _currentPageIndex = tmpIndex;
            if (self.delegate && [self.delegate respondsToSelector:@selector(ha_bannerView:pageIndexDidChanged:)]) {
                [self.delegate ha_bannerView:self pageIndexDidChanged:_currentPageIndex];
            }
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        [self removeTimer];
    });
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self setUpTimer];
}

#pragma mark - UIWebViewDelegate
//TODO:UIWebView代理暂未实现

@end


