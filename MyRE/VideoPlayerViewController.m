//
//  VideoPlayerViewController.m
//  MyRE
//
//  Created by Jinwoo Kim on 8/1/25.
//

#import "VideoPlayerViewController.h"
#import <CoreRE/CoreRE.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKitPrivate/UIKitPrivate.h>
#import <MRUIKit/MRUIKit.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#include <TargetConditionals.h>

@interface VideoPlayerViewController ()
@property (retain, nonatomic, nullable) AVPlayer *player;
@end

@implementation VideoPlayerViewController

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [_player release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view _requestSeparatedState:1 withReason:@"_UIViewSeparatedStateRequestReasonUnspecified"];
    
    NSURL *videoURL = [NSBundle.mainBundle URLForResource:@"spatial_video" withExtension:UTTypeQuickTimeMovie.preferredFilenameExtension];
    assert(videoURL != nil);
    
    AVPlayer *player = [[AVPlayer alloc] initWithURL:videoURL];
    self.player = player;
    
    struct REEntity *entity = [self.view _reEntity];
    struct REEntity *customEntity = REEntityCreate();
    REEntitySetParent(customEntity, entity);
    
    struct REAssetManager *assetManager = MRUIDefaultAssetManager();
    struct REAsset *videoAsset = REAssetManagerMemoryAssetCreateWithRemotePlayer(assetManager, player);
    
    struct REComponent *videoPlayerComponent = REEntityGetOrAddComponentByClass(customEntity, REVideoPlayerComponentGetComponentType());
    REVideoPlayerComponentSetScreenRoundedCornerEnabled(videoPlayerComponent, YES);
    REVideoPlayerComponentSetScaleRoundedCornerEnabled(videoPlayerComponent, YES);
    REVideoPlayerComponentSetScreenAspectRatioAnimationEnabled(videoPlayerComponent, YES);
    REVideoPlayerComponentSetScreenDeferAspectRatioTransitionToApp(videoPlayerComponent, NO);
//    AVPlayerCaptionLayer *captionLayer;
    REVideoPlayerComponentSetEnableSpecularAndFresnelEffects(videoPlayerComponent, NO);
    REVideoPlayerComponentSetBevelFrontDepth(videoPlayerComponent, 3.);
    REVideoPlayerComponentSetEnableReflections(videoPlayerComponent, YES);
    REVideoPlayerComponentSetDesiredViewingMode(videoPlayerComponent, 2);
    REVideoPlayerComponentSetDesiredImmersiveViewingMode(videoPlayerComponent, 2);
    REVideoPlayerComponentSetIsPassthroughTintingEnabled(videoPlayerComponent, NO);
    REVideoPlayerComponentSetIsMediaTintingEnabled(videoPlayerComponent, YES);
    REVideoPlayerComponentSetMaxGlowIntensity(videoPlayerComponent, 0.45);
    REVideoPlayerComponentSetCaptionsOffset(videoPlayerComponent, CGPointZero);
    REVideoPlayerComponentSetIsAutoPauseOnHighMotionEnabled(videoPlayerComponent, YES);
    REVideoPlayerComponentSetDesiredSpatialVideoMode(videoPlayerComponent, 0);
    REVideoPlayerComponentSetLowLatencyEnabled(videoPlayerComponent, NO);
    REVideoPlayerComponentSetScreenWrapTheta(videoPlayerComponent, NO);
    REVideoPlayerComponentSetScreenWrapPostive(videoPlayerComponent, NO);
    REVideoPlayerComponentSetScreenWrapAnimation(videoPlayerComponent, NO);
    REVideoPlayerComponentSetUsesCurvedUIStyleSystemTreatments(videoPlayerComponent, NO);
    REVideoPlayerComponentSetScreenAspectRatio(videoPlayerComponent, 0.);
    REVideoPlayerComponentSetLoadingTextureAspectRatioHint(videoPlayerComponent, 1.78);
    REVideoPlayerComponentSetLoadingTextureHorizontalFOVHint(videoPlayerComponent, 70.215736389160156);
#if TARGET_OS_SIMULATOR
    REVideoPlayerComponentSetSpatialGalleryRenderingEnabled(videoPlayerComponent, NO);
#endif
    REVideoPlayerComponentPreloadVideoAsset(videoPlayerComponent);
    REVideoPlayerComponentSetVideoAsset(videoPlayerComponent, videoAsset);
    RERelease(videoAsset);
    
    {
        struct REComponent *transformComponent = REEntityGetOrAddComponentByClass(customEntity, RETransformComponentGetComponentType());
        RETransformComponentSetLocalScale(transformComponent, simd_make_float3(0.4f, 0.4f, 0.4f));
        RETransformComponentSetWorldPosition(transformComponent, simd_make_float3(0.f, 0.f, 0.1f));
    }
    
    REEntityAddComponentByClass(customEntity, RENetworkComponentGetComponentType());
    REEntityAddComponentByClass(customEntity, RESpatialMediaStatusComponentGetComponentType());
    REEntityAddComponentByClass(customEntity, REVideoPlayerStatusComponentGetComponentType());
    
    RERelease(customEntity);
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [player play];
    [player release];
}

- (void)didPlayToEnd:(NSNotification *)notification {
    if ([notification.object isEqual:self.player.currentItem]) {
        [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            [self.player play];
        }];
    }
}

@end
