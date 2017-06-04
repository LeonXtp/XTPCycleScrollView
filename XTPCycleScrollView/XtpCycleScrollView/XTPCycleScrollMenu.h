//
//  XTPCycleScrollMenu.h
//  XTPCycleScrollMenu
//
//  Created by Leon He on 2017/5/16.
//  Referenced by https://github.com/YueRuo/YRADScrollView
//  Copyright © 2017年 LipuWater. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol XTPCycleScrollMenuDataSource;
@protocol XTPCycleScrollMenuDelegate;

@interface XTPCycleScrollMenu : UIView

@property (assign, nonatomic) NSInteger currentPage;
@property (assign, nonatomic) BOOL scrollEnabled; //default is YES
@property (assign, nonatomic) BOOL cycleEnabled;  //是否可循环滚动，default is YES
@property (weak, nonatomic) id<XTPCycleScrollMenuDataSource> dataSource;
@property (weak, nonatomic) id<XTPCycleScrollMenuDelegate> delegate;
@property (assign, nonatomic) BOOL viewTappedAlwaysScrollMiddle; //点击某个item后是否这个item总是移动到中间位置，适用于三个item的情况
@property (nonatomic, strong) UIScrollView *scrollView;

- (id)dequeueReusableView; //重用池中取出一个控件
- (NSArray*)orderedViews; //获取当前所有的view
- (void)reloadData;

@end

@protocol XTPCycleScrollMenuDataSource <NSObject>
/*!
 *	@brief	获取数据源，要注意的是，使用dequeueReusableView进行获取，如果返回为nil，则再进行创建，类似tableView早前的数据获取方式。
 *
 *	@param 	pageIndex 	第几页
 *
 *	@return	要展示的控件
 */
- (UIView *)viewForCycleScrollMenu:(XTPCycleScrollMenu *)cycleScrollMenu atPage:(NSInteger)pageIndex;
- (NSUInteger)numberOfViewsForCycleScrollMenu:(XTPCycleScrollMenu *)cycleScrollMenu;
@end

@protocol XTPCycleScrollMenuDelegate <NSObject>
@optional

- (void)beginInteracting:(UIScrollView*)scrollView;//用户开始点击或者滑动此View
- (void)cycleScollMenuDidScoll:(UIScrollView*)scrollView;

- (void)cycleScrollMenu:(XTPCycleScrollMenu *)cycleScrollMenu didClickedAtPage:(NSInteger)pageIndex;//点击了某一页
- (void)cycleScrollMenu:(XTPCycleScrollMenu *)cycleScrollMenu didScrollToPage:(NSInteger)pageIndex  orderedViews:(NSArray *)orderedViews;//滚动到某一页

@end
