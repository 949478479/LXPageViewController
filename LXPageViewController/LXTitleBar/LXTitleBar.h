//
//  LXTitleBar.h
//
//  Created by 从今以后 on 16/12/27.
//  Copyright © 2016年 从今以后. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXTitleBar : UIView

/// 标题字体，默认 15.0 系统字体
@property (nonatomic) UIFont *titleFont;
/// 标题在完全选中状态下的放大比率，默认 1.1
@property (nonatomic) IBInspectable CGFloat titleScale;
/// 首尾标题缩进距离，默认 10.0
@property (nonatomic) IBInspectable CGFloat titleInset;
/// 标题之间的最小距离，标题较少时间距可能会大于该值，默认 15.0
@property (nonatomic) IBInspectable CGFloat minimumTitleSpacing;
/// 普通状态标题颜色，默认亮灰色
@property (nonatomic) IBInspectable UIColor *normalTitleColor;
/// 选中状态标题颜色，默认红色
@property (nonatomic) IBInspectable UIColor *selectedTitleColor;

/// 标题字符串数组
@property (nonatomic, copy) NSArray<NSString *> *titles;
/// 选中的标题
@property (nonatomic, readonly) NSString *selectedTitle;
/// 选中标题的索引
@property (nonatomic, readonly) NSUInteger selectedIndex;

/// 滑块向相邻标题滑动时的滑动进度，范围 -1.0~1.0，负数表示向左滑动，正数表示向右滑动
@property (nonatomic) CGFloat slideProgress;
/// 选中标题后调用
@property (nonatomic, copy) void (^selectTitleHandler)(NSUInteger selectedIndex, NSString *selectedTitle);

/// 滚动动标题栏以致选中标题可见，无动画
- (void)scrollSelectedTitleToVisible;

/// 选中指定索引的标题项，不会触发闭包回调
- (void)selectTitleAtIndex:(NSUInteger)index animated:(BOOL)animated;

@end
