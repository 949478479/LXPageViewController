//
//  NavigationController.m
//
//  Created by 从今以后 on 16/5/21.
//  Copyright © 2016年 从今以后. All rights reserved.
//

#import "NavigationController.h"
#import "LXPageViewController.h"
#import "TableViewController.h"

@implementation NavigationController

- (void)awakeFromNib
{
    [super awakeFromNib];

    NSMutableArray *viewControllers = [NSMutableArray new];
	NSArray *titles =
//  @[@"推荐", @"热门热门", @"资讯", @"最新"];
 @[@"头条", @"要闻", @"娱乐娱乐", @"体育", @"时尚时尚", @"视频", @"读书", @"历史",  @"汽车", @"直播直播", @"科技", @"数码", @"运动运动"];
	for (NSString *title in titles) {
		UIViewController *vc = [TableViewController new];
		vc.title = title;
		[viewControllers addObject:vc];
	}

    LXPageViewController *pageViewController = self.viewControllers[0];

    [pageViewController setSelectTitleItemHandler: ^(NSUInteger index, NSString *title, UIViewController *vc){
        NSLog(@"索引：%@，标题：%@，控制器：%@", @(index), title, vc);
    }];

    [pageViewController addViewControllers:viewControllers forTitles:titles];

    [pageViewController scrollToPageAtIndex:1 animated:NO completion:^{
		NSLog(@"scrollToPageAtIndex:%@ completion", @(pageViewController.selectedIndex));
	}];

//	pageViewController.titleScale = 1.2;
//	pageViewController.titleBarHeight = 35;
//	pageViewController.titleFont = [UIFont systemFontOfSize:13];
}

@end
