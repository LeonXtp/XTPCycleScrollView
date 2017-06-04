//
//  XTPCycleScrollMenu.m
//  XTPCycleScrollMenu
//
//  Created by Leon He on 2017/5/16.
//  Copyright © 2017年 LipuWater. All rights reserved.
//

#import "XTPCycleScrollMenu.h"

typedef enum {
    LEFT,
    MIDDLE,
    RIGHT
}tap_position;

@interface XTPCycleScrollMenu() <UIScrollViewDelegate> {
    NSMutableSet *_reusableViewSet;
    NSMutableDictionary *_onShowViewDictionary;
    
    NSInteger _totalPageNumber;
    NSInteger _positionIndex;
    
    NSInteger _pageTapped;
    tap_position _tapedPosition;//点击的位置，左边要右移动， 右边要左移
    
    CGFloat lastOffsetX;//判断滑动方向

}

@end

@implementation XTPCycleScrollMenu

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        //同时要准备5个view
        _reusableViewSet = [[NSMutableSet alloc] initWithCapacity:5];
        _onShowViewDictionary = [[NSMutableDictionary alloc] initWithCapacity:5];
        _cycleEnabled = true;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width/3, frame.size.height)];
        _scrollView.pagingEnabled = true;
        _scrollView.delegate = self;
        _scrollView.clipsToBounds = NO;//用于单屏多页展示
        _scrollView.showsHorizontalScrollIndicator = false;
        _scrollView.showsVerticalScrollIndicator = false;
        
        [self addSubview:_scrollView];
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [_scrollView addGestureRecognizer:gesture];
    }
    return self;
}

#pragma mark---修改hitTest方法
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if(![self pointInside:point withEvent:event]){
        return nil;
    }
    
    if(0<=point.x && point.x < self.bounds.size.width/3.0){
        _pageTapped = _currentPage % 3;
        _tapedPosition = LEFT;
    } else if(point.x >= self.bounds.size.width/3.0 && point.x < self.bounds.size.width/3.0 * 2){
        _pageTapped = (_currentPage + 1)%3;
        _tapedPosition = MIDDLE;
    } else {
        _pageTapped = (_currentPage + 2)%3;
        _tapedPosition = RIGHT;
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(beginInteracting:)]){
        [self.delegate beginInteracting:_scrollView];
    }
    
    return _scrollView;
}

- (void)layoutSubviews {
    _scrollView.frame = CGRectMake(self.frame.size.width/3, 0, self.frame.size.width/3, self.frame.size.height);
    [self reloadData];
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    _scrollView.scrollEnabled = scrollEnabled;
}

- (BOOL)scrollEnabled {
    return _scrollView.scrollEnabled;
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cycleScrollMenu:didClickedAtPage:)]) {
        [self.delegate cycleScrollMenu:self didClickedAtPage:_pageTapped];
    }
    if(self.viewTappedAlwaysScrollMiddle){
        if(_tapedPosition == LEFT ){
            [self scrollLeft];
        } else if(_tapedPosition == RIGHT ){
            [self scrollRight];
        }
    }
}

- (void)scrollLeft{
    [_scrollView setContentOffset:CGPointMake(_positionIndex * _scrollView.frame.size.width -_scrollView.frame.size.width, 0) animated:YES];
}

- (void)scrollRight{
    [_scrollView setContentOffset:CGPointMake(_positionIndex * _scrollView.frame.size.width + _scrollView.frame.size.width, 0) animated:YES];
}

- (id)dequeueReusableView {
    id obj = [_reusableViewSet anyObject];
    if (obj) {
        [_reusableViewSet removeObject:obj];
    }
    return obj;
}

- (void)reloadData {
    if (self.dataSource) {
        if ([self.dataSource respondsToSelector:@selector(numberOfViewsForCycleScrollMenu:)]) {
            _totalPageNumber = [self.dataSource numberOfViewsForCycleScrollMenu:self];
        }
    }

    //    NSLog(@"_onShowViewDictionary:%@", _onShowViewDictionary);
    if (_onShowViewDictionary.count > 0) {
        [_reusableViewSet addObjectsFromArray:[_onShowViewDictionary allValues]];
        [_onShowViewDictionary removeAllObjects];
    }
    
    if (_cycleEnabled) {
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * 2000 * _totalPageNumber, 0);
        _positionIndex = 1000 * _totalPageNumber + self.currentPage;//在存当前选中页面的情况下重新加载
        [_scrollView setContentOffset:CGPointMake(_positionIndex * _scrollView.frame.size.width, 0) animated:false];
    } else {
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * _totalPageNumber, 0);
        _positionIndex = self.currentPage;
        [_scrollView setContentOffset:CGPointMake(_positionIndex * _scrollView.frame.size.width, 0) animated:false];
    }
    
    if (_totalPageNumber > 0) {
        //        NSLog(@"setPageToPositionIndex:%d", _positionIndex);
        [self setPageToPositionIndex:_positionIndex];
    }
}

- (NSArray*)sortIndex:(NSArray*)array{
    NSMutableArray *indexArrays= [NSMutableArray arrayWithArray:array];
    for(int i = 0; i< indexArrays.count-1; i++){
        NSNumber *temp;
        for(int j = 0; j< indexArrays.count-i-1;j++){
            NSNumber *key1 = indexArrays[j];
            NSInteger index1 = [key1 integerValue];
            
            NSNumber *key2 = indexArrays[j+1];
            NSInteger index2 = [key2 integerValue];
            
            if(index1>index2){
                temp = indexArrays[j];
                indexArrays[j] = indexArrays[j+1];
                indexArrays[j+1] = temp;
            }
        }
    }
    return indexArrays;
}

- (void)setPageToPositionIndex:(NSInteger)positionIndex {
    [self prepareViewAtPositionIndex:positionIndex - 1];
    [self prepareViewAtPositionIndex:positionIndex];
    [self prepareViewAtPositionIndex:positionIndex + 1];
    [self prepareViewAtPositionIndex:positionIndex + 2];
    [self prepareViewAtPositionIndex:positionIndex + 3];
    
    NSArray *allKeyArray = _onShowViewDictionary.allKeys;
    //    NSLog(@"allKeyArray:%@", allKeyArray);
    allKeyArray = [self sortIndex:allKeyArray];
    //    NSLog(@"indexArray:%@", allKeyArray);
    for (NSInteger i = 0; i < allKeyArray.count; i++) {
        NSNumber *key = [allKeyArray objectAtIndex:i];
        NSInteger index = [key integerValue];
        UIView *view = [_onShowViewDictionary objectForKey:key];
        
        if( index + 1 < positionIndex || positionIndex > index + 3 ){
            view.hidden = true;
            [_reusableViewSet addObject:view];
            [_onShowViewDictionary removeObjectForKey:key];
        } else {
            view.hidden = false;
        }
    }
    
}

- (NSInteger)pageFromPositionIndex:(NSInteger)positionIndex {
    if (_totalPageNumber == 0) {
        return 0;
    }
    NSInteger showIndex = positionIndex;
    if (positionIndex > 0) {
        showIndex = positionIndex % _totalPageNumber;
    } else if (positionIndex < 0) {
        showIndex = positionIndex % _totalPageNumber + _totalPageNumber;
    }
    return showIndex;
}

- (void)prepareViewAtPositionIndex:(NSInteger)positionIndex {
    if (!_cycleEnabled) {
        if (positionIndex < 0 || positionIndex > _totalPageNumber - 1) {
            return;
        }
    }
    NSInteger showIndex = [self pageFromPositionIndex:positionIndex];
//    NSLog(@"prepareViewAtPositionIndex positionIndex = %ld, showIndex = %ld", positionIndex, showIndex);
    UIView *view = [_onShowViewDictionary objectForKey:@(positionIndex)];
    if (!view && self.dataSource && [self.dataSource respondsToSelector:@selector(viewForCycleScrollMenu:atPage:)]) {
        view = [self.dataSource viewForCycleScrollMenu:self atPage:showIndex];
        [_scrollView addSubview:view];
        [_onShowViewDictionary setObject:view forKey:@(positionIndex)];
    }
    view.frame = CGRectMake((positionIndex -1)* _scrollView.frame.size.width, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    view.hidden = false;
    //    NSLog(@"_onShowViewDictionary:%@", _onShowViewDictionary);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_totalPageNumber == 0) {
        return;
    }
    CGFloat pageWidth = _scrollView.frame.size.width;
    
    NSInteger page = _positionIndex;
    if(lastOffsetX < scrollView.contentOffset.x){//scrollview左滑
//        NSLog(@"左滑");
        page = (_scrollView.contentOffset.x / pageWidth) + 0.15;//+0.15，在滑动翻页即将完成的时候判断为翻页
    } else if(lastOffsetX > scrollView.contentOffset.x){
//        NSLog(@"右滑");
        page = (_scrollView.contentOffset.x / pageWidth) + 0.85;
    }
    
//    NSLog(@"scrollViewDidScroll page = %ld, _positionIndex = %ld", (long)page, (long)_positionIndex);
    
    if (page != _positionIndex) {
        if (!_cycleEnabled) {
            if (page < 0 || page > _totalPageNumber - 1) {
                return;
            }
        }
        _positionIndex = page;
        _currentPage = [self pageFromPositionIndex:_positionIndex];
        
        [self setPageToPositionIndex:_positionIndex];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(cycleScrollMenu:didScrollToPage:orderedViews:)]) {
            [self.delegate cycleScrollMenu:self didScrollToPage:_currentPage orderedViews:[self orderedViews ]];
        }
    }
    
    lastOffsetX = scrollView.contentOffset.x;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(cycleScollMenuDidScoll:)]){
        [self.delegate cycleScollMenuDidScoll:_scrollView];
    }
}

- (NSArray*)orderedViews{
    if(_onShowViewDictionary.count<5){
        return nil;
    }
    NSMutableArray *orderedViews = [[NSMutableArray alloc]initWithCapacity:5];
    [orderedViews addObject:[_onShowViewDictionary objectForKey:[NSNumber numberWithInteger:_positionIndex-1]]];
    [orderedViews addObject:[_onShowViewDictionary objectForKey:[NSNumber numberWithInteger:_positionIndex]]];
    [orderedViews addObject:[_onShowViewDictionary objectForKey:[NSNumber numberWithInteger:_positionIndex+1]]];
    [orderedViews addObject:[_onShowViewDictionary objectForKey:[NSNumber numberWithInteger:_positionIndex+2]]];
    [orderedViews addObject:[_onShowViewDictionary objectForKey:[NSNumber numberWithInteger:_positionIndex+3]]];
    return orderedViews;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
}

@end
