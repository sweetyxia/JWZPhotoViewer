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

@property (nonatomic, strong) NSURL *imageUrl;

@end


@implementation JWZPhotoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {

    }
    return self;
}

- (void)initialize {
    self.maximumZoomScale = CGFLOAT_MAX;
    self.minimumZoomScale = 0.5;
    self.bounces = YES;
    self.alwaysBounceHorizontal = YES;
    self.alwaysBounceVertical = YES;
    [super setDelegate:self];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

- (void)setDelegate:(id<UIScrollViewDelegate>)delegate {
    NSException *exception = [NSException exceptionWithName:@"禁止调用的方法" reason:@"视图的代理方法已经处理，禁止设置此属性。" userInfo:nil];
    @throw exception;
}

- (UIImageView *)imageView {
    if (_imageView != nil) {
        return _imageView;
    }
    _imageView = [[UIImageView alloc] init];
    [self addSubview:_imageView];
    
    _imageView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapAction:)];
    longTap.minimumPressDuration = 3.0;
    [_imageView addGestureRecognizer:longTap];
    UITapGestureRecognizer *twiceTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(twiceTapAction:)];
    twiceTap.numberOfTapsRequired = 2;
    [_imageView addGestureRecognizer:twiceTap];
    
    return _imageView;
}

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
            _imageView.frame = CGRectMake(0, (selfSize.height - height) / 2.0, selfSize.width, height);
        } else if (selfAspectRatio > imageAspectRatio) {
            CGFloat width = imageSize.width * selfSize.height / imageSize.height;
            _imageView.frame = CGRectMake((selfSize.width - width) / 2.0, 0, width, selfSize.height);
        } else {
            _imageView.frame = CGRectMake(0, 0, selfSize.width, selfSize.height);
        }
        self.contentSize = selfSize;
    }
}

- (void)setImageWithUrl:(NSURL *)url {
    self.imageUrl = url;
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    UIImage *cachedImage = [imageCache imageFromDiskCacheForKey:url.absoluteString];
    if (cachedImage != nil) {
        [self setImage:cachedImage];
    } else {
        SDWebImageDownloaderProgressBlock progress = NULL;
        if (self.imageWatcher != nil) {
            progress = ^(NSInteger receivedSize, NSInteger expectedSize) {
                NSInteger percent = receivedSize * 100.0 / expectedSize;
                [[self imageWatcher] photoView:self downloadImageWithProgress:(NSInteger)percent];
            };
        }
        
        [[SDWebImageManager sharedManager] downloadImageWithURL:url options:(0) progress:progress completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (image != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setImage:image];
                });
            }
        }];
    }
}

- (UIImage *)image {
    return _imageView.image;
}

#pragma mark - 长按保存图片到相册

- (void)longTapAction:(UILongPressGestureRecognizer *)tap {
    NSLog(@"Long Tap.");
    if (_imageView.image != nil) {
        UIImageWriteToSavedPhotosAlbum(_imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
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
