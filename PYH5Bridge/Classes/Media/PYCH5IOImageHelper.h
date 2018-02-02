//
//  PYCH5IOImageHelper.h
//  PYH5Bridge
//
//  Created on 17/1/3.
//

#import <Foundation/Foundation.h>
#import "PYCPostImageFile.h"

@class PYCH5IOImageHelper;

@protocol PYCH5IOImageHelperProtocol <NSObject>

@optional
- (NSData *)convertDataBySelect:(NSData *) selectImageData needTrim:(BOOL) isNeedTrim;

/**
 <#Description#>

 @param images 返回的图片数组
 @param isNeedTrim 是否剪裁
 @param hasAuthority 是否有权限
 */
- (void)convertImagesCompleteWith:(NSArray <PYCPostImageFile *>*) images needTrim:(BOOL)isNeedTrim authority:(BOOL)hasAuthority cancelClick:(BOOL)clickCancel;

- (void)imageHelper:(PYCH5IOImageHelper *)imageHelper clickedButtonAtIndex:(NSInteger)buttonIndex;

/**
 用于显示load界面及弹出界面

 @return 界面控制器
 */
- (UIViewController *)showHUDParentViewController;
@end

@interface PYCH5IOImageHelper : NSObject
//拍照类型（正，反，手持）
@property (nonatomic , strong)  NSNumber   *imageType;

- (instancetype) initWithDelegate:(id <PYCH5IOImageHelperProtocol>) delegate;

/**
 打开摄像头

 @param selectMaxSum 可选择最大相片数
 @param maxPixelSize 最大边长
 @param isNeedTrim 是否需要裁剪
 @param cameraDeviceType 摄像头前或后
 */
- (void)showSelectImageActionSheetWithSelectMaxSum:(NSInteger)selectMaxSum
                                      maxPixelSize:(NSInteger)maxPixelSize
                                          needTrim:(BOOL)isNeedTrim
                                  cameraDeviceType:(UIImagePickerControllerCameraDevice)cameraDeviceType;

@end
