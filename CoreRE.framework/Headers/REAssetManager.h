#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct REAsset * REAssetManagerCreateAssetHandle(struct REAssetManager *assetManager, const char *);
RE_EXTERN struct REAsset * REAssetManagerMemoryAssetCreateWithRemotePlayer(struct REAssetManager *assetManager, AVPlayer *player);
RE_EXTERN struct REAsset * REAssetManagerAVSampleBufferVideoRendererMemoryAssetCreate(struct REAssetManager *assetManager, AVSampleBufferVideoRenderer * _Nullable renderer);

NS_ASSUME_NONNULL_END
