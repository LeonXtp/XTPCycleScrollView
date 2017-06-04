//
//  ViewController.m
//  XTPCycleScrollView
//
//  Created by Leon He on 2017/6/4.
//  Copyright © 2017年 LipuWater. All rights reserved.
//

#import "ViewController.h"
#import "XTPCycleScrollMenu.h"
#import "XTPCycleScrollView.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

@interface ViewController ()<XTPCycleScrollMenuDataSource, XTPCycleScrollMenuDelegate, XTPCycleScrollViewDataSource, XTPCycleScrollViewDelegate>{
    UIView *currentScrollingViewByUser;
}

@property (strong, nonatomic) XTPCycleScrollMenu *cycleScrollMenu;
@property (strong, nonatomic) XTPCycleScrollView *cycleScrollView;
@end

@implementation ViewController
@synthesize cycleScrollMenu, cycleScrollView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initMenuWithFrame:CGRectMake(0, 100, SCREEN_WIDTH, 100)];
    
    [self initViewWithFrame:CGRectMake(0, 250, SCREEN_WIDTH, 150)];
    
}

- (void)initMenuWithFrame:(CGRect)frame{
    cycleScrollMenu = [[XTPCycleScrollMenu alloc]initWithFrame:frame];
    cycleScrollMenu.dataSource = self;
    cycleScrollMenu.delegate = self;
    //    adScrollView.cycleEnabled = NO;//如果设置为NO，则关闭循环滚动功能。
    cycleScrollMenu.viewTappedAlwaysScrollMiddle = YES;
    [self.view addSubview:cycleScrollMenu];
}

- (void)initViewWithFrame:(CGRect)frame{
    cycleScrollView = [[XTPCycleScrollView alloc]initWithFrame:frame];
    cycleScrollView.dataSource = self;
    cycleScrollView.delegate = self;
    //    adScrollView.cycleEnabled = NO;//如果设置为NO，则关闭循环滚动功能。
    [self.view addSubview:cycleScrollView];
}

#pragma mark - XTPCycleScrollMenuDataSource
- (UIView *)viewForCycleScrollMenu:(XTPCycleScrollMenu *)cycleScrollMenu atPage:(NSInteger)pageIndex{
    
    UILabel *label = [[UILabel alloc]init];
    label.font = [UIFont systemFontOfSize:20];
    label.textColor = [UIColor purpleColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    if(pageIndex == 0){
        label.text = @"0";
        label.backgroundColor = [UIColor redColor];
    } else if(pageIndex == 1){
        label.text = @"1";
        label.backgroundColor = [UIColor blueColor];
    } else {
        label.text = @"2";
        label.backgroundColor = [UIColor yellowColor];
    }
    
    return label;
}

- (NSUInteger)numberOfViewsForCycleScrollMenu:(XTPCycleScrollMenu *)cycleScrollMenu{
    return 3;
}

#pragma mark -m XTPCycleScrollMenuDelegate
- (void)cycleScrollMenu:(XTPCycleScrollMenu *)cycleScrollMenu didClickedAtPage:(NSInteger)pageIndex{//点击了某一页
    NSLog(@"点击了第%ld页", pageIndex);
}

- (void)cycleScrollMenu:(XTPCycleScrollMenu *)cycleScrollMenu didScrollToPage:(NSInteger)pageIndex  orderedViews:(NSArray *)orderedViews{//滚动到某一页
    NSLog(@"滚动到第%ld页", pageIndex);
}

- (void)beginInteracting:(UIScrollView*)scrollView{
    currentScrollingViewByUser = scrollView;
}

- (void)cycleScollMenuDidScoll:(UIScrollView*)scrollView{
    if(currentScrollingViewByUser == scrollView){
        cycleScrollView.scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x * 3, 0);
    }
}

#pragma mark - XTPCycleScrollViewDataSource
- (UIView *)viewForCycleScrollView:(XTPCycleScrollView *)cycleScrollView atPage:(NSInteger)pageIndex{
    UILabel *label = [[UILabel alloc]init];
    label.font = [UIFont systemFontOfSize:20];
    label.textColor = [UIColor purpleColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    if(pageIndex == 0){
        label.text = @"0";
        label.backgroundColor = [UIColor redColor];
    } else if(pageIndex == 1){
        label.text = @"1";
        label.backgroundColor = [UIColor blueColor];
    } else {
        label.text = @"2";
        label.backgroundColor = [UIColor yellowColor];
    }
    
    return label;
}

- (NSUInteger)numberOfViewsForCycleScrollView:(XTPCycleScrollView *)cycleScrollView{
    return 3;
}

#pragma mark -m XTPCycleScrollViewDelegate
- (void)cycleScrollView:(XTPCycleScrollView *)cycleScrollView didClickedAtPage:(NSInteger)pageIndex{//点击了某一页

}

- (void)cycleScrollView:(XTPCycleScrollView *)cycleScrollView didScrollToPage:(NSInteger)pageIndex{
    //滚动到某一页
}

- (void)cycleScollViewDidScoll:(UIScrollView*)scrollView{
    if(currentScrollingViewByUser == scrollView){
        cycleScrollMenu.scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x / 3, 0);
    }
}

@end
