//
//  LXPageViewController.m
//
//  Created by 从今以后 on 16/12/27.
//  Copyright © 2016年 从今以后. All rights reserved.
//

#import "LXPageViewController.h"
#import "LXTitleBar.h"

@interface LXPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate>

@property (nonatomic) BOOL isSlideProgessValid;
@property (nonatomic) NSUInteger targetIndex;
@property (nonatomic) NSUInteger selectedIndex;
@property (nonatomic) NSUInteger countOfViewControllers;

@property (nonatomic) LXTitleBar *titleBar;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIPageViewController *pageViewController;
@property (nonatomic) NSLayoutConstraint *titleBarHeightConstraint;

@end

@implementation LXPageViewController

#pragma mark - 构造方法

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		[self _commonInit];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		[self _commonInit];
	}
	return self;
}

- (void)_commonInit
{
	_titleScale = 1.1;
	_titleInset = 10.0;
	_scrollEnabled = YES;
	_titleBarHeight = 30.0;
	_targetIndex = NSNotFound;
	_selectedIndex = NSNotFound;
	_minimumTitleSpacing = 15.0;
	_selectedTitleColor = [UIColor redColor];
	_titleFont = [UIFont systemFontOfSize:15.0];
	_normalTitleColor = [UIColor lightGrayColor];
	_titleBarBackgroundColor = [UIColor whiteColor];
}

#pragma mark - 安装组件

- (void)_setupComponentsIfNeeded
{
	if (!self.titleBar) {
		[self _setupTitleBar];
	}

	if (!self.pageViewController) {
		[self _setupPageViewController];
	}
}

- (void)_setupTitleBar
{
	LXTitleBar *titleBar = [LXTitleBar new];
	titleBar.titleFont = self.titleFont;
	titleBar.titleScale = self.titleScale;
	titleBar.titleInset = self.titleInset;
	titleBar.normalTitleColor = self.normalTitleColor;
	titleBar.selectedTitleColor = self.selectedTitleColor;
	titleBar.backgroundColor = self.titleBarBackgroundColor;
	titleBar.minimumTitleSpacing = self.minimumTitleSpacing;
	titleBar.translatesAutoresizingMaskIntoConstraints = NO;
	self.titleBar = titleBar;

	[self.view addSubview:titleBar];

	__weak typeof(self) weakSelf = self;
	[titleBar setSelectTitleHandler:^(NSUInteger selectedIndex, NSString *selectedTitle) {
		__strong typeof(weakSelf) self = weakSelf;
		[self scrollToPageAtIndex:selectedIndex animated:YES completion:nil];
		!self.selectTitleItemHandler ?: self.selectTitleItemHandler(selectedIndex, selectedTitle, self.selectedViewController);
	}];

	id<UILayoutSupport> topLayoutGuide = self.topLayoutGuide;
	NSDictionary *views = NSDictionaryOfVariableBindings(titleBar, topLayoutGuide);
	NSDictionary *metrics = @{ @"titleBarHeight" : @(self.titleBarHeight) };
	NSString *visualFormats[] = { @"H:|[titleBar]|", @"V:[topLayoutGuide][titleBar(titleBarHeight)]" };
	for (int i = 0; i < 2; ++i) {
		[NSLayoutConstraint activateConstraints:
		 [NSLayoutConstraint constraintsWithVisualFormat:visualFormats[i]
												 options:kNilOptions
												 metrics:metrics
												   views:views]];
	}

	for (NSLayoutConstraint *constraint in self.titleBar.constraints) {
		if (constraint.firstAttribute == NSLayoutAttributeHeight) {
			self.titleBarHeightConstraint = constraint;
			break;
		}
	}
}

- (void)_setupPageViewController
{
	UIPageViewController *pageViewController =
	[[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
									navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
												  options:nil];
	pageViewController.delegate = self;
	pageViewController.dataSource = self;
	pageViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
	self.pageViewController = pageViewController;

	[self addChildViewController:pageViewController];
	[self.view addSubview:pageViewController.view];
	[pageViewController didMoveToParentViewController:self];

	UIView *containerView = pageViewController.view;
	id<UILayoutSupport> bottomLayoutGuide = self.bottomLayoutGuide;
	NSDictionary *views = NSDictionaryOfVariableBindings(_titleBar, containerView, bottomLayoutGuide);
	NSString *visualFormats[] = { @"H:|[containerView]|", @"V:[_titleBar][containerView][bottomLayoutGuide]" };
	for (int i = 0; i < 2; ++i) {
		[NSLayoutConstraint activateConstraints:
		 [NSLayoutConstraint constraintsWithVisualFormat:visualFormats[i]
												 options:kNilOptions
												 metrics:nil
												   views:views]];
	}

	// scrollView 的类型为 _UIQueuingScrollView，其 delegate 属性为 nil
	UIScrollView *scrollView = [pageViewController.view valueForKey:@"scrollView"];
	scrollView.panGestureRecognizer.maximumNumberOfTouches = 1;
	scrollView.scrollEnabled = self.scrollEnabled;
	scrollView.delegate = self;
	self.scrollView = scrollView;
}

#pragma mark - <UIPageViewControllerDataSource>

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
	  viewControllerBeforeViewController:(UIViewController *)viewController
{
	if (self.viewControllers.count == 0) {
		return nil;
	}

	NSUInteger indexOfViewController = [self.viewControllers indexOfObjectIdenticalTo:viewController];

	if (indexOfViewController == NSNotFound || indexOfViewController == 0) {
		return nil;
	}

	return self.viewControllers[indexOfViewController - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
	   viewControllerAfterViewController:(UIViewController *)viewController
{
	NSUInteger countOfViewControllers = self.viewControllers.count;

	if (countOfViewControllers == 0) {
		return nil;
	}

	NSUInteger indexOfViewController = [self.viewControllers indexOfObjectIdenticalTo:viewController];

	if (indexOfViewController == NSNotFound || indexOfViewController == countOfViewControllers - 1) {
		return nil;
	}

	return self.viewControllers[indexOfViewController + 1];
}

#pragma mark - <UIPageViewControllerDelegate>

- (void)pageViewController:(UIPageViewController *)pageViewController
willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers
{
	UIViewController *targetViewController = pendingViewControllers[0];
	NSUInteger indexOfTargetViewController = [self.viewControllers indexOfObjectIdenticalTo:targetViewController];

	NSAssert(indexOfTargetViewController != NSNotFound,
			 @"通过手势滑动页面时 indexOfTargetViewController 不应该为 NSNotFound");

	self.targetIndex = indexOfTargetViewController;
}

- (void)pageViewController:(UIPageViewController *)pageViewController
		didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers
	   transitionCompleted:(BOOL)completed
{
	// 位于左右边界时，若继续向边界外拖动，则会跳过 -pageViewController:willTransitionToViewControllers:，
	// 而直接调用 -pageViewController:didFinishAnimating:previousViewControllers:transitionCompleted:，
	// 这种情况下 self.targetIndex 会为 NSNotFound
	if (completed && self.targetIndex != NSNotFound) {
		self.selectedIndex = self.targetIndex;
	}
	self.targetIndex = NSNotFound;
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	self.isSlideProgessValid = YES;
	// 为了避免潜在问题，拖拽页面时就不允许拖拽标题栏
	self.titleBar.userInteractionEnabled = NO;

	[self.titleBar scrollSelectedTitleToVisible];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	// 位于左右边界时，若继续向边界外拖动，则会跳过 -pageViewController:willTransitionToViewControllers:，
	// 这种情况下 self.targetIndex 会为 NSNotFound，此时不要对滑块做处理
	if (!self.isSlideProgessValid || self.targetIndex == NSNotFound) {
		return;
	}

	// 正在拖拽或松手后处于减速滑动或者回弹中
	if (scrollView.isDragging || scrollView.isDecelerating) {
		CGFloat widthOfScrollView = CGRectGetWidth(scrollView.bounds);
		CGFloat contentOffsetX = scrollView.contentOffset.x;
		CGFloat progress = (contentOffsetX - widthOfScrollView) / widthOfScrollView;
		if (progress > -1.0 && progress < 1.0) {
			self.titleBar.slideProgress = progress;
		} else {
			// 大幅度滑动时，进度可能会溢出 [-1.0, +1.0] 闭区间，
			// 然后又会在回弹过程在重新落入 [-1.0, +1.0] 闭区间，
			// 因此一旦进度溢出，就判定到达最大值，并标记进度无效，忽略重新落入区间内的情况
			self.isSlideProgessValid = NO;
			self.view.userInteractionEnabled = NO;
			self.titleBar.slideProgress = (progress > 0 ? +1.0 : -1.0);
		}
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	// 为了避免潜在的问题，松手后会进入减速滑动状态则不允许再拖拽了
	if (decelerate) {
		self.view.userInteractionEnabled = NO;
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	// 减速滑动静止后重新开启交互功能
	self.view.userInteractionEnabled = YES;
	self.titleBar.userInteractionEnabled = YES;
}

#pragma mark - 设置外观

- (void)setTitleBarHeight:(CGFloat)titleBarHeight
{
	_titleBarHeight = titleBarHeight;

	self.titleBarHeightConstraint.constant = titleBarHeight;
}

- (void)setTitleScale:(CGFloat)titleScale
{
	_titleScale = titleScale;

	self.titleBar.titleScale = titleScale;
}

- (void)setTitleFont:(UIFont *)titleFont
{
	_titleFont = titleFont;

	self.titleBar.titleFont = titleFont;
}

- (void)setTitleInset:(CGFloat)titleInset
{
	_titleInset = titleInset;

	self.titleBar.titleInset = titleInset;
}

- (void)setMinimumTitleSpacing:(CGFloat)minimumTitleSpacing
{
	_minimumTitleSpacing = minimumTitleSpacing;

	self.titleBar.minimumTitleSpacing = minimumTitleSpacing;
}

- (void)setNormalTitleColor:(UIColor *)normalTitleColor
{
	_normalTitleColor = normalTitleColor;

	self.titleBar.normalTitleColor = normalTitleColor;
}

- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor
{
	_selectedTitleColor = selectedTitleColor;

	self.titleBar.selectedTitleColor = selectedTitleColor;
}

- (void)setTitleBarBackgroundColor:(UIColor *)titleBarBackgroundColor
{
	_titleBarBackgroundColor = titleBarBackgroundColor;

	self.titleBar.backgroundColor = titleBarBackgroundColor;
}

#pragma mark - 页面添加

- (void)addViewControllers:(NSArray<UIViewController *> *)viewControllers
				 forTitles:(NSArray<NSString *> *)titles
{
	NSAssert(titles.count > 1, @"标题数量必须大于1， %@", titles);
	NSAssert(viewControllers.count > 1, @"视图控制器数量必须大于1，%@", viewControllers);
	NSAssert(titles.count == viewControllers.count, @"标题和视图控制器数量必须相同");

	_titles = [titles valueForKey:@"copy"];
	_viewControllers = viewControllers.copy;
	self.countOfViewControllers = viewControllers.count;

	self.selectedIndex = 0;
	_selectedTitle = self.titles[0];
	_selectedViewController = self.viewControllers[0];

	[self _setupComponentsIfNeeded];

	[self.titleBar setTitles:self.titles];
	[self.pageViewController setViewControllers:@[self.selectedViewController]
									  direction:kNilOptions
									   animated:NO
									 completion:nil];
}

#pragma mark - 页面滚动

- (void)setScrollEnabled:(BOOL)scrollEnabled
{
	_scrollEnabled = scrollEnabled;

	self.scrollView.scrollEnabled = scrollEnabled;
}

- (void)scrollToPageAtIndex:(NSUInteger)index
				   animated:(BOOL)animated
				 completion:(void (^)(void))completion
{
	NSAssert(index < self.countOfViewControllers, @"滚动页面时索引越界，index: %@", @(index));

	if (index == self.selectedIndex) {
		return;
	}

	UIPageViewControllerNavigationDirection navigationDirection =
	index > self.selectedIndex ?
	UIPageViewControllerNavigationDirectionForward :
	UIPageViewControllerNavigationDirectionReverse;

	self.selectedIndex = index;
	_selectedTitle = self.titles[index];
	_selectedViewController = self.viewControllers[index];

	// 为了避免潜在问题，滚动中不允许交互
	if (animated) {
		self.view.userInteractionEnabled = NO;
	}

	[self.titleBar selectTitleAtIndex:index animated:animated];
	__weak typeof(self) weakSelf = self;
	[self.pageViewController setViewControllers:@[self.viewControllers[index]]
									  direction:navigationDirection
									   animated:animated
									 completion:^(BOOL finished) {
										 __strong typeof(weakSelf) self = weakSelf;
										 if (animated) {
											 self.view.userInteractionEnabled = YES;
										 }
										 !completion ?: completion();
									 }];
}

@end
