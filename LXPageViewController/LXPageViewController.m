//
//  LXPageViewController.m
//
//  Created by 从今以后 on 16/12/27.
//  Copyright © 2016年 从今以后. All rights reserved.
//

@import ObjectiveC.runtime;
#import "LXPageViewController.h"
#import "LXTitleBar.h"

@implementation UIViewController (LXIndex)

- (void)lx_setIndex:(NSInteger)index {
    objc_setAssociatedObject(self, @selector(lx_index), @(index), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)lx_index {
    id value = objc_getAssociatedObject(self, _cmd);
    if (value) {
        return [value integerValue];
    }
    return NSNotFound;
}

@end

@implementation LXPageViewControllerConfiguration

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self _commonInit];
}

- (void)_commonInit
{
    _scrollEnabled = YES;
    _titleBarHeight = 35;
    _titleBarBackgroundColor = [UIColor whiteColor];

    _titleScale = 1.1;
    _titleInset = 10.0;
    _minimumTitleSpacing = 15.0;
    _titleFont = [UIFont systemFontOfSize:15.0];

    _selectedTitleColor = [UIColor redColor];
    _normalTitleColor = [UIColor lightGrayColor];

    _sliderHeight = 2;
    _sliderExtendedWidth = 0;
}

@end

@interface LXPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate>
{
    struct {
        BOOL didSelectViewControllerAtIndex;
        BOOL willTransitionToViewController;
        BOOL transitionCompleted;
    } _delegateFlags;
}

@property (nonatomic) BOOL scrollEnabled;
@property (nonatomic) CGFloat titleBarHeight;
@property (nonatomic) UIColor *titleBarBackgroundColor;

@property (nonatomic) LXTitleBar *titleBar;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIPageViewController *pageViewController;
@property (nonatomic) NSLayoutConstraint *titleBarHeightConstraint;

@property (nonatomic) BOOL isSlideProgessValid;
@property (nonatomic) NSUInteger indexOfPendingViewController;

@property (nonatomic) NSArray<NSString *> *titles;
@property (nonatomic) NSString *titleOfDisplayedPage;
@property (nonatomic) NSInteger indexOfDisplayedPage;

@end

@implementation LXPageViewController

#pragma mark - 构造方法

- (instancetype)initWithConfiguration:(LXPageViewControllerConfiguration *)configuration
{
	self = [super init];
	if (self) {
		[self _commonInitWithConfiguration:configuration];
        [self _setupComponentIfNeeded];
	}
	return self;
}

- (void)setConfiguration:(LXPageViewControllerConfiguration *)configuration
{
    NSParameterAssert(configuration != nil);
    NSParameterAssert(_configuration == nil);

    if (configuration && !_configuration) {
        [self _commonInitWithConfiguration:configuration];
        [self _setupComponentIfNeeded];
    }
}

- (void)_commonInitWithConfiguration:(LXPageViewControllerConfiguration *)configuration
{
    _configuration = configuration;

	_scrollEnabled = _configuration.scrollEnabled;
	_titleBarHeight = _configuration.titleBarHeight;
	_titleBarBackgroundColor = _configuration.titleBarBackgroundColor;

	_indexOfDisplayedPage = NSNotFound;
	_indexOfPendingViewController = NSNotFound;
}

#pragma mark - 添加组件

- (void)_setupComponentIfNeeded
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
    LXTitleBar *titleBar = [[LXTitleBar alloc] initWithConfiguration:(LXTitleBarConfiguration *)self.configuration];
    titleBar.backgroundColor = self.titleBarBackgroundColor;
    titleBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleBar = titleBar;

    [self.view addSubview:titleBar];

    __weak typeof(self) weakSelf = self;
    [titleBar setSelectTitleHandler:^(NSInteger selectedIndex, NSString *selectedTitle) {
        __strong typeof(weakSelf) self = weakSelf;
        [self _transitionToPageAtIndex:selectedIndex animated:YES invokeDelegateMethod:YES completion:nil];
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

    for (NSLayoutConstraint *constraint in titleBar.constraints) {
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

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
	  viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [viewController lx_index];
    if (index == 0) {
        return nil;
    }
    UIViewController *previousViewController = [self.dataSource pageViewController:self viewControllerAtIndex:index - 1];
    [previousViewController lx_setIndex:index - 1];
    return previousViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
	   viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [viewController lx_index];
    if (index == self.titles.count - 1) {
        return nil;
    }
    UIViewController *nextViewController = [self.dataSource pageViewController:self viewControllerAtIndex:index + 1];
    [nextViewController lx_setIndex:index + 1];
    return nextViewController;
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController
willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers
{
	UIViewController *pendingViewController = pendingViewControllers[0];
    NSUInteger indexOfPendingViewController = [pendingViewController lx_index];
	NSAssert(indexOfPendingViewController != NSNotFound,
			 @"通过手势滑动页面时 indexOfPendingViewController 不应该为 NSNotFound");
	self.indexOfPendingViewController = indexOfPendingViewController;

    if (_delegateFlags.willTransitionToViewController) {
        [self.delegate pageViewController:self
           willTransitionToViewController:pendingViewController
                                    index:indexOfPendingViewController];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController
		didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers
	   transitionCompleted:(BOOL)completed
{
	// 位于左右边界时，若继续向边界外拖动，则会跳过 -pageViewController:willTransitionToViewControllers:，
	// 而直接调用 -pageViewController:didFinishAnimating:previousViewControllers:transitionCompleted:，
	// 这种情况下 self.indexOfSelectedViewController 会为 NSNotFound
	if (completed && self.indexOfPendingViewController != NSNotFound) {
		self.indexOfDisplayedPage = self.indexOfPendingViewController;
	}
	self.indexOfPendingViewController = NSNotFound;

    if (_delegateFlags.transitionCompleted) {
        UIViewController *previousViewController = previousViewControllers[0];
        NSInteger index = [previousViewController lx_index];
        [self.delegate pageViewController:self
                      transitionCompleted:completed
                   previousViewController:previousViewController
                                    index:index];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	self.isSlideProgessValid = YES;
	// 为了避免潜在问题，拖拽页面时就不允许拖拽标题栏
	self.titleBar.userInteractionEnabled = NO;

	[self.titleBar scrollSelectedItemToVisible];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	// 位于左右边界时，若继续向边界外拖动，则会跳过 -pageViewController:willTransitionToViewControllers:，
	// 这种情况下 self.targetIndex 会为 NSNotFound，此时不要对滑块做处理
	if (!self.isSlideProgessValid || self.indexOfPendingViewController == NSNotFound) {
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
	if (decelerate) {
        // 滑动减速过程中禁止交互
		self.view.userInteractionEnabled = NO;
    } else {
        [self.titleBar scrollSelectedItemToCenter];
        // 没有滑动减速过程，恢复标题栏的交互
        self.titleBar.userInteractionEnabled = YES;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	self.view.userInteractionEnabled = YES;
    self.titleBar.userInteractionEnabled = YES;

    [self.titleBar scrollSelectedItemToCenter];
}

#pragma mark - 设置代理

- (void)setDelegate:(id<LXPageViewControllerDelegate>)delegate {
	_delegate = delegate;
	_delegateFlags.willTransitionToViewController = [delegate respondsToSelector:@selector(pageViewController:willTransitionToViewController:index:)];
	_delegateFlags.transitionCompleted = [delegate respondsToSelector:@selector(pageViewController:transitionCompleted:previousViewController:index:)];
}

#pragma mark - 设置外观

- (void)setTitleBarHeight:(CGFloat)titleBarHeight {
	_titleBarHeight = titleBarHeight;
	self.titleBarHeightConstraint.constant = titleBarHeight;
}

- (void)setTitleBarBackgroundColor:(UIColor *)titleBarBackgroundColor {
	_titleBarBackgroundColor = titleBarBackgroundColor;
	self.titleBar.backgroundColor = titleBarBackgroundColor;
}

#pragma mark - 计算属性

- (UIViewController *)viewControllerOfDisplayedPage {
	return self.pageViewController.viewControllers.firstObject;
}

#pragma mark - 页面滑动

- (void)setScrollEnabled:(BOOL)scrollEnabled {
	_scrollEnabled = scrollEnabled;
	self.scrollView.scrollEnabled = scrollEnabled;
}

- (void)_transitionToPageAtIndex:(NSUInteger)index
                        animated:(BOOL)animated
            invokeDelegateMethod:(BOOL)invokeDelegateMethod
                      completion:(void (^)(void))completion
{
    NSParameterAssert(self.dataSource != nil);

    if (!self.dataSource) {
        return;
    }
    
    if (index == self.indexOfDisplayedPage) {
        return;
    }

    if (animated) {
        self.view.userInteractionEnabled = NO;
    }

    UIPageViewControllerNavigationDirection navigationDirection =
    index > self.indexOfDisplayedPage ?
    UIPageViewControllerNavigationDirectionForward :
    UIPageViewControllerNavigationDirectionReverse;

    UIViewController *targetViewController = [self.dataSource pageViewController:self viewControllerAtIndex:index];
    [targetViewController lx_setIndex:index];

    if (invokeDelegateMethod && _delegateFlags.willTransitionToViewController) {
        [self.delegate pageViewController:self willTransitionToViewController:targetViewController index:index];
    }

    __weak typeof(self) weakSelf = self;
    [self.pageViewController setViewControllers:@[targetViewController]
                                      direction:navigationDirection
                                       animated:animated
                                     completion:^(BOOL finished) {
                                         __strong typeof(weakSelf) self = weakSelf;

                                         if (animated) {
                                             self.view.userInteractionEnabled = YES;
                                         }

                                         NSInteger previousIndex = self.indexOfDisplayedPage;
                                         UIViewController *previousViewController = self.viewControllerOfDisplayedPage;

                                         self.indexOfDisplayedPage = index;
                                         self.titleOfDisplayedPage = self.titles[index];

                                         if (invokeDelegateMethod && self->_delegateFlags.transitionCompleted) {
                                             [self.delegate pageViewController:self
                                                           transitionCompleted:YES
                                                        previousViewController:previousViewController
                                                                         index:previousIndex];
                                         }

                                         !completion ?: completion();
                                     }];
}

- (void)transitionToPageAtIndex:(NSInteger)index
                       animated:(BOOL)animated
                     completion:(void (^)(void))completion
{
    NSParameterAssert(self.dataSource != nil);

    if (self.dataSource && self.indexOfDisplayedPage != index) {
        [self.titleBar selectTitleAtIndex:index animated:animated];
        [self _transitionToPageAtIndex:index animated:animated invokeDelegateMethod:NO completion:completion];
    }
}

#pragma mark - 设置内容

- (void)setInitialViewController:(UIViewController *)viewController index:(NSInteger)index titles:(NSArray<NSString *> *)titles
{
    NSParameterAssert(viewController != nil);
    NSParameterAssert(titles.count > 0);
    
    self.titles = titles;

    [self.titleBar setTitles:titles selectedIndex:index];

    [viewController lx_setIndex:index];
    __weak typeof(self) weakSelf = self;
    [self.pageViewController setViewControllers:@[viewController] direction:kNilOptions animated:NO completion:^(BOOL finished) {
        __strong typeof(weakSelf) self = weakSelf; if (!self) return;
        self.indexOfDisplayedPage = index;
        self.titleOfDisplayedPage = titles[index];
    }];
}

@end
