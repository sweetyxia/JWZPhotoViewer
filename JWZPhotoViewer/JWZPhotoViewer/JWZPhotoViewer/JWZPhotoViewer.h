//
//  JWZPhotoViewer.h
//  JWZPhotoViewer
//
//  Created by J. W. Z. on 16/1/17.
//  Copyright © 2016年 J. W. Z. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN CGFloat const kJWZPhotoViewAnimationDuration;

@class JWZPhotoViewer;

@protocol JWZPhotoViewerDataSource <NSObject>

- (NSInteger)numberOfItemsForPhotoViewer:(JWZPhotoViewer *)photoViewer;
- (NSURL *)photoViewer:(JWZPhotoViewer *)photoViewer thumbnailURLForItemAtIndex:(NSInteger)index;
- (NSURL *)photoViewer:(JWZPhotoViewer *)photoViewer imageURLForItemAtIndex:(NSInteger)index;

@optional
- (UIView *)resoureViewForItemAtIndex:(NSInteger)index;

@end

@interface JWZPhotoViewer : UIViewController

@property (nonatomic) NSInteger currentIndex;

@property (nonatomic, weak) id<JWZPhotoViewerDataSource> dataSource;

+ (void)showFromViewController:(UIViewController *)viewController dataSource:(id<JWZPhotoViewerDataSource>)dataSource defaultIndex:(NSInteger)defaultIndex;

@end
