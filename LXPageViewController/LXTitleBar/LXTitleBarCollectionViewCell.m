//
//  LXTitleBarCollectionViewCell.m
//
//  Created by 从今以后 on 16/12/27.
//  Copyright © 2016年 从今以后. All rights reserved.
//

#import "LXTitleBarCollectionViewCell.h"

@interface LXTitleBarCollectionViewCell ()

@property (nonatomic) UIView *bgView;
@property (nonatomic) UILabel *maskLabel;
@property (nonatomic) CGAffineTransform _transform;

@end

@implementation LXTitleBarCollectionViewCell

#pragma mark - 构造方法

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		UILabel *label = [[UILabel alloc] initWithFrame:frame];
		label.textAlignment = NSTextAlignmentCenter;
		_maskLabel = label;
		self.maskView = label;

		UIView *bgView = [UIView new];
		_bgView = bgView;
		[self.contentView addSubview:bgView];

		_gradient = -1.0;
		_titleScale = 1.0;
		__transform = CGAffineTransformIdentity;
	}
	return self;
}

#pragma mark - 调整布局

- (void)layoutSubviews
{
	[super layoutSubviews];

	[self _updateMaskViewFrame];
}

- (void)_updateTransform
{
	CGFloat scale = self.titleScale - (self.titleScale - 1.0) * fabs(self.gradient);
	self._transform = CGAffineTransformMakeScale(scale, scale);
}

- (void)_updateMaskAndBackgroundViewFrame
{
	[self _updateMaskViewFrame];
	[self _updateBackgroundViewFrame];
}

- (void)_updateMaskViewFrame
{
	self.maskLabel.transform = CGAffineTransformIdentity;
	self.maskLabel.frame = self.bounds;
	self.maskLabel.transform = self._transform;
}

- (void)_updateBackgroundViewFrame
{
	self.bgView.transform = CGAffineTransformIdentity;

	self.bgView.frame = (CGRect){
		.size = self.titleSize,
	};
	self.bgView.center = (CGPoint){
		CGRectGetMidX(self.bounds) + self.gradient * self.titleSize.width,
		CGRectGetMidY(self.bounds),
	};

	self.bgView.transform = self._transform;
}

#pragma mark - 设置标题

- (void)setTitle:(NSString *)title
{
	_title = title.copy;

	self.maskLabel.text = title;
}

- (void)setTitleSize:(CGSize)titleSize
{
	_titleSize = titleSize;

	[self _updateMaskAndBackgroundViewFrame];
}

#pragma mark - 设置标题外观

- (void)setTitleFont:(UIFont *)font
{
	_titleFont = font;

	self.maskLabel.font = font;
}

- (void)setNormalTitleColor:(UIColor *)normalColor
{
	_normalTitleColor = normalColor;

	self.backgroundColor = normalColor;
}

- (void)setSelectedTitleColor:(UIColor *)selectedColor
{
	_selectedTitleColor = selectedColor;

	self.bgView.backgroundColor = selectedColor;
}

#pragma mark - 设置标题缩放

- (void)setTitleScale:(CGFloat)scale
{
	scale = fmax(1.0, scale);
	if (scale == self.titleScale) {
		return;
	}
	_titleScale = scale;

	[self _updateTransform];
	[self _updateMaskAndBackgroundViewFrame];
}

#pragma mark - 设置渐变

- (void)setGradient:(CGFloat)gradient
{
	gradient = fmax(-1.0, fmin(gradient, +1.0));
	if (gradient == self.gradient) {
		return;
	}
	_gradient = gradient;

	[self _updateTransform];
	[self _updateMaskAndBackgroundViewFrame];
}

#pragma mark - 选中状态

- (void)setSelected:(BOOL)selected
{
	[super setSelected:selected];

	self.gradient = (selected ? 0.0 : 1.0);
}

#pragma mark - 复用清理

- (void)prepareForReuse
{
	[super prepareForReuse];

	_gradient = -1.0;
	_titleScale = 1.0;
	__transform = CGAffineTransformIdentity;
	
	self.bgView.frame = CGRectZero;
}

@end
