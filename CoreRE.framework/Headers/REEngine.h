#import <Foundation/Foundation.h>
#import <CoreRE/REDefines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct REEngine * REEngineGetShared(void);
RE_EXTERN struct REServiceLocator * REEngineGetServiceLocator(struct REEngine *engine);

NS_ASSUME_NONNULL_END
