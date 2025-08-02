#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN void REAssetLoadRequestAddAsset(struct REAssetLoadRequest *request, struct REAsset *asset);
RE_EXTERN BOOL REAssetLoadRequestSetLoadAndWaitForResourceSharingClients(struct REAssetLoadRequest *request, BOOL, BOOL, NSError * __autoreleasing _Nullable * _Nullable error);
RE_EXTERN void REAssetLoadRequestSetCompletionHandler(struct REAssetLoadRequest *request, void (^ _Nullable)(BOOL success));
RE_EXTERN void REAssetLoadRequestSetCompletionHandlerOnQueue(struct REAssetLoadRequest *request, void (^ _Nullable)(BOOL success), dispatch_queue_t queue);

NS_ASSUME_NONNULL_END
