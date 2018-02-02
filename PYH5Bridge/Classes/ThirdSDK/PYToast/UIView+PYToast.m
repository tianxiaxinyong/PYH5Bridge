//
//  UIView+Toast.m
//  Toast
//
//  Copyright 2014 Charles Scalesse.
//


#import "UIView+PYToast.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
//#import "UIImage+ScaleSize.h"

#define PYToastTag 35555
/*
 *  CONFIGURE THESE VALUES TO ADJUST LOOK & FEEL,
 *  DISPLAY DURATION, ETC.
 */

// general appearance
static const CGFloat CSToastMaxWidth            = 0.8;      // 80% of parent view width
static const CGFloat CSToastMaxHeight           = 0.8;      // 80% of parent view height
static const CGFloat CSToastHorizontalPadding   = 15.0;
static const CGFloat CSToastVerticalPadding     = 22.0;
static const CGFloat CSToastCornerRadius        = 5.0;
static const CGFloat CSToastOpacity             = 0.8;
static const CGFloat CSToastFontSize            = 16.0;
static const CGFloat CSToastMaxTitleLines       = 0;
static const CGFloat CSToastMaxMessageLines     = 0;
static const NSTimeInterval CSToastFadeDuration = 0.2;

// shadow appearance
static const CGFloat CSToastShadowOpacity       = 0.8;
static const CGFloat CSToastShadowRadius        = 6.0;
static const CGSize  CSToastShadowOffset        = { 4.0, 4.0 };
static const BOOL    CSToastDisplayShadow       = YES;

// display duration
static const NSTimeInterval CSToastDefaultDuration  = 2.0;

// image view size
static const CGFloat CSToastImageViewWidth      = 29;
static const CGFloat CSToastImageViewHeight     = 29;

// activity
static const CGFloat CSToastActivityWidth       = 100.0;
static const CGFloat CSToastActivityHeight      = 100.0;
static const NSString * CSToastActivityDefaultPosition = @"center";

// interaction
static const BOOL CSToastHidesOnTap             = YES;     // excludes activity views

// associative reference keys
static const NSString * CSToastTimerKey         = @"CSToastTimerKey";
static const NSString * CSToastActivityViewKey  = @"CSToastActivityViewKey";
static const NSString * CSToastTapCallbackKey   = @"CSToastTapCallbackKey";

// positions
NSString * const PYToastPositionTop                 = @"top";
NSString * const PYToastPositionBlowStatusBar       = @"BlowStatusBar";
NSString * const PYToastPositionBlowNavigationBar   = @"BlowNavigationBar";
NSString * const PYToastPositionCenter              = @"center";
NSString * const PYToastPositionBottom              = @"bottom";

@interface UIView (ToastPrivate)

- (void)hideToast:(UIView *)toast;
- (void)toastTimerDidFinish:(NSTimer *)timer;
- (void)handleToastTapped:(UITapGestureRecognizer *)recognizer;
- (CGPoint)centerPointForPosition:(id)position withToast:(UIView *)toast;
- (UIView *)viewForMessage:(NSString *)message title:(NSString *)title image:(UIImage *)image;
- (CGSize)sizeForString:(NSString *)string font:(UIFont *)font constrainedToSize:(CGSize)constrainedSize lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end


@implementation UIView (PYToast)

#pragma mark - Toast Methods

- (void)pymakeToast:(NSString *)message {
    //    [self pymakeToast:message duration:CSToastDefaultDuration position:CSToastPositionCenter];
    [self pymakeToast:message duration:CSToastDefaultDuration position:PYToastPositionCenter image:[UIImage imageNamed:@"PYLibrary.bundle/toastIcon"]];
}
- (void)pymakeNormalToast:(NSString *)message
{
    //    [self pymakeToast:message duration:CSToastDefaultDuration position:CSToastPositionCenter];
    //    UIImage *image = [[UIImage imageNamed:@"Resource.bundle/toastIcon"] getSubImage:CGRectMake(100, 0, 320, 60)];
    //    [self pymakeToast:message duration:CSToastDefaultDuration position:CSToastPositionCenter image:image];
    //修改为默认方法
    [self pymakeToast:message];
}
- (void)pymakeToast:(NSString *)message duration:(NSTimeInterval)duration position:(id)position {
    UIView *toast = [self viewForMessage:message title:nil image:[UIImage imageNamed:@"PYLibrary.bundle/toastIcon"]];
    [self showToast:toast duration:duration position:position];
}

- (void)pymakeToast:(NSString *)message duration:(NSTimeInterval)duration position:(id)position title:(NSString *)title {
    UIView *toast = [self viewForMessage:message title:title image:[UIImage imageNamed:@"PYLibrary.bundle/toastIcon"]];
    [self showToast:toast duration:duration position:position];
}

- (void)pymakeToast:(NSString *)message duration:(NSTimeInterval)duration position:(id)position image:(UIImage *)image {
    UIView *toast = [self viewForMessage:message title:nil image:image];
    [self showToast:toast duration:duration position:position];
}

- (void)pymakeToast:(NSString *)message duration:(NSTimeInterval)duration  position:(id)position title:(NSString *)title image:(UIImage *)image {
    UIView *toast = [self viewForMessage:message title:title image:image];
    [self showToast:toast duration:duration position:position];
}

- (void)showToast:(UIView *)toast {
    [self showToast:toast duration:CSToastDefaultDuration position:nil];
}


- (void)showToast:(UIView *)toast duration:(NSTimeInterval)duration position:(id)position {
    [self showToast:toast duration:duration position:position tapCallback:nil];

}


- (void)showToast:(UIView *)toast duration:(NSTimeInterval)duration position:(id)position
      tapCallback:(void(^)(void))tapCallback
{
    
    if (toast == nil) {
        return;
    }
    toast.center = [self centerPointForPosition:position withToast:toast];
    toast.alpha = 0.0;
    toast.tag = PYToastTag;
    if (CSToastHidesOnTap) {
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:toast action:@selector(handleToastTapped:)];
        [toast addGestureRecognizer:recognizer];
        toast.userInteractionEnabled = YES;
        toast.exclusiveTouch = YES;
    }
    //    CGFloat height = toast.frame.size.height;
    //    CGRect rect = toast.frame;
    //    rect.size.height = 0;
    //    toast.frame = rect;
    UIView *lastView = [self viewWithTag:PYToastTag];
    if (lastView) {
        [lastView removeFromSuperview];
    }
    [self addSubview:toast];
    //    rect.size.height = height;
    [UIView animateWithDuration:CSToastFadeDuration
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         toast.alpha = 1.0;
                         //                         toast.frame = rect;
                     } completion:^(BOOL finished) {
                         NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(toastTimerDidFinish:) userInfo:toast repeats:NO];
                         // associate the timer with the toast view
                         objc_setAssociatedObject (toast, &CSToastTimerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                         objc_setAssociatedObject (toast, &CSToastTapCallbackKey, tapCallback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                     }];
}


- (void)hideToast:(UIView *)toast {
    //    CGRect rect = toast.frame;
    //    rect.size.height = 0;
    [UIView animateWithDuration:CSToastFadeDuration
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         //                         toast.frame = rect;
                         toast.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [toast removeFromSuperview];
                     }];
}

#pragma mark - Events

- (void)toastTimerDidFinish:(NSTimer *)timer {
    [self hideToast:(UIView *)timer.userInfo];
}

- (void)handleToastTapped:(UITapGestureRecognizer *)recognizer {
    NSTimer *timer = (NSTimer *)objc_getAssociatedObject(self, &CSToastTimerKey);
    [timer invalidate];

    void (^callback)(void) = objc_getAssociatedObject(self, &CSToastTapCallbackKey);
    if (callback) {
        callback();
    }
    [self hideToast:recognizer.view];
}

#pragma mark - Toast Activity Methods

- (void)pymakeToastActivity {
    [self pymakeToastActivity:CSToastActivityDefaultPosition];
}

- (void)pymakeToastActivity:(id)position {
    // sanity
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &CSToastActivityViewKey);
    if (existingActivityView != nil) return;

    UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CSToastActivityWidth, CSToastActivityHeight)];
    activityView.center = [self centerPointForPosition:position withToast:activityView];
    activityView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:CSToastOpacity];
    activityView.alpha = 0.0;
    activityView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    activityView.layer.cornerRadius = CSToastCornerRadius;

    if (CSToastDisplayShadow) {
        activityView.layer.shadowColor = [UIColor blackColor].CGColor;
        activityView.layer.shadowOpacity = CSToastShadowOpacity;
        activityView.layer.shadowRadius = CSToastShadowRadius;
        activityView.layer.shadowOffset = CSToastShadowOffset;
    }

    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicatorView.center = CGPointMake(activityView.bounds.size.width / 2, activityView.bounds.size.height / 2);
    [activityView addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];

    // associate the activity view with self
    objc_setAssociatedObject (self, &CSToastActivityViewKey, activityView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [self addSubview:activityView];

    [UIView animateWithDuration:CSToastFadeDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         activityView.alpha = 1.0;
                     } completion:nil];
}

- (void)hideToastActivity {
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &CSToastActivityViewKey);
    if (existingActivityView != nil) {
        [UIView animateWithDuration:CSToastFadeDuration
                              delay:0.0
                            options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             existingActivityView.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [existingActivityView removeFromSuperview];
                             objc_setAssociatedObject (self, &CSToastActivityViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                         }];
    }
}

#pragma mark - Helpers

- (CGPoint)centerPointForPosition:(id)point withToast:(UIView *)toast {
    if([point isKindOfClass:[NSString class]]) {
        if([point caseInsensitiveCompare:PYToastPositionTop] == NSOrderedSame)
        {
            return CGPointMake(self.bounds.size.width/2, (toast.frame.size.height / 2));
        }
        else if([point caseInsensitiveCompare:PYToastPositionCenter] == NSOrderedSame)
        {
            return CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        }
        else if ([point caseInsensitiveCompare:PYToastPositionBlowStatusBar] == NSOrderedSame)
        {
            return CGPointMake(self.bounds.size.width / 2, 20 + (toast.frame.size.height / 2));
        }
        else if ([point caseInsensitiveCompare:PYToastPositionBlowNavigationBar] == NSOrderedSame)
        {
            return CGPointMake(self.bounds.size.width / 2, 64 + (toast.frame.size.height / 2));
        }
    } else if ([point isKindOfClass:[NSValue class]]) {
        return [point CGPointValue];
    }

    // default to bottom
    return CGPointMake(self.bounds.size.width/2, (self.bounds.size.height - (toast.frame.size.height / 2)) - CSToastVerticalPadding);
}

- (CGSize)sizeForString:(NSString *)string font:(UIFont *)font constrainedToSize:(CGSize)constrainedSize lineBreakMode:(NSLineBreakMode)lineBreakMode {
    if ([string respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = lineBreakMode;
        NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle};
        CGRect boundingRect = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        return CGSizeMake(ceilf(boundingRect.size.width), ceilf(boundingRect.size.height));
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [string sizeWithFont:font constrainedToSize:constrainedSize lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
}

- (UIView *)viewForMessage:(NSString *)message title:(NSString *)title image:(UIImage *)image {
    // sanity
    if((message == nil) && (title == nil) && (image == nil)) return nil;

    CGFloat wrapperWidth = [UIScreen mainScreen].bounds.size.width - 20;

    // dynamically build a toast view with any combination of message, title, & image.
    UILabel *messageLabel = nil;
    UILabel *titleLabel = nil;
    UIImageView *imageView = nil;

    // create the parent view
    UIView *wrapperView = [[UIView alloc] init];
    wrapperView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    wrapperView.layer.cornerRadius = CSToastCornerRadius;

    if (CSToastDisplayShadow) {
        wrapperView.layer.shadowColor = [UIColor blackColor].CGColor;
        wrapperView.layer.shadowOpacity = CSToastShadowOpacity;
        wrapperView.layer.shadowRadius = CSToastShadowRadius;
        wrapperView.layer.shadowOffset = CSToastShadowOffset;
    }

    wrapperView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:CSToastOpacity];

    if(image != nil) {
        imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = CGRectMake(CSToastHorizontalPadding, CSToastVerticalPadding, CSToastImageViewWidth, CSToastImageViewHeight);
    }

    CGFloat imageWidth, imageHeight, imageLeft;

    // the imageView frame values will be used to size & position the other views
    if(imageView != nil) {
        imageWidth = imageView.bounds.size.width;
        imageHeight = imageView.bounds.size.height;
        imageLeft = CSToastHorizontalPadding;
    } else {
        imageWidth = imageHeight = imageLeft = 0.0;
    }

    if (title != nil) {
        titleLabel = [[UILabel alloc] init];
        titleLabel.numberOfLines = CSToastMaxTitleLines;
        titleLabel.font = [UIFont boldSystemFontOfSize:CSToastFontSize];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.alpha = 1.0;
        titleLabel.text = title;
        //        titleLabel.textAlignment = NSTextAlignmentCenter;
        // size the title label according to the length of the text
        CGSize maxSizeTitle = CGSizeMake((self.bounds.size.width * CSToastMaxWidth) - imageWidth, self.bounds.size.height * CSToastMaxHeight);
        CGSize expectedSizeTitle = [self sizeForString:title font:titleLabel.font constrainedToSize:maxSizeTitle lineBreakMode:titleLabel.lineBreakMode];
        titleLabel.frame = CGRectMake(0.0, 0.0, expectedSizeTitle.width, expectedSizeTitle.height);
    }

    if (message != nil) {
        messageLabel = [[UILabel alloc] init];
        messageLabel.numberOfLines = CSToastMaxMessageLines;
        messageLabel.font = [UIFont systemFontOfSize:CSToastFontSize];
        messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.alpha = 1.0;
        messageLabel.text = message;
        //        messageLabel.textAlignment = NSTextAlignmentCenter;
        // size the message label according to the length of the text
        CGSize maxSizeMessage = CGSizeMake((self.bounds.size.width * CSToastMaxWidth) - imageWidth, self.bounds.size.height * CSToastMaxHeight);
        CGSize expectedSizeMessage = [self sizeForString:message font:messageLabel.font constrainedToSize:maxSizeMessage lineBreakMode:messageLabel.lineBreakMode];
        messageLabel.frame = CGRectMake(0.0, 0.0, expectedSizeMessage.width, expectedSizeMessage.height);
    }

    // titleLabel frame values
    CGFloat titleWidth, titleHeight, titleTop, titleLeft;

    if(titleLabel != nil) {
        titleWidth = titleLabel.bounds.size.width;
        titleHeight = titleLabel.bounds.size.height;
        titleTop = CSToastVerticalPadding;
        titleLeft = imageLeft + imageWidth + CSToastHorizontalPadding;
    } else {
        titleWidth = titleHeight = titleTop = titleLeft = 0.0;
    }

    // messageLabel frame values
    CGFloat messageWidth, messageHeight, messageLeft, messageTop;

    if(messageLabel != nil) {
        messageWidth = messageLabel.bounds.size.width;
        messageHeight = messageLabel.bounds.size.height;
        messageLeft = imageLeft + imageWidth + CSToastHorizontalPadding/2;// + (wrapperWidth - messageWidth)/2;
        if(titleLabel != nil)
        {
            messageTop = titleTop + titleHeight + CSToastVerticalPadding;
        }
        else if(imageView != nil)
        {
            if (imageHeight < messageHeight)
            {
                CGRect rect = imageView.frame;
                messageTop = CSToastVerticalPadding;
                rect.origin.y = messageTop + (messageHeight - rect.size.height) / 2;
                [imageView setFrame:rect];
            }
            else
            {
                messageTop = CSToastVerticalPadding + (imageHeight - messageHeight) / 2;
            }

        }
        else
        {
            messageTop = CSToastVerticalPadding;
        }
    } else {
        messageWidth = messageHeight = messageLeft = messageTop = 0.0;
    }

//    CGFloat longerWidth = MAX(titleWidth, messageWidth);
//    CGFloat longerLeft = MAX(titleLeft, messageLeft);

    // wrapper width uses the longerWidth or the image width, whatever is larger. same logic applies to the wrapper height
    //    CGFloat wrapperWidth = MAX((imageWidth + (CSToastHorizontalPadding * 2)), (longerLeft + longerWidth + CSToastHorizontalPadding));
    //    CGFloat wrapperWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat wrapperHeight = MAX((messageTop + messageHeight + CSToastVerticalPadding), (imageHeight + (CSToastVerticalPadding * 2)));

    wrapperView.frame = CGRectMake(0.0, 0.0, wrapperWidth, wrapperHeight);

    if(titleLabel != nil) {
        titleLabel.frame = CGRectMake(titleLeft, titleTop, titleWidth, titleHeight);
        [wrapperView addSubview:titleLabel];
    }

    if(messageLabel != nil) {
        messageLabel.frame = CGRectMake(messageLeft, messageTop, messageWidth, messageHeight);
        [wrapperView addSubview:messageLabel];
    }

    if(imageView != nil) {
        [wrapperView addSubview:imageView];
    }
    //    UIBezierPath *maskPath=  [UIBezierPath bezierPathWithRoundedRect:wrapperView.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(CSToastCornerRadius, CSToastCornerRadius)];
    //
    //    CAShapeLayer *maskLayer=[[CAShapeLayer alloc] init];
    //
    //    maskLayer.frame = wrapperView.bounds;
    //
    //    maskLayer.path = maskPath.CGPath;
    //
    //    wrapperView.layer.mask = maskLayer;
    //
    //    wrapperView.layer.masksToBounds=YES;

    return wrapperView;
}

/**
 *  全屏的toast,toast底下增加透明的bgView
 *
 *  @param message message description
 */
-(void)pymakeFullScreenToast:(NSString *)message
{
    UIView *toast = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [toast setBackgroundColor:[UIColor clearColor]];
    UIView *wrapperView =  [self viewForMessage:message title:nil image:[UIImage imageNamed:@"PYLibrary.bundle/toastIcon"]];
    CGPoint center =  CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    [wrapperView setCenter:center];

    [toast addSubview:wrapperView];
    [self showFullScreenToast:toast duration:CSToastDefaultDuration  tapCallback:nil];
}

- (void)showFullScreenToast:(UIView *)toast duration:(NSTimeInterval)duration
                tapCallback:(void(^)(void))tapCallback
{
    UIView *lastView = [self viewWithTag:PYToastTag];
    if (lastView) {
        [lastView removeFromSuperview];
    }
    [self addSubview:toast];
    //    rect.size.height = height;
    [UIView animateWithDuration:CSToastFadeDuration
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         toast.alpha = 1.0;
                         //                         toast.frame = rect;
                     } completion:^(BOOL finished) {
                         NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(toastTimerDidFinish:) userInfo:toast repeats:NO];
                         // associate the timer with the toast view
                         objc_setAssociatedObject (toast, &CSToastTimerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                         objc_setAssociatedObject (toast, &CSToastTapCallbackKey, tapCallback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                     }];
    
}
@end
