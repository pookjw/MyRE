#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>
#import <AVFoundation/AVFoundation.h>
#import <DirectResource/Defines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct REAsset * REAssetManagerCreateAssetHandle(struct REAssetManager *assetManager, const char *);
RE_EXTERN struct REAsset * REAssetManagerMemoryAssetCreateWithRemotePlayer(struct REAssetManager *assetManager, AVPlayer *player);
RE_EXTERN struct REAsset * REAssetManagerAVSampleBufferVideoRendererMemoryAssetCreate(struct REAssetManager *assetManager, AVSampleBufferVideoRenderer * _Nullable renderer);
RE_EXTERN struct REAssetLoadRequest * REAssetManagerCreateAssetRequest(struct REAssetManager *assetManager);
RE_EXTERN struct REAsset * REAssetManagerCreateTextureAssetFromData(struct REAssetManager *assetManager, const char * _Nullable name, struct RETextureAssetData *textureData);
RE_EXTERN struct REAsset * REAssetManagerCreateMeshAssetWithDirectMesh(struct REAssetManager *assetManager, struct DRMesh *mesh);

NS_ASSUME_NONNULL_END
