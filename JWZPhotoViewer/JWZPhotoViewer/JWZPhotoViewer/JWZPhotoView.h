//
//  JWZPhotoView.h
//  JWZPhotoViewer
//
//  Created by J. W. Z. on 16/1/17.
//  Copyright © 2016年 J. W. Z. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JWZPhotoView;

@protocol JWZPhotoViewImageWatcher <UIScrollViewDelegate>

- (void)photoView:(JWZPhotoView *)photoView downloadImageWithProgress:(NSInteger)progress;
- (BOOL)photoViewShouldSaveImageToAlbum:(JWZPhotoView *)photoView;
- (void)photoViewDidSaveImageToAlbum:(JWZPhotoView *)photoView;


@end

@interface JWZPhotoView : UIScrollView

@property (nonatomic, weak) id<JWZPhotoViewImageWatcher> imageWatcher;

- (UIImage *)image;
- (void)setImage:(UIImage *)image;

- (NSURL *)imageUrl;
- (void)setImageWithUrl:(NSURL *)url;

@end
