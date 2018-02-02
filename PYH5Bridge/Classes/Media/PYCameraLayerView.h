//
//  PYCameraLayerView.h
//  PYH5Bridge
//
//  Created by liuzhy on 2017/12/12.
//  Copyright © 2017年 Pengyuan Credit Service Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CameraLayerType) {
    CameraLayerType_IdCard,//手持身份证
    CameraLayerType_Flag,//正面(人面)
    CameraLayerType_Emblem//反面（国徽）
    
};

@protocol PYCameraLayerViewDelegate <NSObject>

- (void) takePhoto;
- (void) lightAction:(BOOL)isOpen;
- (void) changeCameraDirection;
- (void) exitCamera;

@end;


@interface PYCameraLayerView : UIView


- (id) initWithFrame:(CGRect)frame
           layerType:(CameraLayerType)layerType;

@property (nonatomic, weak) id<PYCameraLayerViewDelegate> delegate;

@end
