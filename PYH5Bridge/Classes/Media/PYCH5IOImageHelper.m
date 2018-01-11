//
//  PYCH5IOImageHelper.m
//  PYH5Bridge
//
//  Created on 17/1/3.
//

#import "PYCH5IOImageHelper.h"
#import "PYCImagePickerController.h"
#import "UIImage+PYCCreate.h"
#import "PYCUtil.h"
#import "UIImage+PYCScaleSize.h"
#import "PYCUtil+PYCFilePath.h"
#import "PYCUtil+PYCTimeManage.h"
#import <ImageIO/ImageIO.h>
#import "UIView+Toast.h"
#import "PYCUtil+PYCAppAndServiceInfo.h"
#import "PYCUtil+PYCInvocatSystemOperate.h"
#import "MBProgressHUD.h"

#define IMAGE_SCALE_FIXED_WIDTH         1024.0f
#define IMAGE_JPEG_FACTOR               0.8f

@interface PYCH5IOImageHelper () <UIActionSheetDelegate, PYCImagePickerControllerDelegate>

@property (nonatomic , weak) UIViewController <PYCH5IOImageHelperProtocol> * delegate;

@property (nonatomic , strong) NSMutableArray *images;

@property (nonatomic, assign) NSInteger selectMaxSum;//此次最大选择张数

@property (nonatomic, assign) NSInteger maxPixelSize;//最大边长

@property (nonatomic, assign) BOOL isNeedTrim;//是否需要裁剪

@property (nonatomic, assign) BOOL hasAuthority;//是否有权限

@property (nonatomic, copy) NSString *actionType;//0 任意类型 ；1 图片；2 视频；
@property (nonatomic, assign) UIImagePickerControllerCameraDevice cameraDeviceType;//摄像头前或后

@end

@implementation PYCH5IOImageHelper
{
    ALAssetsLibrary *assetslibrary;
}

- (instancetype)initWithDelegate:(UIViewController <PYCH5IOImageHelperProtocol> *)delegate
{
    if (self = [super init]) {
        
        _delegate = delegate;
        _images = @[].mutableCopy;
        _isNeedTrim = NO;
        assetslibrary = [[ALAssetsLibrary alloc] init];
        
    }
    return self;
}

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
                                  cameraDeviceType:(UIImagePickerControllerCameraDevice)cameraDeviceType
{
    _actionType = @"1";//设置成常量
    _cameraDeviceType = cameraDeviceType;

    UIActionSheet *actionSheet;
    if ([_actionType isEqualToString:@"1"])
    {
        actionSheet = [[UIActionSheet alloc]
                       initWithTitle:nil
                       delegate:self
                       cancelButtonTitle:@"取消"
                       destructiveButtonTitle:nil
                       otherButtonTitles: @"拍照", nil];
    }
    else
    {
        return;
    }
    
    _selectMaxSum = selectMaxSum;
    _maxPixelSize = maxPixelSize;
    _isNeedTrim = isNeedTrim;
    
    if (_isNeedTrim) {
        _selectMaxSum = 1;
    }
    
    //如果父视图有实现这个方法，优先在这个返回的视图控制器上显示弹出视图
    if ([_delegate respondsToSelector:@selector(showHUDParentViewController)]) {
        UIViewController *parentViewController = [_delegate showHUDParentViewController];
        [MBProgressHUD hideHUDForView:parentViewController.view animated:YES];
        [actionSheet showInView:parentViewController.view];
    }
}


#pragma  mark -
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_delegate && [_delegate respondsToSelector:@selector(imageHelper:clickedButtonAtIndex:)]) {
        if (![_actionType isEqualToString:@"1"]) {
          [_delegate imageHelper:self clickedButtonAtIndex:buttonIndex];
        }
    }
    
    //呼出的菜单按钮点击后的响应
    if (buttonIndex == actionSheet.cancelButtonIndex)
    {
        [self _convertImagesComplete:YES];
        return;
    }
    
    void (^takePhotoBlock)(void) = ^{
        
        _hasAuthority = [PYCUtil hasCameraRights];
        if (!_hasAuthority) {
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
        
        UIViewController *parentViewController = nil;
        if ([_delegate respondsToSelector:@selector(showHUDParentViewController)]) {
             parentViewController = [_delegate showHUDParentViewController];
        }
       
        [[PYCImagePickerController sharedInstance] showWithControlType:PYCControlTypeTakePhoto
                                                    maxChooseImageNum:1
                                                 parentViewController:parentViewController
                                                     cameraDeviceType:_cameraDeviceType];
        [PYCImagePickerController sharedInstance].pickerDelegate = self;
    };
    
    if ([_actionType isEqualToString:@"0"]) {
        switch (buttonIndex)
        {
            case 0:
                takePhotoBlock();
                break;
            case 1:
                break;
            case 2:
                break;
        }
    }
    else if ([_actionType isEqualToString:@"1"])
    {
        switch (buttonIndex)
        {
            case 0:
                takePhotoBlock();
                break;
            case 1:
                break;
        }
    }
    
}

- (void)imagePickerChooseCancel
{
    [self _convertImagesComplete:YES];
}

// 选择图片完成之后的代理，UIImage的数组
- (void) imagePickerChooseDone:(NSArray *)imagesArray isByTake:(BOOL)isByTake
{
    
    if (_isNeedTrim) {
        [self trimImageWithImagesArray:imagesArray];
    }
    else
    {
        //如果父视图有实现这个方法，优先在这个返回的视图控制器上显示弹出视图
        if ([_delegate respondsToSelector:@selector(showHUDParentViewController)]) {
            UIViewController *parentViewController = [_delegate showHUDParentViewController];
            MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:parentViewController.view animated:YES];
            hud.labelText = @"正在处理图片...";
        }
        
        [self gcdDispatchProcessImages:imagesArray isByTake:isByTake];
    }
    
}

- (void) trimImageWithImagesArray:(NSArray *) imagesArray
{
    //获取到图片之后添加到裁剪Controller里面。进行裁剪操作。
    id item = nil;
    __block UIImage *tempImage;
    
    if (imagesArray == nil) {
        [self _convertImagesComplete:NO];
        return;
    }
    
    if (imagesArray.count == 0) {
        [self _convertImagesComplete:NO];
        return;
    }
    item = [imagesArray objectAtIndex:0];
    
    if ([item isKindOfClass:[UIImage class]]) {
        
        tempImage = item;
        [self processImage:tempImage];
        
    } else if ([item isKindOfClass:[NSURL class]]) {
        dispatch_queue_t queue = dispatch_queue_create("pycredit.queue", DISPATCH_QUEUE_SERIAL);
        dispatch_group_t dispatchGroup = dispatch_group_create();
        NSURL *url = (NSURL *)item;
        assetslibrary = [[ALAssetsLibrary alloc] init];
        
        [assetslibrary assetForURL:url resultBlock:^(ALAsset *asset)
         {
             if (asset) {
                 dispatch_group_async(dispatchGroup, queue, ^{
                     [self processAsset:asset isByTake:NO];
                 });
             } else {
                 NSLog(@"asset is nil");
                 //ALAssetsLibrary assetForURL: always returning nil for photos in "My Photo Stream" in iOS 8.1
                 [assetslibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream
                                              usingBlock:^(ALAssetsGroup *group, BOOL *stop)
                  {
                      [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                          if ([result.defaultRepresentation.url isEqual:url]) {
                              dispatch_group_async(dispatchGroup, queue, ^{
                                  [self processAsset:result isByTake:NO];
                              });
                          }
                      }];
                  }
                  
                                            failureBlock:^(NSError *error)
                  {
                      NSLog(@"Error: Cannot load asset from photo stream - %@", [error localizedDescription]);
                      [self _convertImagesComplete:NO];
                  }];
             }
         }
                      failureBlock:^(NSError *error)
         {
             NSLog(@"%@", error.description);
             [self _convertImagesComplete:NO];
         }];
    }
}

- (void) gcdDispatchProcessImages:(NSArray *)aryImageList isByTake:(BOOL) isByTake
{
    dispatch_queue_t queue = dispatch_queue_create("pycredit.queue", DISPATCH_QUEUE_SERIAL);
    dispatch_group_t dispatchGroup = dispatch_group_create();
    
    BOOL isImageURL = NO;
    id item = nil;
    __block int urlCount = 0;
    __block BOOL isEnumPhoneStream = NO;
    __block BOOL isAddGroupNotify = NO;
    for (int i = 0; i < aryImageList.count; i++) {
        @autoreleasepool {
            item = [aryImageList objectAtIndex:i];
            
            if ([item isKindOfClass:[UIImage class]]) {
                dispatch_group_async(dispatchGroup, queue, ^{
                    [self processImage:(UIImage *)item];
                });
            }
            else if ([item isKindOfClass:[NSURL class]])
            {
                isImageURL = YES;
                NSURL *url = (NSURL *)item;
                
                [assetslibrary assetForURL:url resultBlock:^(ALAsset *asset)
                 {
                     urlCount++;
                     if (asset) {
                         dispatch_group_async(dispatchGroup, queue, ^{
                             [self processAsset:asset isByTake:isByTake];
                         });
                     }
                     else
                     {
                         NSLog(@"asset is nil");
                         isEnumPhoneStream = YES;
                         //ALAssetsLibrary assetForURL: always returning nil for photos in "My Photo Stream" in iOS 8.1
                         [assetslibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream
                                                      usingBlock:^(ALAssetsGroup *group, BOOL *stop)
                          {
                              [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                  if([result.defaultRepresentation.url isEqual:url])
                                  {
                                      dispatch_group_async(dispatchGroup, queue, ^{
                                          [self processAsset:result isByTake:isByTake];
                                      });
                                      *stop = YES;
                                  }
                                  if (*stop) {
                                      if ((urlCount == aryImageList.count) && !isAddGroupNotify) {
                                          isAddGroupNotify = YES;
                                          dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^{
                                              [self _convertImagesComplete:NO];
                                          });
                                      }
                                  }
                              }];
                          }
                                                    failureBlock:^(NSError *error)
                          {
                              //                              [self hideHUDWithAnimated:YES];
                              [self _convertImagesComplete:NO];
                              NSLog(@"Error: Cannot load asset from photo stream - %@", [error localizedDescription]);
                          }];
                     }
                     
                     if ((urlCount == aryImageList.count) && !isEnumPhoneStream)
                     {
                         dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^{
                             [self _convertImagesComplete:NO];
                         });
                     }
                     
                 } failureBlock:^(NSError *error)
                 {
                     //                     [self hideHUDWithAnimated:YES];
                     [self _convertImagesComplete:NO];
                     NSLog(@"%@", error.description);
                 }];
                
            }
        }
        
    }
    
    if (!isImageURL) {
        dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^{
            [self _convertImagesComplete:NO];
        });
    }
}

- (void) processAsset:(ALAsset *)asset isByTake:(BOOL) isByTake
{
    
    @autoreleasepool {
        
        
        UIImage *newImage = [UIImage py_thumbnailForAsset:asset maxPixelSize:_maxPixelSize];
        NSData *data = UIImageJPEGRepresentation(newImage, IMAGE_JPEG_FACTOR);
        newImage = nil;
        
        NSMutableDictionary *metaMdic = @{}.mutableCopy;
        if (!_isNeedTrim) {
            NSDictionary *imageMetadata = [[NSMutableDictionary alloc] initWithDictionary:asset.defaultRepresentation.metadata];
            
            NSDictionary *exiDic = [imageMetadata objectForKey:(__bridge NSString*)kCGImagePropertyExifDictionary];
            
            NSString *pictureTime = exiDic[@"DateTimeOriginal"];
            if ( !pictureTime)
            {
                NSDate* pictureDate = [asset valueForProperty:ALAssetPropertyDate];
                NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
                formatter.dateFormat = @"yyyy:MM:dd HH:mm:ss";
                pictureTime = [formatter stringFromDate:pictureDate];
            }
            [metaMdic setValue:[PYCUtil timestampWithStringTime:pictureTime] forKey:@"createTime"];
            [metaMdic setValue:[PYCUtil timestampWithStringTime:pictureTime] forKey:@"modifyTime"];
            
        }
        
        [self _processImage:data withMeta:metaMdic];
        
    }
}


- (void) processImage:(UIImage *)image {
    
    @autoreleasepool {
        UIImage *newImage = image;
        if (_maxPixelSize > 0) {
            newImage = [UIImage py_resizeImage:image maxPixelSize:_maxPixelSize];
        }
        
        image = nil;
        NSData *data = UIImageJPEGRepresentation(newImage, IMAGE_JPEG_FACTOR);
        newImage = nil;
        
        NSMutableDictionary *metaMdic = @{}.mutableCopy;
        [self _processImage:data withMeta:metaMdic];
    }
}

#pragma mark - private
- (void)_processImage:(NSData *) data withMeta:(NSDictionary *) metaDic
{
    if (!data) {
        return;
    }
    
    //图片保存的路径
    //这里将图片放在沙盒的documents文件夹中
    NSString * imagesTemplatePath = [PYCUtil imagesTemplatePath];
    
    NSString *haxi  = [PYCUtil md5:[PYCUtil encodeBase64Data:data] ];
    
    //得到选择后沙盒中图片的完整路径
    NSString *filePath = [imagesTemplatePath stringByAppendingPathComponent:haxi];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                           forKey:NSFileProtectionKey];
    
    if ( ![[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:attributes]) {
        
        NSLog(@"ResourceData createFileAtPath failed; filePath:%@",filePath);
        return;
    }
    
    PYCPostImageFile *postImg = [[PYCPostImageFile alloc] init];
    postImg.imageName = [NSString stringWithFormat:@"/image%@.jpg",haxi];
    postImg.imgFilePath = filePath;
    postImg.postFinished = NO;
    postImg.imgFileSize = data.length/1024.0;
    postImg.meta = metaDic;
    postImg.isCache = YES;
    
    if (postImg.imgFileSize > 4096)
    {
        return;
    }
    
    NSData *convertData ;
    if ([_delegate respondsToSelector:@selector(convertDataBySelect:needTrim:)] && !_isNeedTrim) {
        
        ///使用者自定义处理方式
        
        convertData = [_delegate convertDataBySelect:data needTrim:NO];
        
        if (![[NSFileManager defaultManager] createFileAtPath:filePath contents:convertData attributes:attributes]) {
            
            NSLog(@"convertData createFileAtPath failed; filePath:%@",filePath);
            return;
        }
    }
    
    @synchronized(self) {
        [_images addObject:postImg];
    }
    data = nil;
}

/**
 完成图片处理

 @param clickCancel 是否是点击了cancel选项
 */
- (void) _convertImagesComplete:(BOOL)clickCancel
{
    
    if ([_delegate respondsToSelector:@selector(convertImagesCompleteWith:needTrim:authority:cancelClick:)]) {
        
        [_delegate convertImagesCompleteWith:_images needTrim:_isNeedTrim authority:_hasAuthority cancelClick:clickCancel];
    }
    
    if (!_isNeedTrim) {
        //如果父视图有实现这个方法，优先在这个返回的视图控制器上显示弹出视图
        if ([_delegate respondsToSelector:@selector(showHUDParentViewController)]) {
            UIViewController *parentViewController = [_delegate showHUDParentViewController];
            [MBProgressHUD hideHUDForView:parentViewController.view animated:YES];
        }
    }
    
    [_images removeAllObjects];
    
    ///因为是单例所以一次调用后，需要恢复为默认值
    _isNeedTrim = NO;
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
            else
            {
                [self _convertImagesComplete:YES];
            }
            
            break;
        }
        default:
            break;
    }
    
}

@end
