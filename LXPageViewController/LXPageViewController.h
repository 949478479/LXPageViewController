//
//  LXPageViewController.h
//
//  Created by 从今以后 on 16/12/27.
//  Copyright © 2016年 从今以后. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXPageViewController : UIViewController

/// 标题字体，默认为 15.0 系统字体
@property (nonatomic) UIFont *titleFont;
/// 标题在完全选中状态下的放大比率，默认 1.1
@property (nonatomic) IBInspectable CGFloat titleScale;
/// 首尾标题缩进距离，默认 10.0
@property (nonatomic) IBInspectable CGFloat titleInset;
/// 标题之间的最小距离，标题较少时间距可能会大于该值，默认 15.0
@property (nonatomic) IBInspectable CGFloat minimumTitleSpacing;
/// 标题栏高度，默认 30.0
@property (nonatomic) IBInspectable CGFloat titleBarHeight;
/// 普通状态标题颜色，默认亮灰色
@property (nonatomic) IBInspectable UIColor *normalTitleColor;
/// 选中状态标题颜色，默认红色
@property (nonatomic) IBInspectable UIColor *selectedTitleColor;
/// 标题栏背景色，默认白色
@property (nonatomic) IBInspectable UIColor *titleBarBackgroundColor;

/// 页面是否可以滚动，默认可以
@property (nonatomic) IBInspectable BOOL scrollEnabled;

/// 选中页面标题
@property (nonatomic, readonly) NSString *selectedTitle;
/// 选中页面索引
@property (nonatomic, readonly) NSUInteger selectedIndex;
/// 选中页面视图控制器
@property (nonatomic, readonly) UIViewController *selectedViewController;

/// 各页面所对应的标题
@property (nonatomic, readonly) NSArray<NSString *> *titles;
/// 各页面所对应的视图控制器
@property (nonatomic, readonly) NSArray<__kindof UIViewController *> *viewControllers;
/// 选中标题后调用
@property (nonatomic, copy) void (^selectTitleItemHandler)(NSUInteger index, NSString *title, UIViewController *vc);

/// 添加视图控制器以及对应标题，先前添加的会被移除，默认选中第一个视图控制器
- (void)addViewControllers:(NSArray<UIViewController *> *)viewControllers
				 forTitles:(NSArray<NSString *> *)titles;

/// 滑动到指定索引对应的的页面，完成块会在动画完成时调用，若不指定动画则立即调用
- (void)scrollToPageAtIndex:(NSUInteger)index
				   animated:(BOOL)animated
				 completion:(void (^)(void))completion;

@end
