//
//  ViewController.m
//  JWZPhotoViewer
//
//  Created by J. W. Z. on 16/1/17.
//  Copyright © 2016年 J. W. Z. All rights reserved.
//

#import "ViewController.h"

#import "JWZPhotoViewer.h"
#import "JWZSudokuView.h"

@interface ViewController () <JWZPhotoViewerDataSource, JWZSudokuViewDelegate>

@property (weak, nonatomic) IBOutlet JWZSudokuView *sudokuView;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dataArray = @[
                       @"http://funsbar.image.alimmdn.com/image/E8761596C917428AAE286C3464BBC34E.png?0",
                       @"http://h.hiphotos.baidu.com/image/pic/item/4ec2d5628535e5dd2820232370c6a7efce1b623a.jpg?1",
                       @"http://v1.qzone.cc/avatar/201403/30/09/33/533774802e7c6272.jpg%21200x200.jpg?2",
                       @"http://img4.duitang.com/uploads/item/201409/16/20140916103123_343c3.jpeg?3",
                       @"http://v1.qzone.cc/avatar/201407/25/20/52/53d253192be47412.jpg%21200x200.jpg?4",
                       @"http://cdn.duitang.com/uploads/item/201408/13/20140813122725_8h8Yu.jpeg?5",
                       @"http://v1.qzone.cc/avatar/201403/30/09/33/533774802e7c6272.jpg%21200x200.jpg?6",
                       @"http://img4.duitang.com/uploads/item/201409/16/20140916103123_343c3.jpeg?7",
                       @"http://v1.qzone.cc/avatar/201407/25/20/52/53d253192be47412.jpg%21200x200.jpg?8",
                       @"http://cdn.duitang.com/uploads/item/201408/13/20140813122725_8h8Yu.jpeg?9",
                       @"http://v1.qzone.cc/avatar/201403/30/09/33/533774802e7c6272.jpg%21200x200.jpg?10",
                       @"http://img4.duitang.com/uploads/item/201409/16/20140916103123_343c3.jpeg?11",
                       @"http://v1.qzone.cc/avatar/201407/25/20/52/53d253192be47412.jpg%21200x200.jpg?12"
                       ];
    [self.sudokuView setContentWithImageUrls:_dataArray placeholder:nil];
    _sudokuView.delegate = self;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfItemsForPhotoViewer:(JWZPhotoViewer *)photoViewer {
    return self.dataArray.count;
}

- (NSString *)photoViewer:(JWZPhotoViewer *)photoViewer imageURLForItemAtIndex:(NSInteger)index {
    return [self.dataArray objectAtIndex:index];
}

- (NSString *)photoViewer:(JWZPhotoViewer *)photoViewer thumbnailURLForItemAtIndex:(NSInteger)index {
    return [self.dataArray objectAtIndex:index];
}

- (void)sudokuView:(JWZSudokuView *)sudokuView didTouchOnImageView:(UIImageView *)imageView atIndex:(NSInteger)index {
    JWZPhotoViewer *viewer = [[JWZPhotoViewer alloc] init];
    viewer.defaultIndex = index;
    viewer.dataSource = self;
    self.definesPresentationContext = YES;
    viewer.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:viewer animated:NO completion:NULL];
}

@end
