//
//  LXTitleBar.m
//
//  Created by 从今以后 on 16/12/27.
//  Copyright © 2016年 从今以后. All rights reserved.
//

#import "LXTitleBar.h"
#import "LXTitleBarCollectionView.h"
#import "LXTitleBarCollectionViewCell.h"

@interface LXTitleBar () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic) BOOL isLayoutReloading;
@property (nonatomic) BOOL isContentReloading;

@property (nonatomic) NSArray *itemWidthCache;
@property (nonatomic) NSArray *textSizeCache;

@property (nonatomic) CGFloat previousContentOffsetX;
@property (nonatomic) BOOL shouldRecordContentOffsetX;

@property (nonatomic) UIView *slider;
@property (nonatomic) LXTitleBarCollectionView *collectionView;

@end

@implementation LXTitleBar

#pragma mark - 构造方法

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
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
	_sliderHeight = 1;
	_titleScale = 1.1;
	_titleInset = 10.0;
	_minimumTitleSpacing = 15.0;
	_selectedIndex = NSNotFound;
	_shouldRecordContentOffsetX = YES;
	_selectedTitleColor = [UIColor redColor];
	_titleFont = [UIFont systemFontOfSize:15.0];
	_normalTitleColor = [UIColor lightGrayColor];

	[self _setupCollectionView];
	[self _setupSlider];
}

#pragma mark - 安装组件

- (void)_setupCollectionView
{
	LXTitleBarCollectionView *collectionView = [[LXTitleBarCollectionView alloc] initWithReuseIdentifier:@"LXTitleBarCollectionViewCell"];
	collectionView.delegate = self;
	collectionView.dataSource = self;
	collectionView.translatesAutoresizingMaskIntoConstraints = NO;
	collectionView.flowLayout.sectionInset = (UIEdgeInsets){
		0,
		self.titleInset - self. minimumTitleSpacing / 2,
		0,
		self.titleInset - self.minimumTitleSpacing / 2,
	};
	self.collectionView = collectionView;

	[self addSubview:collectionView];

	NSDictionary *views = NSDictionaryOfVariableBindings(collectionView);
	NSString *visualFormats[] = { @"H:|[collectionView]|", @"V:|[collectionView]|" };
	for (int i = 0; i < 2; ++i) {
		[NSLayoutConstraint activateConstraints:
		 [NSLayoutConstraint constraintsWithVisualFormat:visualFormats[i]
												 options:kNilOptions
												 metrics:nil
												   views:views]];
	}
}

- (void)_setupSlider
{
	[self.collectionView addSubview:self.slider = [UIView new]];
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.titles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	LXTitleBarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LXTitleBarCollectionViewCell" forIndexPath:indexPath];
	cell.titleFont = self.titleFont;
	cell.titleScale = self.titleScale;
	cell.title = self.titles[indexPath.item];
	cell.normalTitleColor = self.normalTitleColor;
	cell.selectedTitleColor = self.selectedTitleColor;
	cell.titleSize = [self.textSizeCache[indexPath.item] CGSizeValue];
	return cell;
}

#pragma mark - <UICollectionViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (self.shouldRecordContentOffsetX) {
		self.previousContentOffsetX = scrollView.contentOffset.x;
	}
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.item != self.selectedIndex) {
		[self _selectTitleAtIndex:indexPath.item];
		[self _scrollToItemAtIndexPath:indexPath animated:YES];
		[self _scrollSliderToItemAtIndexPath:indexPath animated:NO];
		!self.selectTitleHandler ?: self.selectTitleHandler(self.selectedIndex, self.selectedTitle);
	}
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView
				  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	[self _computeAndCacheTitleAndItemSizeIfNeeded];

	return CGSizeMake([self.itemWidthCache[indexPath.item] floatValue], CGRectGetHeight(collectionView.bounds));
}

#pragma mark - 获取布局属性

- (UICollectionViewLayoutAttributes *)_layoutAttributesForItemAtIndex:(NSUInteger)index
{
	NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
	return [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
}

#pragma mark - 设置布局

- (void)setTitleInset:(CGFloat)titleInset
{
	_titleInset = titleInset;

	self.collectionView.flowLayout.sectionInset = (UIEdgeInsets){
		0,
		titleInset - self.minimumTitleSpacing / 2,
		0,
		titleInset - self.minimumTitleSpacing / 2,
	};

	[self _invalidateLayout];
}

- (void)setMinimumTitleSpacing:(CGFloat)minimumTitleSpacing
{
	_minimumTitleSpacing = minimumTitleSpacing;

	self.collectionView.flowLayout.sectionInset = (UIEdgeInsets){
		0,
		self.titleInset - minimumTitleSpacing / 2,
		0,
		self.titleInset - minimumTitleSpacing / 2,
	};

	[self _invalidateLayout];
}

- (void)_invalidateLayout
{
	if (self.isLayoutReloading) {
		return;
	}
	self.isLayoutReloading = YES;

	self.itemWidthCache = nil;
	self.textSizeCache = nil;

	[UIView animateWithDuration:0 animations:^{
		[self.collectionView.collectionViewLayout invalidateLayout];
	} completion:^(BOOL finished) {
		self.isLayoutReloading = NO;
	}];
}

- (void)_computeAndCacheTitleAndItemSizeIfNeeded
{
	NSAssert(self.titles.count > 1, @"计算标题尺寸时标题数量必须大于1，titles：%@", self.titles);

	if (self.textSizeCache && self.itemWidthCache) {
		return;
	}

	int titlesCount = (int)self.titles.count;
	CGSize titleSizeArray[titlesCount];
	CGFloat itemWidthArray[titlesCount];

	CGFloat totalItemWidth = 0;
	CGFloat totalTextWidth = 0;

	NSMutableArray *titleSizeCache = [NSMutableArray arrayWithCapacity:titlesCount];

	int index = 0;
	for (NSString *title in self.titles) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
		CGSize textSize = [title sizeWithFont:self.titleFont];
#pragma clang diagnostic pop

		titleSizeArray[index] = textSize;
		totalTextWidth += titleSizeArray[index].width;
		[titleSizeCache addObject:[NSValue valueWithCGSize:titleSizeArray[index]]];

		itemWidthArray[index] = textSize.width + self.minimumTitleSpacing;
		totalItemWidth += itemWidthArray[index];

		++index;
	}

	NSMutableArray *itemWidthCache = [NSMutableArray arrayWithCapacity:titlesCount];
	for (int i = 0; i < titlesCount; ++i) {
		[itemWidthCache addObject:@(itemWidthArray[i])];
	}

	self.textSizeCache = titleSizeCache;
	self.itemWidthCache = itemWidthCache;
}

#pragma mark - 设置外观

- (void)setTitleScale:(CGFloat)titleScale
{
	_titleScale = titleScale;

	[self _reloadData];
}

- (void)setTitleFont:(UIFont *)titleFont
{
	_titleFont = titleFont;

	[self _reloadData];
}

- (void)setNormalTitleColor:(UIColor *)normalTitleColor
{
	_normalTitleColor = normalTitleColor;

	[self _reloadData];
}

- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor
{
	_selectedTitleColor = selectedTitleColor;

	self.slider.backgroundColor = selectedTitleColor;

	[self _reloadData];
}

- (void)_reloadData
{
	if (self.isContentReloading) {
		return;
	}
	self.isContentReloading = YES;

	[self _invalidateLayout];
	[UIView animateWithDuration:0 animations:^{
		[self.collectionView reloadData];
	} completion:^(BOOL finished) {
		self.isContentReloading = NO;
		[self _selectAndScrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex inSection:0] animated:NO];
	}];
}

#pragma mark - 设置标题

- (void)setTitles:(NSArray<NSString *> *)titles
{
	NSAssert(titles.count > 1, @"标题数量必须大于1，titles：%@", titles);

	_titles = [titles valueForKey:@"copy"];

	[self _selectTitleAtIndex:0];

	[self _reloadData];
}

#pragma mark - 选中标题

- (void)selectTitleAtIndex:(NSUInteger)index animated:(BOOL)animated
{
	[self _selectTitleAtIndex:index];

	if (self.collectionView.indexPathsForVisibleItems.count > 0) {
		[self _selectAndScrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex inSection:0] animated:animated];
	}
}

- (void)_selectTitleAtIndex:(NSUInteger)index
{
	NSAssert(index < self.titles.count, @"选中标题项时索引越界，index：%@", @(index));

	if (self.selectedIndex == index) {
		return;
	}
	_selectedIndex = index;
	_selectedTitle = self.titles[index];
}

- (void)_selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
	[self.collectionView selectItemAtIndexPath:indexPath animated:animated scrollPosition:UICollectionViewScrollPositionNone];
}

- (void)_selectAndScrollToItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
	[self _selectItemAtIndexPath:indexPath animated:animated];
	[self _scrollToItemAtIndexPath:indexPath animated:animated];
	[self _scrollSliderToItemAtIndexPath:indexPath animated:animated];
}

#pragma mark - 滑动标题

- (void)setSlideProgress:(CGFloat)slideProgress
{
	slideProgress = fmax(-1.0, fmin(slideProgress, +1.0));
	if (slideProgress == self.slideProgress) {
		return;
	}
	_slideProgress = slideProgress;

	NSUInteger targetIndex = NSNotFound;
	if (slideProgress > 0.0) {
		NSAssert(self.selectedIndex < self.titles.count - 1,
				 @"设置滑动进度时索引越界，slideProgress：%f, selectedIndex：%lu",
				 self.slideProgress, self.selectedIndex);
		targetIndex = self.selectedIndex + 1;
	} else if (slideProgress < 0.0) {
		NSAssert(self.selectedIndex >= 1,
				 @"设置滑动进度时索引越界，slideProgress：%f, selectedIndex：%lu",
				 self.slideProgress, self.selectedIndex);
		targetIndex = self.selectedIndex - 1;
	} else {
		targetIndex = self.selectedIndex;
	}

	[self _renderTitleBySlideProgressWithTargetIndex:targetIndex];
	[self _scrollSliderBySlideProgressWithTargetIndex:targetIndex];
	[self _scrollCollectionViewBySlideProgressWithTargetIndex:targetIndex];

	if (slideProgress == +1.0 || slideProgress == -1.0) {
		_slideProgress = 0.0;
		[self _selectTitleAtIndex:targetIndex];
		[self setPreviousContentOffsetX:self.collectionView.contentOffset.x];
		[self _selectItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] animated:NO];
	}
}

- (void)_renderTitleBySlideProgressWithTargetIndex:(NSUInteger)targetIndex
{
	NSIndexPath *currrentIndexPath = [NSIndexPath indexPathForItem:self.selectedIndex inSection:0];
	LXTitleBarCollectionViewCell *currentCell = (LXTitleBarCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:currrentIndexPath];
	currentCell.gradient = self.slideProgress;

	if (self.selectedIndex != targetIndex) {
		NSIndexPath *targetIndexPath = [NSIndexPath indexPathForItem:targetIndex inSection:0];
		LXTitleBarCollectionViewCell *targetCell = (LXTitleBarCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:targetIndexPath];
		if (self.slideProgress > 0.0) {
			targetCell.gradient = self.slideProgress - 1.0;
		} else if (self.slideProgress < 0.0) {
			targetCell.gradient = self.slideProgress + 1.0;
		} else {
			NSAssert(NO, @"不应该存在这种情况：%f", self.slideProgress);
		}
	}
}

- (void)_scrollSliderBySlideProgressWithTargetIndex:(NSUInteger)targetIndex
{
	CGFloat progress = fabs(self.slideProgress);

	self.slider.frame = ({
		CGFloat currentWidth = [self.textSizeCache[self.selectedIndex] CGSizeValue].width * self.titleScale + self.sliderExtendedWidth;
		CGFloat targetWidth = currentWidth;
		if (self.selectedIndex != targetIndex) {
			targetWidth = [self.textSizeCache[targetIndex] CGSizeValue].width * self.titleScale + self.sliderExtendedWidth;
		}
		CGRect frame = self.slider.frame;
		frame.size.width = currentWidth + progress * (targetWidth - currentWidth);
		frame;
	});

	self.slider.center = ({
		CGFloat currentCenterX = [self _layoutAttributesForItemAtIndex:self.selectedIndex].center.x;
		CGFloat targetCenterX = currentCenterX;
		if (self.selectedIndex != targetIndex) {
			targetCenterX = [self _layoutAttributesForItemAtIndex:targetIndex].center.x;
		}
		CGPoint center = self.slider.center;
		center.x = currentCenterX + progress * (targetCenterX - currentCenterX);
		center;
	});
}

- (void)_scrollCollectionViewBySlideProgressWithTargetIndex:(NSUInteger)targetIndex
{
	CGFloat delta = 0.0;
	UICollectionViewLayoutAttributes *targetAttributes = [self _layoutAttributesForItemAtIndex:targetIndex];

	if (self.slideProgress > 0.0) {
		CGFloat visibleMaxX = self.previousContentOffsetX + CGRectGetWidth(self.bounds);
		delta = CGRectGetMaxX(targetAttributes.frame) - visibleMaxX;
	} else if (self.slideProgress < 0.0) {
		CGFloat visibleMinX = self.previousContentOffsetX;
		delta = visibleMinX - CGRectGetMinX(targetAttributes.frame);
	}

	if (delta > 0.0) {
		self.shouldRecordContentOffsetX = NO;
		self.collectionView.contentOffset = (CGPoint){.x = self.previousContentOffsetX + delta * self.slideProgress};
		self.shouldRecordContentOffsetX = YES;
	}
}

- (void)scrollSelectedTitleToVisible
{
	NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.selectedIndex inSection:0];
	[self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

- (void)_scrollToItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
	[self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:animated];
}

- (void)_scrollSliderToItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
	if (animated) {
		self.userInteractionEnabled = NO;
	}

	CGSize textSize = [self.textSizeCache[indexPath.item] CGSizeValue];
	CGFloat sliderWidth = textSize.width * self.titleScale + self.sliderExtendedWidth;
	CGFloat centerX = [self _layoutAttributesForItemAtIndex:indexPath.item].center.x;

	[UIView animateWithDuration:(animated ? 0.3 : 0.0) animations:^{
		self.slider.frame = (CGRect){
			0,
			CGRectGetMidY(self.bounds) + textSize.height * self.titleScale * 0.5,
			sliderWidth,
			self.sliderHeight,
		};
		self.slider.center = ({
			CGPoint center = self.slider.center;
			center.x = centerX;
			center;
		});
	} completion:^(BOOL finished) {
		self.userInteractionEnabled = YES;
	}];
}

@end
