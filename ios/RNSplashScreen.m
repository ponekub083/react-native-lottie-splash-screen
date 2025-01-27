/**
 * SplashScreen
 * 启动屏
 * from：http://www.devio.org
 * Author:CrazyCodeBoy
 * GitHub:https://github.com/crazycodeboy
 * Email:crazycodeboy@gmail.com
 */

#import "RNSplashScreen.h"
#import <React/RCTBridge.h>

static bool waitingEnd = true; 
static bool addedJsLoadErrorObserver = false;
static UIView* loadingView = nil;

static bool hideTriggle = false;
static bool animationEnd = false;

@implementation RNSplashScreen
- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE(SplashScreen)

+ (void)show {
  if (!addedJsLoadErrorObserver) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(jsLoadError:)
                                              name:RCTJavaScriptDidFailToLoadNotification
                                              object:nil];
    addedJsLoadErrorObserver = true;
  }

  while (waitingEnd) {
    NSDate* later = [NSDate dateWithTimeIntervalSinceNow:0.1];
    [[NSRunLoop mainRunLoop] runUntilDate:later];
  }
}

+ (void)showSplash:(NSString*)splashScreen inRootView:(UIView*)rootView {
  if (!loadingView) {
    loadingView = [[[NSBundle mainBundle] loadNibNamed:splashScreen owner:self
                                                options:nil] objectAtIndex:0];
    CGRect frame = rootView.frame;
    frame.origin = CGPointMake(0, 0);
    loadingView.frame = frame;
  }
  [rootView addSubview:loadingView];
}

+ (void)showLottieSplash:(UIView*)animationView inRootView:(UIView*)rootView waitEnd:(Boolean)wait {
    loadingView = animationView;
    waitingEnd = wait;
    [rootView addSubview:animationView];
}

+ (void)hide {
    if(waitingEnd && !animationEnd && !hideTriggle){
        hideTriggle = true;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)),
                dispatch_get_main_queue(), ^{
                animationEnd = true;
            });
    }
    else if(animationEnd) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
            dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5
                animations:^{loadingView.alpha = 0.0;}
                completion:^(BOOL finished){ [loadingView removeFromSuperview]; }];
        });
    }
}

+(void)hideForce {
    dispatch_async(dispatch_get_main_queue(), ^{
      [loadingView removeFromSuperview];
    });
}

+(void)setAnimationFinished:(Boolean)flag {
    animationEnd = flag;
}

+ (Boolean)getHideTrigger{
    return  hideTriggle;
}

+ (void)jsLoadError:(NSNotification*)notification {
  // If there was an error loading javascript, hide the splash screen so it can be shown.  Otherwise
  // the splash screen will remain forever, which is a hassle to debug.
  [RNSplashScreen hide];
}

RCT_EXPORT_METHOD(hide) { [RNSplashScreen hide]; }

RCT_EXPORT_METHOD(show) { [RNSplashScreen show]; }

@end
