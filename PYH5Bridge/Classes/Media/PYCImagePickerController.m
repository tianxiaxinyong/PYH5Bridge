//
//  PYImagePickerController.m
//  Demomo
//
//  Created on 14/10/30.
//  Copyright (c) 2014年 ios py. All rights reserved.
//

#import "PYCImagePickerController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "PYCUtil.h"
#import "PYCUtil+PYCAppAndServiceInfo.h"
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "PYCUtil+PYCInvocatSystemOperate.h"
#import "UIImage+PYCCreate.h"

@interface PYCImagePickerController () <UINavigationControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, weak) UIViewController *parentViewContrller;
@property (nonatomic, assign) NSInteger maxChooseImageNumble;

@end

@implementation PYCImagePickerController


static PYCImagePickerController * static_ZwImagePickerController = nil;
+ (instancetype) sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      static_ZwImagePickerController = [[super alloc] init];
                  });
    return static_ZwImagePickerController;
}

- (id)init
{
    if (self = [super init])
    {
        self.imagePickerController = [[UIImagePickerController alloc] init];
        self.imagePickerController.delegate = self;
        self.imagePickerController.allowsEditing = NO;
        
    }
    
    return self;
}

- (void)showWithControlType:(PYCControlType)type
          maxChooseImageNum:(NSInteger)num
       parentViewController:(UIViewController *)controller
           cameraDeviceType:(UIImagePickerControllerCameraDevice)cameraDeviceType//摄像头前或后
                   delegate:(UIView *)delegate
{
    [ALAssetsLibrary disableSharedPhotoStreamsSupport];
    self.parentViewContrller = controller;
    self.pickerDelegate = (id<PYCImagePickerControllerDelegate>)delegate;
    self.maxChooseImageNumble = num;
    
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.allowsEditing = NO;
    self.imagePickerController.cameraDevice = cameraDeviceType;
    
    NSUInteger sourceType = 0;
    
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        
        switch (type)
        {
            case PYCControlTypeNone:
                // 取消
                break;
            case PYCControlTypeTakePhoto:
            {
                if (![PYCUtil hasCameraRights]) {
                    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请在设备的“设置”选项中，允许应用访问您的相机" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"去设置", nil];
                        alert.tag = 1000;
                        [alert show];
                    }
                    else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请在设备的“设置-隐私-相机”选项中，允许应用访问您的相机" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        
                        [alert show];
                    }
                    
                    return;
                }
                // 相机
                sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
            }
        }
    }
    else
    {
        if (type != 0)
        {
            sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
    }
    
    self.imagePickerController.sourceType = sourceType;
    [self show];

}

- (void)showWithControlType:(PYCControlType)type
          maxChooseImageNum:(NSInteger)num
       parentViewController:(UIViewController *)controller
           cameraDeviceType:(UIImagePickerControllerCameraDevice)cameraDeviceType//摄像头前或后
{
    
    [ALAssetsLibrary disableSharedPhotoStreamsSupport];
    self.parentViewContrller = controller;
    self.pickerDelegate = (id <PYCImagePickerControllerDelegate>)controller;
    self.maxChooseImageNumble = num;
    
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.allowsEditing = NO;
    
    
    NSUInteger sourceType = 0;
    
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        
        switch (type)
        {
            case PYCControlTypeNone:
                // 取消
                break;
            case PYCControlTypeTakePhoto:
            {
                if (![PYCUtil hasCameraRights]) {
                    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请在设备的“设置”选项中，允许应用访问您的相机" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"去设置", nil];
                        alert.tag = 1000;
                        [alert show];
                    }
                    else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请在设备的“设置-隐私-相机”选项中，允许应用访问您的相机" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        
                        [alert show];
                    }
                    
                    return;
                }
                // 相机
                sourceType = UIImagePickerControllerSourceTypeCamera;
                
                break;
            }
        }
    }
    else
    {
        if (type != 0)
        {
            sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
    }
    
    
    self.imagePickerController.sourceType = sourceType;
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        self.imagePickerController.cameraDevice = cameraDeviceType;
    }
    [self show];
}


- (void)show
{
    [self.parentViewContrller presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)hide
{
    [self.imagePickerController dismissViewControllerAnimated:YES completion:^{}];
    self.imagePickerController = nil;
}

#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    __block NSMutableArray *array = @[].mutableCopy;
    
    UIImage *fixImage = [image py_fixOrientation];
    
    [array addObject:fixImage];
    [self.pickerDelegate imagePickerChooseDone:array isByTake:YES];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (self.pickerDelegate && [self.pickerDelegate respondsToSelector:@selector(imagePickerChooseCancel)])
    {
        [self.pickerDelegate imagePickerChooseCancel];
    }
    
    [self hide];
}


#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 1000:
        case 1001:
        {
            if (buttonIndex != alertView.cancelButtonIndex) {
                [PYCUtil openSystemSettingOfApp];
            }
            
            break;
        }
        default:
            break;
    }
    
}


@end
