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
#include <vector>
#include <ranges>

// [MRUIEntityAttachedStorage, Network, RCPInputTarget, RealityKit.__EntityInfoComponent, SpatialMedia, SpatialMediaStatus, Transform, UIEntityAttachedStorage, VideoPlayer, VideoPlayerStatus]

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
    
    //
    
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
        RETransformComponentSetLocalScale(transformComponent, simd_make_float3(0.2f, 0.2f, 0.2f));
        RETransformComponentSetWorldPosition(transformComponent, simd_make_float3(-0.1f, 0.f, 0.1f));
    }
    
    REEntityAddComponentByClass(customEntity, RENetworkComponentGetComponentType());
    struct REComponent *spatialMediaComponent = REEntityAddComponentByClass(customEntity, RESpatialMediaComponentGetComponentType());
    REEntityAddComponentByClass(customEntity, RESpatialMediaStatusComponentGetComponentType());
    struct REComponent *videoPlayerStatusComponent = REEntityAddComponentByClass(customEntity, REVideoPlayerStatusComponentGetComponentType());
    
    RERelease(customEntity);
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [player play];
    [player release];
    
    //
    
    UIBarButtonItem *menuBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" image:[UIImage systemImageNamed:@"filemenu.and.selection"] target:nil action:nil menu:[self _makeMenuWithVideoPlayerComponent:videoPlayerComponent videoPlayerStatusComponent:videoPlayerStatusComponent spatialMediaComponent:spatialMediaComponent]];
    self.navigationItem.rightBarButtonItem = menuBarButtonItem;
    [menuBarButtonItem release];
}

- (void)didPlayToEnd:(NSNotification *)notification {
    if ([notification.object isEqual:self.player.currentItem]) {
        [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            [self.player play];
        }];
    }
}

- (UIMenu *)_makeMenuWithVideoPlayerComponent:(struct REComponent *)videoPlayerComponent videoPlayerStatusComponent:(struct REComponent *)videoPlayerStatusComponent spatialMediaComponent:(struct REComponent *)spatialMediaComponent {
    AVPlayer *player = self.player;
    
    UIDeferredMenuElement *element = [UIDeferredMenuElement elementWithUncachedProvider:^(void (^ _Nonnull completion)(NSArray<UIMenuElement *> * _Nonnull)) {
        NSMutableArray<__kindof UIMenuElement *> *elements = [[NSMutableArray alloc] init];
        
        {
            UIAction *flatVideoAction = [UIAction actionWithTitle:@"Flat Video" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                NSURL *videoURL = [NSBundle.mainBundle URLForResource:@"video" withExtension:UTTypeMPEG4Movie.preferredFilenameExtension];
                assert(videoURL != nil);
                AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:videoURL];
                [player replaceCurrentItemWithPlayerItem:playerItem];
                [playerItem release];
            }];
            
            UIAction *spatialVideoAction = [UIAction actionWithTitle:@"Spatial Video" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                NSURL *videoURL = [NSBundle.mainBundle URLForResource:@"spatial_video" withExtension:UTTypeQuickTimeMovie.preferredFilenameExtension];
                assert(videoURL != nil);
                AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:videoURL];
                [player replaceCurrentItemWithPlayerItem:playerItem];
                [playerItem release];
            }];
            
            UIMenu *menu = [UIMenu menuWithTitle:@"Video Type" children:@[flatVideoAction, spatialVideoAction]];
            [elements addObject:menu];
        }
        
        {
            if (player.rate == 0.f) {
                UIAction *action = [UIAction actionWithTitle:@"Play" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                    player.rate = 1.f;
                }];
                [elements addObject:action];
            } else {
                UIAction *action = [UIAction actionWithTitle:@"Pause" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                    player.rate = 0.f;
                }];
                [elements addObject:action];
            }
        }
        
        {
            unsigned int currentImmersiveViewingMode = REVideoPlayerStatusComponentGetCurrentImmersiveViewingMode(videoPlayerStatusComponent);
            unsigned int desiredImmersiveViewingMode = REVideoPlayerComponentGetDesiredImmersiveViewingMode(videoPlayerComponent);
            auto actionsVec = std::views::iota(0, 3)
            | std::views::transform([videoPlayerComponent, currentImmersiveViewingMode, desiredImmersiveViewingMode](unsigned int immersiveViewingMode) -> UIAction * {
                NSString *title;
                if (immersiveViewingMode == 0) {
                    title = @"Full";
                } else if (immersiveViewingMode == 1) {
                    title = @"Portal";
                } else if (immersiveViewingMode == 2) {
                    title = @"Progressive";
                } else {
                    abort();
                }
                
                UIAction *action = [UIAction actionWithTitle:title image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                    REVideoPlayerComponentSetDesiredImmersiveViewingMode(videoPlayerComponent, immersiveViewingMode);
                }];
                
                if (immersiveViewingMode == currentImmersiveViewingMode) {
                    action.state = UIMenuElementStateOn;
                } else if (immersiveViewingMode == desiredImmersiveViewingMode) {
                    action.state = UIMenuElementStateMixed;
                } else {
                    action.state = UIMenuElementStateOff;
                }
                
                return action;
            })
            | std::ranges::to<std::vector<UIAction *>>();
            
            NSArray<UIAction *> *actions = [[NSArray alloc] initWithObjects:actionsVec.data() count:actionsVec.size()];
            UIMenu *menu = [UIMenu menuWithTitle:@"Immersive Viewing Mode" children:actions];
            [elements addObject:menu];
        }
        
        {
            unsigned int currentSpatialVideoMode = REVideoPlayerStatusComponentGetCurrentSpatialVideoMode(videoPlayerStatusComponent);
            unsigned int desiredSpatialVideoMode = REVideoPlayerComponentGetDesiredSpatialVideoMode(videoPlayerComponent);
            auto actionsVec = std::views::iota(0, 2)
            | std::views::transform([videoPlayerComponent, currentSpatialVideoMode, desiredSpatialVideoMode](unsigned int spatialVideoMode) -> UIAction * {
                NSString *title;
                if (spatialVideoMode == 0) {
                    title = @"Screen";
                } else if (spatialVideoMode == 1) {
                    title = @"Spatial";
                } else {
                    abort();
                }
                
                UIAction *action = [UIAction actionWithTitle:title image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                    REVideoPlayerComponentSetDesiredSpatialVideoMode(videoPlayerComponent, spatialVideoMode);
                }];
                
                if (spatialVideoMode == currentSpatialVideoMode) {
                    action.state = UIMenuElementStateOn;
                } else if (spatialVideoMode == desiredSpatialVideoMode) {
                    action.state = UIMenuElementStateMixed;
                } else {
                    action.state = UIMenuElementStateOff;
                }
                
                return action;
            })
            | std::ranges::to<std::vector<UIAction *>>();
            
            NSArray<UIAction *> *actions = [[NSArray alloc] initWithObjects:actionsVec.data() count:actionsVec.size()];
            UIMenu *menu = [UIMenu menuWithTitle:@"Spatial Video Mode" children:actions];
            [elements addObject:menu];
        }
        
        {
            unsigned int currentViewingMode = REVideoPlayerStatusComponentGetCurrentViewingMode(videoPlayerStatusComponent);
            unsigned int desiredViewingMode = REVideoPlayerComponentGetDesiredViewingMode(videoPlayerComponent);
            auto actionsVec = std::views::iota(0, 2)
            | std::views::transform([videoPlayerComponent, currentViewingMode, desiredViewingMode](unsigned int viewingMode) -> UIAction * {
                NSString *title;
                if (viewingMode == 0) {
                    title = @"Mono";
                } else if (viewingMode == 1) {
                    title = @"Stereo";
                } else {
                    abort();
                }
                
                UIAction *action = [UIAction actionWithTitle:title image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                    REVideoPlayerComponentSetDesiredViewingMode(videoPlayerComponent, viewingMode);
                }];
                
                if (viewingMode == currentViewingMode) {
                    action.state = UIMenuElementStateOn;
                } else if (viewingMode == desiredViewingMode) {
                    action.state = UIMenuElementStateMixed;
                } else {
                    action.state = UIMenuElementStateOff;
                }
                
                return action;
            })
            | std::ranges::to<std::vector<UIAction *>>();
            
            NSArray<UIAction *> *actions = [[NSArray alloc] initWithObjects:actionsVec.data() count:actionsVec.size()];
            UIMenu *menu = [UIMenu menuWithTitle:@"Viewing Mode" children:actions];
            [elements addObject:menu];
        }
        
        {
            BOOL passthroughTintingEnabled = REVideoPlayerComponentGetIsPassthroughTintingEnabled(videoPlayerComponent);
            UIAction *action = [UIAction actionWithTitle:@"Passthrough Tinting" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                REVideoPlayerComponentSetIsPassthroughTintingEnabled(videoPlayerComponent, !passthroughTintingEnabled);
            }];
            action.state = (passthroughTintingEnabled ? UIMenuElementStateOn : UIMenuElementStateOff);
            [elements addObject:action];
        }
        
        {
            BOOL flatGeometry = RESpatialMediaComponentGetIsFlatGeometry(spatialMediaComponent);
            UIAction *action = [UIAction actionWithTitle:@"Flat Geometry" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                RESpatialMediaComponentSetIsFlatGeometry(spatialMediaComponent, !flatGeometry);
            }];
            action.state = (flatGeometry ? UIMenuElementStateOn : UIMenuElementStateOff);
            [elements addObject:action];
        }
        
        completion(elements);
        [elements release];
    }];
    
    UIMenu *menu = [UIMenu menuWithChildren:@[element]];
    return menu;;
}

@end
