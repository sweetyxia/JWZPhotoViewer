//
//  JWZPhotoView.h
//  JWZPhotoViewer
//
//  Created by J. W. Z. on 16/1/17.
//  Copyright © 2016年 J. W. Z. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JWZPhotoView : UIScrollView

@property (nonatomic, strong, readonly) UIImageView *imageView;

/**
 *  通过 URL 设置要显示的图片。
 *
 *  @param url         图片的URL
 *  @param placeholder 在图片下载完成前显示的占位图
 */
- (void)setImageWithURL:(NSURL *)url placeholder:(UIImage *)placeholder;

@end
