//
//  XTPCycleScrollView.m
//  XTPCycleScrollView
//
//  Created by Leon He on 2017/6/4.
//  Copyright © 2017年 LipuWater. All rights reserved.
//

#import "XTPCycleScrollView.h"

@interface XTPCycleScrollView () <UIScrollViewDelegate> {
    NSMutableDictionary *_onShowViewDictionary;
    
    NSInteger _totalPageNumber;
    NSInteger _positionIndex;
    CGFloat lastOffsetX;//判断滑动方向
}

@end

@implementation XTPCycleScrollView

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _onShowViewDictionary = [[NSMutableDictionary alloc] initWithCapacity:3];
        _cycleEnabled = true;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.pagingEnabled = true;
        _scrollView.delegate = self;
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
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(beginInteracting:)]){
        [self.delegate beginInteracting:_scrollView];
    }
    
    return _scrollView;
}

- (void)layoutSubviews {
    _scrollView.frame = self.bounds;
    [self reloadData];
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    _scrollView.scrollEnabled = scrollEnabled;
}

- (BOOL)scrollEnabled {
    return _scrollView.scrollEnabled;
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cycleScrollView:didClickedAtPage:)]) {
        [self.delegate cycleScrollView:self didClickedAtPage:_currentPage];
    }
}

- (void)reloadData {
    if (self.dataSource) {
        if ([self.dataSource respondsToSelector:@selector(numberOfViewsForCycleScrollView:)]) {
            _totalPageNumber = [self.dataSource numberOfViewsForCycleScrollView:self];
        }
    }
    if (_onShowViewDictionary.count > 0) {
        [_onShowViewDictionary removeAllObjects];
    }
    
    if (_cycleEnabled) {
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * 2000 * _totalPageNumber, 0);
        _positionIndex = 1000 * _totalPageNumber + self.currentPage;
        [_scrollView setContentOffset:CGPointMake(_positionIndex * _scrollView.frame.size.width, 0) animated:false];
    } else {
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * _totalPageNumber, 0);
        _positionIndex = self.currentPage;
        [_scrollView setContentOffset:CGPointMake(_positionIndex * _scrollView.frame.size.width, 0) animated:false];
    }
    
    if (_totalPageNumber > 0) {
        [self setPageToPositionIndex:_positionIndex];
    }
}

- (void)setPageToPositionIndex:(NSInteger)positionIndex {
    [self prepareViewAtPositionIndex:positionIndex - 1];
    [self prepareViewAtPositionIndex:positionIndex];
    [self prepareViewAtPositionIndex:positionIndex + 1];
}

- (void)prepareViewAtPositionIndex:(NSInteger)positionIndex {
    if (!_cycleEnabled) {
        if (positionIndex < 0 || positionIndex > _totalPageNumber - 1) {
            return;
        }
    }
    
    NSInteger pageIndex = [self pageNoFromPositionIndex:positionIndex];
    UIView *view = [_onShowViewDictionary objectForKey:@(pageIndex)];
    if (!view && self.dataSource && [self.dataSource respondsToSelector:@selector(viewForCycleScrollView:atPage:)]) {
        view = [self.dataSource viewForCycleScrollView:self atPage:pageIndex];
        [_scrollView addSubview:view];
        [_onShowViewDictionary setObject:view forKey:@(pageIndex)];
    }
    view.frame = CGRectMake(positionIndex * _scrollView.frame.size.width, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
}

- (NSInteger)pageNoFromPositionIndex:(NSInteger)positionIndex {
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_totalPageNumber == 0) {
        return;
    }
    CGFloat pageWidth = _scrollView.frame.size.width;
    
    
    NSInteger positionIndex = _positionIndex;
    if(lastOffsetX < scrollView.contentOffset.x){//scrollview左滑
        //+0.15，在滑动翻页即将完成的时候判断为翻页
        positionIndex = (_scrollView.contentOffset.x / pageWidth) + 0.15;
    } else if(lastOffsetX > scrollView.contentOffset.x){
        positionIndex = (_scrollView.contentOffset.x / pageWidth) + 0.85;
    }
    
    if (positionIndex != _positionIndex) {
        if (!_cycleEnabled) {
            if (positionIndex < 0 || positionIndex > _totalPageNumber - 1) {
                return;
            }
        }
        _positionIndex = positionIndex;
        _currentPage = [self pageNoFromPositionIndex:_positionIndex];
        if (self.delegate && [self.delegate respondsToSelector:@selector(cycleScrollView:didScrollToPage:)]) {
            [self.delegate cycleScrollView:self didScrollToPage:_currentPage];
        }
        
        [self setPageToPositionIndex:_positionIndex];
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(cycleScollViewDidScoll:)]){
        [self.delegate cycleScollViewDidScoll:_scrollView];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
}

@end
