//
//  JWZPhotoViewer.h
//  JWZPhotoViewer
//
//  Created by J. W. Z. on 16/1/17.
//  Copyright © 2016年 J. W. Z. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JWZPhotoViewer;

@protocol JWZPhotoViewerDataSource <NSObject>

- (NSInteger)numberOfItemsForPhotoViewer:(JWZPhotoViewer *)photoViewer;
- (NSURL *)photoViewer:(JWZPhotoViewer *)photoViewer thumbnailURLForItemAtIndex:(NSInteger)index;
- (NSURL *)photoViewer:(JWZPhotoViewer *)photoViewer imageURLForItemAtIndex:(NSInteger)index;

@end

@interface JWZPhotoViewer : UIViewController

@property (nonatomic) NSInteger defaultIndex;

@property (nonatomic, weak) id<JWZPhotoViewerDataSource> dataSource;

@end
