//
//  JWZPhotoViewer.m
//  JWZPhotoViewer
//
//  Created by J. W. Z. on 16/1/17.
//  Copyright © 2016年 J. W. Z. All rights reserved.
//

#import "JWZPhotoViewer.h"
#import "JWZPhotoView.h"

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

@property (nonatomic, strong) UIImageView *thumbnailImageView;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tap;

@end

@implementation JWZPhotoViewer

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    self.leftPhotoView.backgroundColor = [UIColor blackColor];
//    self.centerPhotoView.backgroundColor = [UIColor blueColor];
//    self.rightPhotoView.backgroundColor = [UIColor greenColor];
    
    NSLog(@"%s, %@", __func__, NSStringFromCGRect(self.view.bounds));
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"%s, %@", __func__, NSStringFromCGRect(self.view.bounds));
    _pageControl.numberOfPages = [[self dataSource] numberOfItemsForPhotoViewer:self];
    _pageControl.currentPage = _defaultIndex;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%s, %@", __func__, NSStringFromCGRect(self.view.bounds));
    self.pageControl.numberOfPages = [[self dataSource] numberOfItemsForPhotoViewer:self];
    self.pageControl.currentPage = self.defaultIndex;
    self.scrollView.contentOffset = CGPointMake(self.view.bounds.size.width, 0);
    [self scrollViewDidEndDecelerating:self.scrollView];
    
    
    [self.tap requireGestureRecognizerToFail:self.centerPhotoView->_twiceTap];
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

- (UIImageView *)thumbnailImageView {
    if (_thumbnailImageView != nil) {
        return _thumbnailImageView;
    }
    _thumbnailImageView = [[UIImageView alloc] init];
    [self.view addSubview:_thumbnailImageView];
    
    return _thumbnailImageView;
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _scrollView) {
        // 根据位置判断滚动方向
        JWZPhotoViewerScrollDirection scrollDirection = floor(scrollView.contentOffset.x / self.view.bounds.size.width) - 1;
        
        // 计算出每张图片的索引
        NSInteger previousCenterIndex = self.pageControl.currentPage;
        NSInteger centerIndex = [self indexWithPreviousIndex:previousCenterIndex scrollDirection:scrollDirection];
        NSInteger rightIndex = [self indexWithPreviousIndex:centerIndex scrollDirection:(JWZPhotoViewerScrollRight)];
        NSInteger leftIndex = [self indexWithPreviousIndex:centerIndex scrollDirection:(JWZPhotoViewerScrollLeft)];
        
        // 更改 pageControl 的值
        self.pageControl.currentPage = centerIndex;
        
        // 通过代理获取要显示的图片的 URL，并设置图片
        NSURL *rightURL  = [self.dataSource photoViewer:self imageURLForItemAtIndex:rightIndex];
        NSURL *centerURL = [self.dataSource photoViewer:self imageURLForItemAtIndex:centerIndex];
        NSURL *leftURL   = [self.dataSource photoViewer:self imageURLForItemAtIndex:leftIndex];
        
        [self.rightPhotoView setImageWithURL:rightURL placeholder:nil];
        [self.centerPhotoView setImageWithURL:centerURL placeholder:nil];
        [self.leftPhotoView setImageWithURL:leftURL placeholder:nil];
        
        // 将位置重置到中间
        self.scrollView.contentOffset = CGPointMake(self.view.bounds.size.width, 0);
    }
}

- (NSInteger)indexWithPreviousIndex:(NSInteger)index scrollDirection:(JWZPhotoViewerScrollDirection)direction {
    NSInteger count = [[self dataSource] numberOfItemsForPhotoViewer:self];
    return ABS(index + direction + count) % count;
}

#pragma mark - Center View Tap Action

- (IBAction)tapToDismissPhotoViewer:(id)sender {
    [self dismissViewControllerAnimated:NO completion:NULL];
}


@end
