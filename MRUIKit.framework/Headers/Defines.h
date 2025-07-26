#import <CoreRE/REServiceLocator.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreRE/Defines.h>

#ifdef __cplusplus
#define MRUI_EXTERN       extern "C"
#else
#define MRUI_EXTERN           extern
#endif

NS_ASSUME_NONNULL_BEGIN

MRUI_EXTERN struct RECALayerService * MRUIDefaultLayerService(void);
MRUI_EXTERN void MRUIApplyBaseConfigurationToNewEntity(struct REEntity *entity);
MRUI_EXTERN NSString * MRUIEntityViewLayerRecursiveDescription(struct REEntity * _Nullable entity, UIView * _Nullable view, CALayer * _Nullable layer, NSString *multilinePrefix, NSUInteger options, BOOL viewDesc);

NS_ASSUME_NONNULL_END
