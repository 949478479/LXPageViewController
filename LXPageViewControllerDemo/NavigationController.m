//
//  NavigationController.m
//
//  Created by 从今以后 on 16/5/21.
//  Copyright © 2016年 从今以后. All rights reserved.
//

#import "NavigationController.h"
#import "LXPageViewController.h"
#import "TableViewController.h"

@interface NavigationController () <LXPageViewControllerDataSource, LXPageViewControllerDelegate>
@property (nonatomic) NSArray *titles;
@property (nonatomic) NSMutableArray *pageViewControllers;
@end

@implementation NavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.titles =
  @[@"头条", @"要闻", @"娱乐娱乐", @"体育", @"时尚时尚", @"视频", @"读书", @"历史",  @"汽车", @"直播直播", @"科技", @"数码", @"运动运动"];
//      @[@"推荐", @"热门热门", @"资讯", @"最新"];

    NSUInteger count = self.titles.count;
    self.pageViewControllers = [NSMutableArray arrayWithCapacity:count];
    for (NSUInteger i = 0; i < count; ++i) {
        [self.pageViewControllers addObject:[NSNull null]];
    }

    LXPageViewControllerConfiguration *config = [LXPageViewControllerConfiguration new];
    config.titleScale = 1.2;
    config.titleBarHeight = 35;
    config.titleFont = [UIFont systemFontOfSize:13];

    LXPageViewController *pageViewController = self.viewControllers[0];
    pageViewController.configuration = config;
    pageViewController.dataSource = self;
    pageViewController.delegate = self;

    [pageViewController setInitialViewController:[self pageViewControllerAtIndex:1] index:1 titles:self.titles];

//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [pageViewController transitionToPageAtIndex:0 animated:YES completion:^{
//            NSLog(@"scrollToPageAtIndex:%@ completion", @(pageViewController.indexOfDisplayedPage));
//        }];
//    });
}

#pragma mark - 辅助方法

- (UIViewController *)pageViewControllerAtIndex:(NSInteger)index
{
    id viewController = self.pageViewControllers[index];
    if (viewController == [NSNull null]) {
        viewController = [TableViewController new];
        [viewController setTitle:self.titles[index]];
        self.pageViewControllers[index] = viewController;
    }
    return viewController;
}

#pragma mark - LXPageViewControllerDataSource

- (UIViewController *)pageViewController:(LXPageViewController *)pvc viewControllerAtIndex:(NSInteger)index {
    return [self pageViewControllerAtIndex:index];
}

#pragma mark - LXPageViewControllerDelegate

- (void)pageViewController:(LXPageViewController *)pageViewController willTransitionToViewController:(UIViewController *)pendingViewController index:(NSInteger)index {
    NSLog(@"willTransitionToViewController: %@, index: %ld, title: %@", pendingViewController, index, pageViewController.titles[index]);
}

- (void)pageViewController:(LXPageViewController *)pageViewController transitionCompleted:(BOOL)completed previousViewController:(UIViewController *)previousViewController index:(NSInteger)index {
    NSLog(@"transitionCompleted, previousViewController: %@, index: %ld, title: %@", previousViewController, index, pageViewController.titles[index]);
}

@end
