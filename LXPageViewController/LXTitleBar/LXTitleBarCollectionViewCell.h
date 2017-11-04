//
//  LXTitleBarCollectionViewCell.h
//
//  Created by 从今以后 on 16/12/27.
//  Copyright © 2016年 从今以后. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LXTitleBarCollectionViewCell : UICollectionViewCell

/// 取值范围 -1.0~1.0
/// 0.0 表示选中状态，-1.0 和 +1.0 表示普通状态
/// (-1.0, 0.0) 和 (0.0, +1.0) 开区间表示过渡状态
@property (nonatomic) CGFloat gradient;
/// 标题在完全选中状态下的放大比率
@property (nonatomic) CGFloat titleScale;
/// 标题文本尺寸
@property (nonatomic) CGSize titleSize;
/// 标题字体
@property (nonatomic) UIFont *titleFont;
/// 标题文本
@property (nonatomic, copy) NSString *title;
/// 普通状态标题颜色
@property (nonatomic) UIColor *normalTitleColor;
/// 选中状态标题颜色
@property (nonatomic) UIColor *selectedTitleColor;

@end

NS_ASSUME_NONNULL_END
