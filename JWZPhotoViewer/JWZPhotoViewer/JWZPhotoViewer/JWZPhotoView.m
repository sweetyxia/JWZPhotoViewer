//
//  JWZPhotoView.m
//  JWZPhotoViewer
//
//  Created by J. W. Z. on 16/1/17.
//  Copyright © 2016年 J. W. Z. All rights reserved.
//

#import "JWZPhotoView.h"
#import "SDWebImageManager.h"

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
    [super setDelegate:self];
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
- (void)setDelegate:(id<UIScrollViewDelegate>)delegate {
    if (delegate == nil) {
        [super setDelegate:delegate];
    } else {
        NSException *exception = [NSException exceptionWithName:@"禁止调用的方法" reason:@"视图的代理方法已经处理，禁止设置此属性。" userInfo:nil];
        @throw exception;
    }
}

/**
 *  要显示的图片容器。
 *
 *  @return UIImageView
 */
- (UIImageView *)imageView {
    if (_imageView != nil) {
        return _imageView;
    }
    _imageView = [[UIImageView alloc] init];
    [self addSubview:_imageView];
    
    /**
     *  添加长按手势和双击手势
     */
    _imageView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapAction:)];
    longTap.minimumPressDuration = 3.0;
    [_imageView addGestureRecognizer:longTap];
    UITapGestureRecognizer *twiceTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(twiceTapAction:)];
    twiceTap.numberOfTapsRequired = 2;
    [_imageView addGestureRecognizer:twiceTap];
    
    _longTap = longTap;
    _twiceTap = twiceTap;
    
    return _imageView;
}

/**
 *  设置要显示的图像
 *
 *  @param image UIImage 对象
 */
- (void)setImage:(UIImage *)image {
    [self.imageView setImage:image];
    self.zoomScale = 1.0;
    if (image != nil) {
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
}

- (UIImage *)image {
    return _imageView.image;
}

/**
 *  加载网络图片的方法
 *
 *  @param url 图片的 URL
 */
- (void)setImageWithURL:(NSURL *)url placeholder:(UIImage *)placeholder {
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    UIImage *cachedImage = [imageCache imageFromDiskCacheForKey:url.absoluteString];
    if (cachedImage != nil) {
        [self setImage:cachedImage];
    } else {
        // 下载图片
        [[SDWebImageManager sharedManager] downloadImageWithURL:url options:(0) progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            NSInteger percent = receivedSize * 100.0 / expectedSize;
            NSLog(@"%ld%%", percent);
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (image != nil) {
                if ([[NSThread currentThread] isMainThread]) {
                    [self setImage:image];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setImage:image];
                    });
                }
            }
        }];
    }
}

#pragma mark - 长按保存图片到相册

- (void)longTapAction:(UILongPressGestureRecognizer *)tap {
    if (self.imageView.image != nil) {
        UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo; {
    NSLog(@"图片已经保存到相册。");
}

#pragma mark - 双击放大还原图片

- (void)twiceTapAction:(UITapGestureRecognizer *)tap {
    NSLog(@"twiceTapAction:");
    if (self.imageView.image != nil) {
        CGSize imageViewSize = self.imageView.frame.size;
        CGSize selfSize = self.frame.size;
        
        CGFloat selfAspectRatio = selfSize.width / selfSize.height;
        CGFloat imageViewAspectRatio = imageViewSize.width / imageViewSize.height;
        
        CGRect newRect = self.imageView.frame;
        CGFloat scale = 0.0;
        if (self.zoomScale != 1.0) {
            scale = 1.0;
            if (selfAspectRatio < imageViewAspectRatio) {
                newRect.origin.y = (selfSize.height - imageViewSize.height / self.zoomScale) / 2.0;
            } else {
                newRect.origin.x = (selfSize.width - imageViewSize.width / self.zoomScale) / 2.0;
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
                _imageView.frame = newRect;
                self.zoomScale = scale;
            }];
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - ScrollView 代理方法

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view {
    
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale {
    
}

@end
