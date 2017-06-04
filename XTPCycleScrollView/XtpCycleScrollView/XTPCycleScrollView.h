//
//  XTPCycleScrollView.h
//  XTPCycleScrollView
//
//  Created by Leon He on 2017/6/4.
//  Copyright © 2017年 LipuWater. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol XTPCycleScrollViewDataSource;
@protocol XTPCycleScrollViewDelegate;

@interface XTPCycleScrollView : UIView
@property (assign, nonatomic) NSInteger currentPage;
@property (assign, nonatomic) BOOL scrollEnabled; //default is YES
@property (assign, nonatomic) BOOL cycleEnabled;  //是否可循环滚动，default is YES
@property (weak, nonatomic) id<XTPCycleScrollViewDataSource> dataSource;
@property (weak, nonatomic) id<XTPCycleScrollViewDelegate> delegate;
@property (nonatomic, strong) UIScrollView *scrollView;

- (void)reloadData;

@end

@protocol XTPCycleScrollViewDataSource <NSObject>
/*!
 *	@brief	获取数据源，要注意的是，使用dequeueReusableView进行获取，如果返回为nil，则再进行创建，类似tableView早前的数据获取方式。
 *
 *	@param 	pageIndex 	第几页
 *
 *	@return	要展示的控件
 */
- (UIView *)viewForCycleScrollView:(XTPCycleScrollView *)cycleScrollView atPage:(NSInteger)pageIndex;
- (NSUInteger)numberOfViewsForCycleScrollView:(XTPCycleScrollView *)cycleScrollView;
@end

@protocol XTPCycleScrollViewDelegate <NSObject>
- (void)beginInteracting:(UIScrollView*)scrollView;//用户开始点击或者滑动此View
- (void)cycleScollViewDidScoll:(UIScrollView*)scrollView;
- (void)cycleScrollView:(XTPCycleScrollView *)cycleScrollView didClickedAtPage:(NSInteger)pageIndex;//点击了某一页
- (void)cycleScrollView:(XTPCycleScrollView *)cycleScrollView didScrollToPage:(NSInteger)pageIndex;//滚动到某一页
@end
