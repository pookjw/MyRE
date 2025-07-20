#import <Foundation/Foundation.h>
#import <CoreRE/REDefines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct NSString * REAssetHandleCopyAssetPath(struct REAssetHandle *asset);
RE_EXTERN struct REAssetHandle * REAssetHandleCreateNewMutableWithAssetDescriptors(struct REAssetManager *assetManager, struct REAssetLoadDescriptor **descriptors, unsigned int count);
RE_EXTERN void REAssetHandleLoadNow(struct REAssetHandle *asset);
RE_EXTERN void REAssetSetNetworkSharingMode(struct REAssetHandle *asset, bool);

NS_ASSUME_NONNULL_END