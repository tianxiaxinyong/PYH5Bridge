//
//  PYCImagePickerController.h
//  Demomo
//
//  Created on 14/10/30.
//  Copyright (c) 2014年 ios py. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "PYCameraLayerView.h"

// 选择类型：相机/拍照
typedef enum : NSUInteger
{
    PYCControlTypeNone,                // 未定义
    PYCControlTypeTakePhoto            // 相机
} PYCControlType;


@protocol PYCImagePickerControllerDelegate <NSObject>

@optional;

// 选择图片完成之后的代理，UIImage的数组
- (void)imagePickerChooseDone:(NSArray *)imagesArray isByTake:(BOOL) isByTake;

// 选择图片取消之后的代理
- (void)imagePickerChooseCancel;

//取拍照类型（正，反，手持）
- (CameraLayerType)layerType;
@end

@interface PYCImagePickerController : NSObject<UINavigationBarDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate>

+ (instancetype)sharedInstance;

- (void)showWithControlType:(PYCControlType)type
          maxChooseImageNum:(NSInteger)num
       parentViewController:(UIViewController *)controller
             pickerDelegate:(NSObject *)pickerDelegate
           cameraDeviceType:(UIImagePickerControllerCameraDevice)cameraDeviceType;//摄像头前或后

- (void)showWithControlType:(PYCControlType)type
          maxChooseImageNum:(NSInteger)num
       parentViewController:(UIViewController *)controller
           cameraDeviceType:(UIImagePickerControllerCameraDevice)cameraDeviceType//摄像头前或后
                   delegate:(id<PYCImagePickerControllerDelegate>)delegate;

- (void)hide;

@property (nonatomic,   weak) id<PYCImagePickerControllerDelegate> pickerDelegate;

@end
