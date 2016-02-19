//
//  JWZPhotoView.m
//  JWZPhotoViewer
//
//  Created by J. W. Z. on 16/1/17.
//  Copyright © 2016年 J. W. Z. All rights reserved.
//

#import "JWZPhotoView.h"
#import "UIImageView+WebCache.h"

@interface JWZPhotoView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;

@end


@implementation JWZPhotoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self viewDidInitialize];
    }
    return self;
}

/**
 *  视图初始化的一些操作
 */
- (void)viewDidInitialize {
    self.maximumZoomScale       = CGFLOAT_MAX;
    self.minimumZoomScale       = 0.5;
    self.bounces                = YES;
    self.alwaysBounceHorizontal = YES;
    self.alwaysBounceVertical   = YES;
    [self.imageView addObserver:self forKeyPath:@"image" options:(NSKeyValueObservingOptionNew) context:nil];
}

- (void)dealloc {
    [self.imageView removeObserver:self forKeyPath:@"image"];
}

/**
 *  从 nib 中加载的
 */
- (void)awakeFromNib {
    [super awakeFromNib];
    [self viewDidInitialize];
}

/**
 *  重写代理的 setter 方法。本类的代理方法由自己实现。
 *
 *  @param delegate 代理
 */
//- (void)setDelegate:(id<UIScrollViewDelegate>)delegate {
//    if (delegate == nil) {
//        [super setDelegate:delegate];
//    } else {
//        NSException *exception = [NSException exceptionWithName:@"禁止调用的方法" reason:@"视图的代理方法已经处理，禁止设置此属性。" userInfo:nil];
//        @throw exception;
//    }
//}

/**
 *  要显示的图片容器。
 *
 *  @return UIImageView
 */
@synthesize imageView = _imageView;
- (UIImageView *)imageView {
    if (_imageView != nil) {
        return _imageView;
    }
    _imageView = [[UIImageView alloc] init];
    [self addSubview:_imageView];
    return _imageView;
}

/**
 *  观察者。当被赋予了新的图片时，调整图片的大小。
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (object == self.imageView && [keyPath isEqualToString:@"image"]) {
        UIImage *image = [change valueForKey:NSKeyValueChangeNewKey];
        if ([image isKindOfClass:[UIImage class]]) {
            [self imageViewAutoResizeWithImage:image];
        }
    }
}

/**
 *  自动重置大小，在重新给新图片的时候，调用此方法。
 *
 *  @param image 图片
 */
- (void)imageViewAutoResizeWithImage:(UIImage *)image {
    self.zoomScale = 1.0;
    CGSize imageSize = image.size;
    CGSize selfSize = self.frame.size;
    
    CGFloat selfAspectRatio = selfSize.width / selfSize.height;
    CGFloat imageAspectRatio = imageSize.width / imageSize.height;
    
    if (selfAspectRatio < imageAspectRatio) {
        CGFloat height = imageSize.height * selfSize.width / imageSize.width;
        self.imageView.frame = CGRectMake(0, (selfSize.height - height) / 2.0, selfSize.width, height);
    } else if (selfAspectRatio > imageAspectRatio) {
        CGFloat width = imageSize.width * selfSize.height / imageSize.height;
        self.imageView.frame = CGRectMake((selfSize.width - width) / 2.0, 0, width, selfSize.height);
    } else {
        self.imageView.frame = CGRectMake(0, 0, selfSize.width, selfSize.height);
    }
    self.contentSize = selfSize;
}

/**
 *  加载网络图片的方法
 *
 *  @param url 图片的 URL
 */
- (void)setImageWithURL:(NSURL *)url placeholder:(UIImage *)placeholder {
    // 下载图片
    [self.imageView setShowActivityIndicatorView:YES];
    [self.imageView sd_setImageWithURL:url placeholderImage:placeholder];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



@end
