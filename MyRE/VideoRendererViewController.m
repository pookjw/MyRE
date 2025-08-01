//
//  VideoRendererViewController.m
//  MyRE
//
//  Created by Jinwoo Kim on 8/2/25.
//

#import "VideoRendererViewController.h"
#import <CoreRE/CoreRE.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKitPrivate/UIKitPrivate.h>
#import <MRUIKit/MRUIKit.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#include <TargetConditionals.h>
#include <objc/runtime.h>
#include <objc/message.h>

@interface VideoRendererViewController ()
@property (retain, nonatomic, nullable) AVSampleBufferVideoRenderer *videoRenderer;
@property (retain, nonatomic, nullable) AVSampleBufferAudioRenderer *audioRenderer;
@property (retain, nonatomic, nullable) AVSampleBufferRenderSynchronizer *renderSynchronizer;
@property (retain, nonatomic, nullable) AVAssetReader *assetReader;
@property (assign, nonatomic, nullable) struct REAsset *videoAsset;
@end

@implementation VideoRendererViewController

- (void)dealloc {
    [_videoRenderer stopRequestingMediaData];
    [_videoRenderer release];
    [_audioRenderer stopRequestingMediaData];
    [_audioRenderer release];
    [_renderSynchronizer release];
    [_assetReader cancelReading];
    [_assetReader release];
    if (_videoAsset != NULL) {
        RERelease(_videoAsset);
    }
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVAssetReader *assetReader = (AVAssetReader *)object;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.assetReader isEqual:assetReader]) {
                if (assetReader.status == AVAssetReaderStatusCompleted) {
                    [self configureAssetReader];
                }
            }
        });
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view _requestSeparatedState:1 withReason:@"_UIViewSeparatedStateRequestReasonUnspecified"];
    
    struct REEntity *entity = [self.view _reEntity];
    struct REEntity *customEntity = REEntityCreate();
    REEntitySetParent(customEntity, entity);
    
    struct REAssetManager *assetManager = MRUIDefaultAssetManager();
    struct REAsset *videoAsset = REAssetManagerAVSampleBufferVideoRendererMemoryAssetCreate(assetManager, nil);
    
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
    
    self.videoAsset = videoAsset;
    RERetain(videoAsset);
    [self configureAssetReader];
}

- (void)configureAssetReader {
    if (self.assetReader != nil) {
        assert(self.assetReader.error == nil);
        [self.videoRenderer stopRequestingMediaData];
        self.videoRenderer = nil;
        [self.audioRenderer stopRequestingMediaData];
        self.audioRenderer = nil;
        [self.assetReader removeObserver:self forKeyPath:@"status"];
        self.assetReader = nil;
        self.renderSynchronizer = nil;
    }
    
    NSURL *videoURL = [NSBundle.mainBundle URLForResource:@"spatial_video" withExtension:UTTypeQuickTimeMovie.preferredFilenameExtension];
    assert(videoURL != nil);
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSError * _Nullable error = nil;
    AVAssetReader *assetReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    assert(assetReader != nil);
    self.assetReader = assetReader;
    [assetReader addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
    [asset release];
    
    AVAssetTrack *videoTrack = ((NSArray<AVAssetTrack *> * (*)(id, SEL, id))objc_msgSend)(asset, sel_registerName("tracksWithMediaType:"), AVMediaTypeVideo).firstObject;
    assert(videoTrack != nil);
    AVAssetTrack *audioTrack = ((NSArray<AVAssetTrack *> * (*)(id, SEL, id))objc_msgSend)(asset, sel_registerName("tracksWithMediaType:"), AVMediaTypeAudio).firstObject;
    assert(audioTrack != nil);
    
    AVAssetReaderTrackOutput *videoTrackOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:nil];
    [assetReader addOutput:videoTrackOutput];
    
    AVAssetReaderTrackOutput *audioTrackOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:audioTrack outputSettings:nil];
    [assetReader addOutput:audioTrackOutput];
    
    [assetReader startReading];
    [assetReader release];
    
    AVSampleBufferVideoRenderer *videoRenderer = [[AVSampleBufferVideoRenderer alloc] init];
    [videoRenderer requestMediaDataWhenReadyOnQueue:dispatch_get_global_queue(0, 0) usingBlock:^{
        while (videoRenderer.readyForMoreMediaData) {
            CMSampleBufferRef _Nullable sampleBuffer = [videoTrackOutput copyNextSampleBuffer];
            if (sampleBuffer != NULL) {
                [videoRenderer enqueueSampleBuffer:sampleBuffer];
                CFRelease(sampleBuffer);
            } else {
                return;
            }
        }
    }];
    self.videoRenderer = videoRenderer;
    REVideoAssetSetAVSampleBufferVideoRenderer(self.videoAsset, videoRenderer);
    [videoRenderer release];
    
    AVSampleBufferAudioRenderer *audioRenderer = [[AVSampleBufferAudioRenderer alloc] init];
    self.audioRenderer = audioRenderer;
    [audioRenderer requestMediaDataWhenReadyOnQueue:dispatch_get_global_queue(0, 0) usingBlock:^{
        while (audioRenderer.readyForMoreMediaData) {
            CMSampleBufferRef _Nullable sampleBuffer = [audioTrackOutput copyNextSampleBuffer];
            if (sampleBuffer != NULL) {
                [audioRenderer enqueueSampleBuffer:sampleBuffer];
                CFRelease(sampleBuffer);
            } else {
                return;
            }
        }
    }];
    [audioRenderer release];
    
    AVSampleBufferRenderSynchronizer *renderSynchronizer = [[AVSampleBufferRenderSynchronizer alloc] init];
    [renderSynchronizer addRenderer:self.videoRenderer];
    [renderSynchronizer addRenderer:self.audioRenderer];
    self.renderSynchronizer = renderSynchronizer;
    [renderSynchronizer setRate:1.f time:kCMTimeZero];
    [renderSynchronizer release];
}

@end
