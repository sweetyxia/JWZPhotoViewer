//
//  JWZPhotoView.h
//  JWZPhotoViewer
//
//  Created by J. W. Z. on 16/1/17.
//  Copyright © 2016年 J. W. Z. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JWZPhotoView;

@protocol JWZPhotoViewDelegate <NSObject>

- (BOOL)photoViewShouldSaveImageToAlbum:(JWZPhotoView *)photoView;
- (void)photoViewDidSaveImageToAlbum:(JWZPhotoView *)photoView;

@end

@interface JWZPhotoView : UIScrollView {
    @public
    UITapGestureRecognizer *_twiceTap;
    UILongPressGestureRecognizer *_longTap;
}

@property (nonatomic, weak) id<JWZPhotoViewDelegate> imageWatcher;

/**
 *  当前显示的图片
 *
 *  @return 图片
 */
- (UIImage *)image;
- (void)setImage:(UIImage *)image;

/**
 *  通过 URL 设置要显示的图片。
 *
 *  @param url         图片的URL
 *  @param placeholder 在图片下载完成前显示的占位图
 */
- (void)setImageWithURL:(NSURL *)url placeholder:(UIImage *)placeholder;

@end
