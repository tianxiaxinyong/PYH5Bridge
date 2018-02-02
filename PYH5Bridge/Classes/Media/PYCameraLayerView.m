//
//  PYCameraLayerView.m
//  PYH5Bridge
//
//  Created by liuzhy on 2017/12/12.
//  Copyright © 2017年 Pengyuan Credit Service Co., Ltd. All rights reserved.
//



#import "PYCameraLayerView.h"
#import "PYCUtil.h"

@interface PYCameraLayerView()

@property (nonatomic, strong) UIButton *lightButton;
@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic, strong) UIButton *chooseCameraButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) NSURL *budleURL;
@property (nonatomic, assign) BOOL isLightButtonClicked;

@end

@implementation PYCameraLayerView

- (id) initWithFrame:(CGRect)frame
          layerType:(CameraLayerType)layerType
{
    self = [super initWithFrame:frame];
    if (self) {
        _isLightButtonClicked = NO;
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        _budleURL = [bundle URLForResource:@"PYH5Bridge" withExtension:@"bundle"];
        [self initSubViewWithlayerType:layerType];
    }
    return self;
}

- (void) initSubViewWithlayerType:(CameraLayerType)layerType
{
    // 顶部区域
    UIView *topBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, TOP_BAR_HEIGHT)];
    topBarView.backgroundColor = [UIColor blackColor];
    [self addSubview:topBarView];
    [topBarView addSubview:self.lightButon];
    [topBarView addSubview:self.chooseCameraButton];
   
    
    // 底部区域
    UIView *bootomBarView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - BOTTOM_BAR_HEIGHT, SCREEN_WIDTH, BOTTOM_BAR_HEIGHT)];
    bootomBarView.backgroundColor = [UIColor clearColor];
    [self addSubview:bootomBarView];
    [bootomBarView addSubview:self.photoButton];
    [bootomBarView addSubview:self.cancelButton];
    
    //遮罩区域
    UIImageView *layerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, TOP_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - TOP_BAR_HEIGHT - BOTTOM_BAR_HEIGHT )];
    switch (layerType)
    {
        case CameraLayerType_Flag:
        {
            NSString *imagePath = [[NSBundle bundleWithURL:_budleURL] pathForResource:@"人像面" ofType:@"png" inDirectory:@"images"];
            UIImage *image2 = [UIImage imageWithContentsOfFile: imagePath];
            [layerImageView setImage:image2];
        }
            break;
        case CameraLayerType_Emblem:
        {
            NSString *imagePath = [[NSBundle bundleWithURL:_budleURL] pathForResource:@"国徽面" ofType:@"png" inDirectory:@"images"];
            UIImage *image2 = [UIImage imageWithContentsOfFile: imagePath];
            [layerImageView setImage:image2];
        }
            break;
        case CameraLayerType_IdCard:
        {
            NSString *imagePath = [[NSBundle bundleWithURL:_budleURL] pathForResource:@"手持身份证" ofType:@"png" inDirectory:@"images"];
            UIImage *image2 = [UIImage imageWithContentsOfFile: imagePath];
            [layerImageView setImage:image2];
        }
            break;
        default:
            break;
    }
    [self addSubview:layerImageView];
}


#pragma mark === setter

- (UIButton *)lightButon{
    if (!_lightButton) {
        NSString *openlightImagePath = [[NSBundle bundleWithURL:_budleURL] pathForResource:@"闪光" ofType:@"png" inDirectory:@"images"];
        NSString *closelightImagePath = [[NSBundle bundleWithURL:_budleURL] pathForResource:@"关闭闪光" ofType:@"png" inDirectory:@"images"];
        UIImage *openlightImage = [UIImage imageWithContentsOfFile: openlightImagePath];
        UIImage *closelightImage = [UIImage imageWithContentsOfFile: closelightImagePath];
        _lightButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 5, 30, 30)];
        [_lightButton addTarget:self action:@selector(lightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_lightButton setImage:openlightImage forState:UIControlStateSelected];
        [_lightButton setImage:closelightImage forState:UIControlStateNormal];
    }
    return _lightButton;
}

- (UIButton *)chooseCameraButton{
    if (!_chooseCameraButton) {
        NSString *changeCameraImagePath = [[NSBundle bundleWithURL:_budleURL] pathForResource:@"切换镜头" ofType:@"png" inDirectory:@"images"];
        UIImage *changeCameraImage = [UIImage imageWithContentsOfFile: changeCameraImagePath];
        _chooseCameraButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 8 - 30, 5, 30, 30)];
        [_chooseCameraButton setImage:changeCameraImage forState:UIControlStateNormal];
        [_chooseCameraButton addTarget:self action:@selector(chooseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _chooseCameraButton;
}

- (UIButton *)photoButton{
    if (!_photoButton) {
        NSString *takePhothoImagePath = [[NSBundle bundleWithURL:_budleURL] pathForResource:@"拍照" ofType:@"png" inDirectory:@"images"];
        UIImage *takePhothoImage = [UIImage imageWithContentsOfFile: takePhothoImagePath];
        _photoButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 40, BOTTOM_BAR_HEIGHT / 2 - 40, 80, 80)];
        [_photoButton setImage:takePhothoImage forState:UIControlStateNormal];
        [_photoButton addTarget:self action:@selector(photoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoButton;
}

- (UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(15, BOTTOM_BAR_HEIGHT / 2 - 15, 40, 40)];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTintColor:[UIColor whiteColor]];
        [_cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

#pragma mark === actions
- (void)lightButtonClicked:(UIButton *)senderButton{
    self.isLightButtonClicked = !self.isLightButtonClicked;
    if (self.isLightButtonClicked) {
        [self.lightButon setSelected:YES];
        if (_delegate && [_delegate respondsToSelector:@selector(lightAction:)]) {
            [_delegate lightAction:NO];
        }
    }
    else{
        [self.lightButon setSelected:NO];
        if (_delegate && [_delegate respondsToSelector:@selector(lightAction:)]) {
            [_delegate lightAction:YES];
        }
    }
}

- (void)chooseButtonClicked:(UIButton *)senderButton{
    if (_delegate && [_delegate respondsToSelector:@selector(changeCameraDirection)]) {
        [_delegate changeCameraDirection];
    }
}

- (void)photoButtonClicked:(UIButton *)senderButton{
    if (_delegate && [_delegate respondsToSelector:@selector(takePhoto)]) {
        [_delegate takePhoto];
    }
}

- (void)cancelButtonClicked:(UIButton *)senderButton{
    if (_delegate && [_delegate respondsToSelector:@selector(exitCamera)]) {
        [_delegate exitCamera];
    }
}

@end
