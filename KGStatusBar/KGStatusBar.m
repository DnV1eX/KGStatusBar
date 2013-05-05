//
//  KGStatusBar.m
//
//  Created by Kevin Gibbon on 2/27/13.
//  Copyright 2013 Kevin Gibbon. All rights reserved.
//  @kevingibbon
//

#import "KGStatusBar.h"

NSString *const KGStatusBarTapNotification = @"KGStatusBarTapNotification";

@interface KGStatusBar ()
    @property (nonatomic, strong, readonly) UIView *topBar;
    @property (nonatomic, strong) UILabel *stringLabel;
    @property (nonatomic, strong) UIActivityIndicatorView *spinner;
    @property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@end

@implementation KGStatusBar

@synthesize topBar, stringLabel;

+ (KGStatusBar*)sharedView {
    static dispatch_once_t once;
    static KGStatusBar *sharedView;
    dispatch_once(&once, ^ { sharedView = [[KGStatusBar alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; });
    return sharedView;
}

+ (void)showSuccessWithStatus:(NSString*)status
{
    [KGStatusBar showWithStatus:status];
    [KGStatusBar performSelector:@selector(dismiss) withObject:self afterDelay:2.0 ];
}

+(void)showLoadingWithStatus:(NSString *)status
{
    [[KGStatusBar sharedView] showWithStatus:status barColor:[UIColor blackColor] textColor:[UIColor colorWithRed:191.0/255.0 green:191.0/255.0 blue:191.0/255.0 alpha:1.0]];
    [[KGStatusBar sharedView].spinner startAnimating];
}

+ (void)showWithStatus:(NSString*)status {
    [[KGStatusBar sharedView] showWithStatus:status barColor:[UIColor blackColor] textColor:[UIColor colorWithRed:191.0/255.0 green:191.0/255.0 blue:191.0/255.0 alpha:1.0]];
}

+ (void)showErrorWithStatus:(NSString*)status {
    [[KGStatusBar sharedView] showWithStatus:status barColor:[UIColor colorWithRed:97.0/255.0 green:4.0/255.0 blue:4.0/255.0 alpha:1.0] textColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]];
    [KGStatusBar performSelector:@selector(dismiss) withObject:self afterDelay:2.0 ];
}

+ (void)dismiss {
    [[KGStatusBar sharedView] dismiss];
}

- (id)initWithFrame:(CGRect)frame {
	
    if ((self = [super initWithFrame:frame])) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor clearColor];
//        self.userInteractionEnabled = NO;
        self.windowLevel = UIWindowLevelStatusBar;
        
        // Transform depending on interafce orientation
        CGAffineTransform rotationTransform = CGAffineTransformMakeRotation([self rotation]);
        self.transform = rotationTransform;
        self.bounds = CGRectMake(0.f, 0.f, [self rotatedSize].width, [self rotatedSize].height);
        
        // Register for orientation changes
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleRoration:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    return self;
}

- (void)tapStatusBar {
    [[NSNotificationCenter defaultCenter] postNotificationName:KGStatusBarTapNotification object:self];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.tapGestureRecognizer && [self.topBar pointInside:point withEvent:event]) return self.topBar;
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    return [keyWindow hitTest:[keyWindow convertPoint:point fromWindow:self] withEvent:event];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showWithStatus:(NSString *)status barColor:(UIColor*)barColor textColor:(UIColor*)textColor {
    [_spinner stopAnimating];
    self.hidden = NO;
    self.topBar.hidden = NO;
    self.topBar.backgroundColor = barColor;
    NSString *labelText = status;
    CGRect labelRect = CGRectZero;
    CGFloat stringWidth = 0;
    CGFloat stringHeight = 0;
    if(labelText) {
        CGSize stringSize = [labelText sizeWithFont:self.stringLabel.font constrainedToSize:CGSizeMake(self.topBar.frame.size.width, self.topBar.frame.size.height)];
        stringWidth = stringSize.width;
        stringHeight = stringSize.height;
        
        labelRect = CGRectMake((self.topBar.frame.size.width / 2) - (stringWidth / 2), 0, stringWidth, stringHeight);
    }
    self.stringLabel.frame = labelRect;
    self.stringLabel.alpha = 0.0;
    self.stringLabel.hidden = NO;
    self.stringLabel.text = labelText;
    self.stringLabel.textColor = textColor;
    [UIView animateWithDuration:0.4 animations:^{
        self.stringLabel.alpha = 1.0;
    }];
    [self setNeedsDisplay];
}

- (void)dismiss
{
    [UIView animateWithDuration:0.4 animations:^{
        self.stringLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        [topBar removeFromSuperview];
        topBar = nil;
        [_spinner removeFromSuperview];
        _spinner = nil;
        self.tapGestureRecognizer = nil;
        self.hidden = YES;
    }];
}

- (UIView *)topBar {
    if(!topBar) {
        topBar = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, [self rotatedSize].width, 20.f)];
        [self addSubview:topBar];
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapStatusBar)];
        [topBar addGestureRecognizer:self.tapGestureRecognizer];
    }
    return topBar;
}

- (UILabel *)stringLabel {
    if (stringLabel == nil) {
        stringLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		stringLabel.textColor = [UIColor colorWithRed:191.0/255.0 green:191.0/255.0 blue:191.0/255.0 alpha:1.0];
		stringLabel.backgroundColor = [UIColor clearColor];
		stringLabel.adjustsFontSizeToFitWidth = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
        stringLabel.textAlignment = UITextAlignmentCenter;
#else
        stringLabel.textAlignment = NSTextAlignmentCenter;
#endif
		stringLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		stringLabel.font = [UIFont boldSystemFontOfSize:14.0];
		stringLabel.shadowColor = [UIColor blackColor];
		stringLabel.shadowOffset = CGSizeMake(0, -1);
        stringLabel.numberOfLines = 0;
        stringLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    
    if(!stringLabel.superview)
        [self.topBar addSubview:stringLabel];
    
    return stringLabel;
}

-(UIActivityIndicatorView *)spinner
{
    if (_spinner == nil)
    {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _spinner.transform = CGAffineTransformMakeScale(0.8, 0.8);
        _spinner.center = CGPointMake(CGRectGetMinX(self.stringLabel.frame) - 25, self.stringLabel.center.y);
        [_spinner setHidesWhenStopped:YES];
        [self.topBar addSubview:_spinner];
    }
    return _spinner;
}

#pragma mark - Handle Rotation

- (CGFloat)rotation
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat rotation = 0.f;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft: { rotation = -M_PI_2; } break;
        case UIInterfaceOrientationLandscapeRight: { rotation = M_PI_2; } break;
        case UIInterfaceOrientationPortraitUpsideDown: { rotation = M_PI; } break;
        case UIInterfaceOrientationPortrait: { } break;
        default: break;
    }
    return rotation;
}

- (CGSize)rotatedSize
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGSize rotatedSize = screenSize;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft: { rotatedSize = CGSizeMake(screenSize.height, screenSize.width); } break;
        case UIInterfaceOrientationLandscapeRight: { rotatedSize = CGSizeMake(screenSize.height, screenSize.width); } break;
        case UIInterfaceOrientationPortraitUpsideDown: { } break;
        case UIInterfaceOrientationPortrait: { } break;
        default: break;
    }
    return rotatedSize;
}

- (void)handleRoration:(id)sender
{
    // Based on http://stackoverflow.com/questions/8774495/view-on-top-of-everything-uiwindow-subview-vs-uiviewcontroller-subview
    
    CGAffineTransform rotationTransform = CGAffineTransformMakeRotation([self rotation]);
    [UIView animateWithDuration:[[UIApplication sharedApplication] statusBarOrientationAnimationDuration]
                       animations:^{
                           self.transform = rotationTransform;
                           // Transform invalidates the frame, so use bounds/center
                           self.bounds = CGRectMake(0.f, 0.f, [self rotatedSize].width, [self rotatedSize].height);
                           self.topBar.frame = CGRectMake(0.f, 0.f, [self rotatedSize].width, 20.f);
                           _spinner.center = CGPointMake(CGRectGetMinX(self.stringLabel.frame) - 25, self.stringLabel.center.y);
                       }];
}

@end
