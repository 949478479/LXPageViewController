//
//  LXPageViewController.h
//
//  Created by 从今以后 on 16/12/27.
//  Copyright © 2016年 从今以后. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LXPageViewController;

NS_ASSUME_NONNULL_BEGIN

@interface LXPageViewControllerConfiguration: NSObject

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

/// 标题栏高度，默认 35
@property (nonatomic) IBInspectable CGFloat titleBarHeight;
/// 标题栏背景色，默认白色
@property (nonatomic) IBInspectable UIColor *titleBarBackgroundColor;

/// 页面是否可以滑动，默认 YES
@property (nonatomic) IBInspectable BOOL scrollEnabled;

@end

@protocol LXPageViewControllerDataSource <NSObject>
@required
- (UIViewController *)pageViewController:(LXPageViewController *)pageViewController viewControllerAtIndex:(NSInteger)index;
@end

@protocol LXPageViewControllerDelegate <NSObject>
@optional
- (void)pageViewController:(LXPageViewController *)pageViewController
willTransitionToViewController:(UIViewController *)pendingViewController
                     index:(NSInteger)index;

- (void)pageViewController:(LXPageViewController *)pageViewController
       transitionCompleted:(BOOL)completed
    previousViewController:(UIViewController *)previousViewController
                     index:(NSInteger)index;
@end

@interface LXPageViewController : UIViewController

/// 仅可在使用 IB 时设置
@property (nonatomic) IBOutlet LXPageViewControllerConfiguration *configuration;

- (instancetype)initWithConfiguration:(LXPageViewControllerConfiguration *)configuration;

/// 全部页面标题
@property (nullable, nonatomic, readonly) NSArray<NSString *> *titles;
/// 当前页面索引
@property (nonatomic, readonly) NSInteger indexOfDisplayedPage;
/// 当前页面标题
@property (nullable, nonatomic, readonly) NSString *titleOfDisplayedPage;
/// 当前页面控制器
@property (nullable, nonatomic, readonly) UIViewController *viewControllerOfDisplayedPage;

@property (nullable, nonatomic, weak) id<LXPageViewControllerDelegate> delegate;
@property (nullable, nonatomic, weak) id<LXPageViewControllerDataSource> dataSource;

/// 设置初始页面的控制器及其对应索引以及全部页面的标题
- (void)setInitialViewController:(UIViewController *)viewController index:(NSInteger)index titles:(NSArray<NSString *> *)titles;

/// 滑动到指定页面，完成块会在动画完成时调用，若不指定动画则立即调用
- (void)transitionToPageAtIndex:(NSInteger)index
					   animated:(BOOL)animated
					 completion:(void (^_Nullable)(void))completion;
@end

NS_ASSUME_NONNULL_END
