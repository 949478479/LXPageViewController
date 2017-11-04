//
//  LXTitleBarCollectionView.h
//
//  Created by 从今以后 on 16/12/27.
//  Copyright © 2016年 从今以后. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LXTitleBarCollectionView : UICollectionView

/// cell 重用标识符
- (instancetype)initWithReuseIdentifier:(NSString *)identifier;

@property (nonatomic, readonly) UICollectionViewFlowLayout *flowLayout;

@end

NS_ASSUME_NONNULL_END
