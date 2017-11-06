//
//  LXTitleBar.h
//
//  Created by 从今以后 on 16/12/27.
//  Copyright © 2016年 从今以后. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LXTitleBarConfiguration: NSObject

/// 标题字体，默认 15.0 系统字体
@property (nonatomic) UIFont *titleFont;
/// 标题在完全选中状态下的放大比率，默认 1.1
@property (nonatomic) IBInspectable CGFloat titleScale;
/// 首尾标题缩进距离，默认 10.0
@property (nonatomic) IBInspectable CGFloat titleInset;
/// 标题之间的最小距离，默认 15.0
@property (nonatomic) IBInspectable CGFloat minimumTitleSpacing;

/// 普通状态标题颜色，默认亮灰色
@property (nonatomic) IBInspectable UIColor *normalTitleColor;
/// 选中状态标题颜色，默认红色
@property (nonatomic) IBInspectable UIColor *selectedTitleColor;

/// 滑块高度，默认 2
@property (nonatomic) IBInspectable CGFloat sliderHeight;
/// 滑块延伸宽度，默认 0
@property (nonatomic) IBInspectable CGFloat sliderExtendedWidth;

@end

@interface LXTitleBar : UIView

/// 滑块向相邻标题滑动时的滑动进度，范围 -1.0 ~ 1.0，负数表示向左滑动，正数表示向右滑动
@property (nonatomic) CGFloat slideProgress;

/// 选中标题的索引
@property (nonatomic, readonly) NSInteger selectedIndex;
/// 选中的标题
@property (nullable, nonatomic, readonly) NSString *selectedTitle;
/// 全部标题
@property (nullable, readonly, nonatomic, copy) NSArray<NSString *> *titles;
/// 选中标题后调用
@property (nullable, nonatomic, copy) void (^selectTitleHandler)(NSInteger selectedIndex, NSString *selectedTitle);

/// 仅可在使用 IB 时设置
@property (nonatomic) IBOutlet LXTitleBarConfiguration *configuration;

- (instancetype)initWithConfiguration:(LXTitleBarConfiguration *)configuration;

/// 根据标题数组和默认选中索引进行配置
- (void)setTitles:(NSArray<NSString *> *)titles selectedIndex:(NSInteger)index;

/// 滚动选中项以可见，无动画
- (void)scrollSelectedItemToVisible;

/// 滚动选中项以居中，无动画
- (void)scrollSelectedItemToCenter;

/// 选中指定索引的标题项，不会触发闭包回调
- (void)selectTitleAtIndex:(NSInteger)index animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
