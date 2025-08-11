#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN void RERenderGraphEmitterPreloadProvidersAssets(struct REAsset *asset, struct RERenderManager *renderManager);
RE_EXTERN void RERenderGraphEmitterAssetRegisterProviders(struct REAsset *asset, struct RERenderManager *renderManager);

NS_ASSUME_NONNULL_END
