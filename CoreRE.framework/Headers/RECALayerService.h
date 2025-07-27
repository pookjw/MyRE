#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>
#import <QuartzCorePrivate/CAContext.h>

NS_ASSUME_NONNULL_BEGIN

/* RECALayerClientComponent */
RE_EXTERN struct REComponent * RECALayerServiceCreateRootComponent(struct RECALayerService *, CAContext *, struct REEntity *, CFDictionaryRef _Nullable);
RE_EXTERN CAContext * RECALayerServiceGetOrCreateCAContext(struct RECALayerService *);
RE_EXTERN void RECASetEnableCalculateTransformFromLayerData(struct RECALayerService *, BOOL);
RE_EXTERN void RECALayerServiceSetCAContext(struct RECALayerService *, CAContext *);

NS_ASSUME_NONNULL_END
