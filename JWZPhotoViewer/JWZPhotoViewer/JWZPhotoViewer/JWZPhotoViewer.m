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

@property (nonatomic, readonly) CGSize contentSize;

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
    _contentSize = self.view.bounds.size;
    CGPoint point = CGPointMake(_contentSize.width, 0);
    self.scrollView.contentOffset = point;
    NSInteger index = _defaultIndex;
    NSString *url = [_dataSource photoViewer:self imageURLForItemAtIndex:index];
    [_centerPhotoView setImageWithUrl:[NSURL URLWithString:url]];
    index = [self indexForCurrentItemWithPreviousIndex:_defaultIndex scrollDirection:(JWZPhotoViewerScrollLeft)];
    url = [_dataSource photoViewer:self imageURLForItemAtIndex:index];
    [_leftPhotoView setImageWithUrl:[NSURL URLWithString:url]];
    index = [self indexForCurrentItemWithPreviousIndex:_defaultIndex scrollDirection:(JWZPhotoViewerScrollRight)];
    url = [_dataSource photoViewer:self imageURLForItemAtIndex:index];
    [_rightPhotoView setImageWithUrl:[NSURL URLWithString:url]];
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
        JWZPhotoViewerScrollDirection scrollDirection = floor(scrollView.contentOffset.x / _contentSize.width) - 1;
        if (scrollDirection != JWZPhotoViewerScrollNone) {
            NSInteger previousIndex = self.pageControl.currentPage;
            NSInteger currentIndex = [self indexForCurrentItemWithPreviousIndex:previousIndex scrollDirection:scrollDirection];
            self.pageControl.currentPage = currentIndex;
            JWZPhotoView *firstPhotoView = nil, *secondPhotoView = nil;
            if (scrollDirection == JWZPhotoViewerScrollLeft) {
                firstPhotoView = _rightPhotoView;
                secondPhotoView = _leftPhotoView;
            } else {
                firstPhotoView = _leftPhotoView;
                secondPhotoView = _rightPhotoView;
            }
            [firstPhotoView setImageWithUrl:_centerPhotoView.imageUrl];
            [_centerPhotoView setImageWithUrl:secondPhotoView.imageUrl];
            self.scrollView.contentOffset = CGPointMake(_contentSize.width, 0);
            NSInteger nextIndex = [self indexForCurrentItemWithPreviousIndex:currentIndex scrollDirection:scrollDirection];
            NSString *url = [_dataSource photoViewer:self imageURLForItemAtIndex:nextIndex];
            [secondPhotoView setImageWithUrl:[NSURL URLWithString:url]];
        }
    }
}

- (NSInteger)indexForCurrentItemWithPreviousIndex:(NSInteger)index scrollDirection:(JWZPhotoViewerScrollDirection)direction {
    NSInteger count = [[self dataSource] numberOfItemsForPhotoViewer:self];
    return ABS(index + direction + count) % count;
}

#pragma mark - Center View Tap Action

- (IBAction)tapToDismissPhotoViewer:(id)sender {
    [self dismissViewControllerAnimated:NO completion:NULL];
}


@end
