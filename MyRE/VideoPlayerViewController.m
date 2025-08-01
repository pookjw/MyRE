//
//  VideoPlayerViewController.m
//  MyRE
//
//  Created by Jinwoo Kim on 8/1/25.
//

// id<RERemoteVideoPlayer>

#import "VideoPlayerViewController.h"
#import <CoreRE/CoreRE.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKitPrivate/UIKitPrivate.h>
#import <MRUIKit/MRUIKit.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

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
    
    struct REEntity *entity = [self.view _reEntity];
    struct REEntity *customEntity = REEntityCreate();
    REEntityInsertChild(entity, customEntity, 0);
    
    struct REAssetManager *assetManager = MRUIDefaultAssetManager();
    NSURL *videoURL = [NSBundle.mainBundle URLForResource:@"video" withExtension:UTTypeMPEG4Movie.preferredFilenameExtension];
    assert(videoURL != nil);
    AVPlayer *player = [[AVPlayer alloc] initWithURL:videoURL];
    struct REAsset *videoAsset = REAssetManagerMemoryAssetCreateWithRemotePlayer(assetManager, player);
    
    struct REComponent *videoPlayerComponent = REEntityGetOrAddComponentByClass(customEntity, REVideoPlayerComponentGetComponentType());
    REVideoPlayerComponentSetVideoAsset(videoPlayerComponent, videoAsset);
    RERelease(videoAsset);
    
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
