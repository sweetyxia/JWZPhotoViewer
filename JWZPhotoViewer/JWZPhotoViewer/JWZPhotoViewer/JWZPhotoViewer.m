//
//  JWZPhotoViewer.m
//  JWZPhotoViewer
//
//  Created by J. W. Z. on 16/1/17.
//  Copyright © 2016年 J. W. Z. All rights reserved.
//

#import "JWZPhotoViewer.h"
#import "JWZPhotoView.h"

#import "UIImageView+WebCache.h"

CGFloat const kJWZPhotoViewAnimationDuration = 0.4;

typedef NS_ENUM(NSInteger, JWZPhotoViewerScrollDirection) {
    JWZPhotoViewerScrollLeft = - 1,
    JWZPhotoViewerScrollNone,
    JWZPhotoViewerScrollRight
};

@interface JWZPhotoViewer () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UIView *wrapperView;

@property (weak, nonatomic) IBOutlet JWZPhotoView *leftPhotoView;
@property (weak, nonatomic) IBOutlet JWZPhotoView *centerPhotoView;
@property (weak, nonatomic) IBOutlet JWZPhotoView *rightPhotoView;

@property (weak, nonatomic) UIImageView *animationImageView;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tap;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *twiceTap;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPress;

@property (weak, nonatomic) IBOutlet UILabel *accessoryLabel;

@end

@implementation JWZPhotoViewer

+ (void)showFromViewController:(UIViewController *)viewController dataSource:(id<JWZPhotoViewerDataSource>)dataSource defaultIndex:(NSInteger)defaultIndex {
    JWZPhotoViewer *photoViewer = [[self alloc] init];
    photoViewer.currentIndex                  = defaultIndex;
    photoViewer.dataSource                    = dataSource;
    photoViewer.modalPresentationStyle        = UIModalPresentationOverCurrentContext;
    viewController.definesPresentationContext = YES;
    [viewController presentViewController:photoViewer animated:NO completion:NULL];
}

#pragma mark - Controller Lifetime

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //  手势
    self.centerPhotoView.imageView.userInteractionEnabled = YES;
    [self.tap requireGestureRecognizerToFail:self.twiceTap];
    
    if (self.dataSource != nil && [self.dataSource respondsToSelector:@selector(resoureViewForItemAtIndex:)]) {
        CGRect rect = [self convertedRectFromRescourceViewAtIndex:self.currentIndex];
        self.animationImageView.frame = rect;
        self.view.backgroundColor = [UIColor clearColor];
        self.scrollView.alpha = 0;
        self.pageControl.alpha = 0;
        NSURL *url = [self.dataSource photoViewer:self thumbnailURLForItemAtIndex:self.currentIndex];
        [self.animationImageView sd_setImageWithURL:url];
    } else {
        self.animationImageView.alpha = 0;
        self.scrollView.alpha = 1.0;
    }
    self.pageControl.numberOfPages = [[self dataSource] numberOfItemsForPhotoViewer:self];
    
    // 目前就用一个简陋的提示框吧
    self.accessoryLabel.alpha = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // NSLog(@"%s, %@", __func__, NSStringFromCGRect(self.view.bounds));
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // NSLog(@"%s, %@", __func__, NSStringFromCGRect(self.view.bounds));
    
    if (self.animationImageView.isHidden == NO) {
        [UIView animateWithDuration:kJWZPhotoViewAnimationDuration animations:^{
            self.animationImageView.center = self.view.center;
            self.view.backgroundColor = [UIColor blackColor];
        } completion:^(BOOL finished) {
            [self showPhotoAtIndex:self.currentIndex];
            [UIView animateWithDuration:kJWZPhotoViewAnimationDuration animations:^{
                self.animationImageView.frame = self.centerPhotoView.imageView.frame;
                self.animationImageView.image = self.centerPhotoView.imageView.image;
            } completion:^(BOOL finished) {
                self.pageControl.alpha        = 1.0;
                self.scrollView.alpha         = 1.0;
                self.animationImageView.alpha = 0;
            }];
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 属性

- (UIImageView *)animationImageView {
    if (_animationImageView != nil) {
        return _animationImageView;
    }
    UIImageView *imageView = [[UIImageView alloc] init];
    [self.view addSubview:imageView];
    _animationImageView = imageView;
    return _animationImageView;
}

#pragma mark - ScrollView 滚动代理

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView == _scrollView) {
        // 根据位置判断滚动方向
        JWZPhotoViewerScrollDirection scrollDirection = floor(scrollView.contentOffset.x / self.view.bounds.size.width) - 1;
        if (scrollDirection != JWZPhotoViewerScrollNone) {
            // 计算出每张图片的索引
            NSInteger previousIndex = self.currentIndex;
            NSInteger currentIndex = [self indexWithPreviousIndex:previousIndex scrollDirection:scrollDirection];
            // 展示图片
            [self showPhotoAtIndex:currentIndex];
        }
    }
}

#pragma mark - ScrollView 缩放代理

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (scrollView == self.centerPhotoView) {
        return self.centerPhotoView.imageView;
    }
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view {
    
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale {
    
}

#pragma mark - 自定义方法

/**
 *  展示指定的图片
 *
 *  @param index 图片的索引
 */
- (void)showPhotoAtIndex:(NSInteger)index {
    // 更改 pageControl 的值
    self.currentIndex = index;
    self.pageControl.currentPage = self.currentIndex;
    
    NSInteger rightIndex = [self indexWithPreviousIndex:index scrollDirection:(JWZPhotoViewerScrollRight)];
    NSInteger leftIndex = [self indexWithPreviousIndex:index scrollDirection:(JWZPhotoViewerScrollLeft)];
    
    // 通过代理获取要显示的图片的 URL，并设置图片
    NSURL *rightURL  = [self.dataSource photoViewer:self imageURLForItemAtIndex:rightIndex];
    NSURL *centerURL = [self.dataSource photoViewer:self imageURLForItemAtIndex:index];
    NSURL *leftURL   = [self.dataSource photoViewer:self imageURLForItemAtIndex:leftIndex];
    
    [self.rightPhotoView setImageWithURL:rightURL placeholder:nil];
    [self.centerPhotoView setImageWithURL:centerURL placeholder:nil];
    [self.leftPhotoView setImageWithURL:leftURL placeholder:nil];
    self.scrollView.contentOffset = CGPointMake(self.view.bounds.size.width, 0);
}

/**
 *  根据滚动前的 index 和滚动方向，计算现在的 index
 *
 *  @param index     滚动前的 index
 *  @param direction 滚动方向
 *
 *  @return 滚动后的 index
 */
- (NSInteger)indexWithPreviousIndex:(NSInteger)previousIndex scrollDirection:(JWZPhotoViewerScrollDirection)direction {
    NSInteger count = [[self dataSource] numberOfItemsForPhotoViewer:self];
    return ABS(previousIndex + direction + count) % count;
}

/**
 *  将 RescourceView 的 frame 转换到 window 里
 *
 *  @param index RescourceView 的索引
 *
 *  @return CGRect
 */
- (CGRect)convertedRectFromRescourceViewAtIndex:(NSInteger)index {
    UIView *senderView = [self.dataSource resoureViewForItemAtIndex:self.currentIndex];
    CGRect rect = CGRectZero;
    if (senderView != nil) {
        UIWindow *window = senderView.window;
        rect = [senderView.superview convertRect:senderView.frame toView:window];
    }
    return rect;
}

#pragma mark - Center View Tap Action

- (IBAction)tapToDismissPhotoViewer:(UITapGestureRecognizer *)sender {
    if (self.centerPhotoView.zoomScale > 1.0) {
        [self twiceTapAction:self.twiceTap];
    } else {
        if (self.dataSource != nil && [self.dataSource respondsToSelector:@selector(resoureViewForItemAtIndex:)]) {
            CGRect rect = [self convertedRectFromRescourceViewAtIndex:self.currentIndex];
            if (CGRectIsEmpty(rect)) {
                rect.origin = self.view.center;
            }
            self.animationImageView.frame = self.centerPhotoView.imageView.frame;
            self.animationImageView.image = self.centerPhotoView.imageView.image;
            self.animationImageView.alpha = 1.0;
            self.scrollView.alpha         = 0;
            self.pageControl.alpha        = 0;
            [UIView animateWithDuration:kJWZPhotoViewAnimationDuration animations:^{
                self.view.backgroundColor = [UIColor clearColor];
                NSURL *url = [self.dataSource photoViewer:self thumbnailURLForItemAtIndex:self.currentIndex];
                [self.animationImageView sd_setImageWithURL:url];
                self.animationImageView.frame = rect;
            } completion:^(BOOL finished) {
                [self dismissViewControllerAnimated:NO completion:NULL];
            }];
        } else {
            [self dismissViewControllerAnimated:NO completion:NULL];
        }
    }
}

#pragma mark - Page Control Events

- (IBAction)pageControlValueChanged:(UIPageControl *)sender {
    CGPoint newOffset = self.centerPhotoView.frame.origin;
    if (sender.currentPage < self.currentIndex) {
        if (sender.currentPage == 0 && self.currentIndex == (sender.numberOfPages - 1)) {
            newOffset = self.rightPhotoView.frame.origin;
        } else {
            newOffset = self.leftPhotoView.frame.origin;
        }
    } else {
        if (sender.currentPage == (sender.numberOfPages - 1) && self.currentIndex == 0) {
            newOffset = self.leftPhotoView.frame.origin;
        } else {
            newOffset = self.rightPhotoView.frame.origin;
        }
    }
    CGPoint currentOffset = self.scrollView.contentOffset;
    if (!CGPointEqualToPoint(newOffset, currentOffset)) {
        [self.scrollView setContentOffset:newOffset animated:YES];
    }
}

#pragma mark - 长按保存图片到相册

- (IBAction)longPressAction:(UILongPressGestureRecognizer *)tap {
    if (self.centerPhotoView.imageView.image != nil) {
        UIImageWriteToSavedPhotosAlbum(self.centerPhotoView.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo; {
    [self showMessage:@"图片已保存到相册" duration:2.0];
}

#pragma mark - 双击放大还原图片

- (IBAction)twiceTapAction:(UITapGestureRecognizer *)tap {
    NSLog(@"twiceTapAction:");
    if (self.centerPhotoView.imageView.image != nil) {
        CGSize imageViewSize = self.centerPhotoView.imageView.frame.size;
        CGSize selfSize = self.centerPhotoView.frame.size;
        
        CGFloat selfAspectRatio = selfSize.width / selfSize.height;
        CGFloat imageViewAspectRatio = imageViewSize.width / imageViewSize.height;
        
        CGRect newRect = self.centerPhotoView.imageView.frame;
        CGFloat scale = 0.0;
        if (self.centerPhotoView.zoomScale != 1.0) {
            scale = 1.0;
            if (selfAspectRatio < imageViewAspectRatio) {
                newRect.origin.y = (selfSize.height - imageViewSize.height / self.centerPhotoView.zoomScale) / 2.0;
            } else {
                newRect.origin.x = (selfSize.width - imageViewSize.width / self.centerPhotoView.zoomScale) / 2.0;
            }
        } else {
            if (selfAspectRatio < imageViewAspectRatio) {
                newRect.origin.y = 0;
                scale = selfSize.height / imageViewSize.height;
            } else {
                scale = selfSize.width / imageViewSize.width;
                newRect.origin.x = 0;
            }
        }
        if (scale != 0.0) {
            [UIView animateWithDuration:0.5 animations:^{
                self.centerPhotoView.imageView.frame = newRect;
                self.centerPhotoView.zoomScale = scale;
            }];
        }
    }
}

- (void)showMessage:(NSString *)message duration:(NSTimeInterval)duration {
    self.accessoryLabel.alpha = 1.0;
    self.accessoryLabel.text = message;
    [UIView animateWithDuration:duration animations:^{
        self.accessoryLabel.alpha = 0.0;
    }];
}

@end
