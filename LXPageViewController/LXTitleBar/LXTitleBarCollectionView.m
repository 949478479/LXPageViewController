//
//  LXTitleBarCollectionView.m
//
//  Created by 从今以后 on 16/12/27.
//  Copyright © 2016年 从今以后. All rights reserved.
//

#import "LXTitleBarCollectionView.h"
#import "LXTitleBarCollectionViewCell.h"

@implementation LXTitleBarCollectionView

- (instancetype)initWithReuseIdentifier:(NSString *)identifier
{
	UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
	layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
	layout.minimumInteritemSpacing = 0;
	layout.minimumLineSpacing = 0;
	
	self = [super initWithFrame:CGRectZero collectionViewLayout:layout];
	if (self) {
		_flowLayout = layout;
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
		self.alwaysBounceHorizontal = YES;
		self.showsVerticalScrollIndicator = NO;
		self.showsHorizontalScrollIndicator = NO;
		self.backgroundColor = [UIColor clearColor];
		[self registerClass:[LXTitleBarCollectionViewCell class] forCellWithReuseIdentifier:identifier];
	}
	return self;
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
	// 避免 UIViewController 的 automaticallyAdjustsScrollViewInsets 属性影响 contentInset 。
}

@end
