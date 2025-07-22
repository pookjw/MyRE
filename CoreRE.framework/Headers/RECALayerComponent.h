#import <Foundation/Foundation.h>
#import <CoreRE/REDefines.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct REComponentClass * RECALayerComponentGetComponentType(void);
RE_EXTERN struct REComponent * RECALayerGetCALayerClientComponent(CALayer *);
RE_EXTERN id RECALayerDrawInContextBlock(void);

NS_ASSUME_NONNULL_END
