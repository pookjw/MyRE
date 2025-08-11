#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct REEngine * REEngineGetShared(void);
RE_EXTERN struct REServiceLocator * REEngineGetServiceLocator(struct REEngine *engine);
RE_EXTERN struct REEngineOverlay * REEngineCreateOverlayForRealityRenderer(struct REEngine *engine);
RE_EXTERN struct REDrawingManager * REEngineCreateDrawingManager(struct REEngine *engine);

NS_ASSUME_NONNULL_END
