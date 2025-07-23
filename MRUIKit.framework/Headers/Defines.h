#import <CoreRE/REServiceLocator.h>

#ifdef __cplusplus
#define MRUI_EXTERN       extern "C"
#else
#define MRUI_EXTERN           extern
#endif

NS_ASSUME_NONNULL_BEGIN

MRUI_EXTERN struct RECALayerService * MRUIDefaultLayerService(void);
MRUI_EXTERN void MRUIApplyBaseConfigurationToNewEntity(struct REEntity *entity);

NS_ASSUME_NONNULL_END
