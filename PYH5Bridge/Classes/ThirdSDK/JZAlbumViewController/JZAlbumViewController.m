//
//  JZAlbumViewController.m
//  aoyouHH
//
//  Created by jinzelu on 15/4/27.
//  Copyright (c) 2015年 jinzelu. All rights reserved.
//

#import "JZAlbumViewController.h"
#import "MBProgressHUD.h"
#import "PhotoView.h"
#import "PYCUtil.h"

#define  jz_tapbarHeight 20.0f

@interface JZAlbumViewController ()<UIScrollViewDelegate,PhotoViewDelegate>
{
    CGFloat lastScale;
    MBProgressHUD *HUD;
    NSMutableArray *_subViewList;
}

@end

@implementation JZAlbumViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //
        _subViewList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    lastScale = 1.0;
    self.view.backgroundColor = [UIColor blackColor];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OnTapView)];
//    [self.view addGestureRecognizer:tap];

    [self initScrollView];
    [self addLabels];
    [self setPicCurrentIndex:self.currentIndex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initScrollView{
//    [[SDImageCache sharedImageCache] cleanDisk];
//    [[SDImageCache sharedImageCache] clearMemory];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    
    CGFloat tapbarHeight = jz_tapbarHeight;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, tapbarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - tapbarHeight)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
    self.scrollView.contentSize = CGSizeMake(self.imgArr.count*SCREEN_WIDTH, SCREEN_HEIGHT - tapbarHeight);
    self.scrollView.delegate = self;
    self.scrollView.contentOffset = CGPointMake(0, 0);
    //设置放大缩小的最大，最小倍数
//    self.scrollView.minimumZoomScale = 1;
//    self.scrollView.maximumZoomScale = 2;
    [self.view addSubview:self.scrollView];
    
    for (int i = 0; i < self.imgArr.count; i++) {
        [_subViewList addObject:[NSNull class]];
    }

}

-(void)addLabels{
    self.sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, SCREEN_HEIGHT-64-49, 60, 30)];
    self.sliderLabel.backgroundColor = [UIColor clearColor];
    self.sliderLabel.textColor = [UIColor whiteColor];
    self.sliderLabel.text = [NSString stringWithFormat:@"%ld/%lu",(long)self.currentIndex+1,(unsigned long)self.imgArr.count];
    [self.view addSubview:self.sliderLabel];
}

-(void)setPicCurrentIndex:(NSInteger)currentIndex{
    _currentIndex = currentIndex;
    self.scrollView.contentOffset = CGPointMake(SCREEN_WIDTH*currentIndex, 0);
    [self loadPhote:_currentIndex];
    [self loadPhote:_currentIndex+1];
    [self loadPhote:_currentIndex-1];
}

-(void)loadPhote:(NSInteger)index{
    if (index<0 || index >=self.imgArr.count) {
        return;
    }
    
    id currentPhotoView = [_subViewList objectAtIndex:index];
    if (![currentPhotoView isKindOfClass:[PhotoView class]]) {
        //url数组
        CGRect frame = CGRectMake(index*_scrollView.frame.size.width, 0, self.view.frame.size.width, self.scrollView.frame.size.height);
        PhotoView *photoV = [[PhotoView alloc] initWithFrame:frame withPhotoImage:[self.imgArr objectAtIndex:index]];
        photoV.delegate = self;
        [self.scrollView insertSubview:photoV atIndex:0];
        [_subViewList replaceObjectAtIndex:index withObject:photoV];
    }else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wunused-variable"
        PhotoView *photoV = (PhotoView *)currentPhotoView;
#pragma clang diagnostic pop
    }
    
}

#pragma mark - PhotoViewDelegate
-(void)TapHiddenPhotoView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)OnTapView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int i = scrollView.contentOffset.x/SCREEN_WIDTH+1;
    [self loadPhote:i-1];
    self.sliderLabel.text = [NSString stringWithFormat:@"%d/%lu",i,(unsigned long)self.imgArr.count];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
