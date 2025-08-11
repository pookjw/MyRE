#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN void REEngineOverlayEnterFrame(struct REEngineOverlay *engineOverlay, float deltaTime);
RE_EXTERN BOOL REEngineOverlayIsEngineInsideTick(struct REEngineOverlay *engineOverlay);
RE_EXTERN void REEngineOverlaySetRealityRendererSceneGroup(struct REEngineOverlay *engineOverlay, struct RERealityRendererSceneGroup *sceneGroup);
RE_EXTERN void REEngineOverlayFramePrepare(struct REEngineOverlay *engineOverlay);
RE_EXTERN void REEngineOverlayFrameSimulate(struct REEngineOverlay *engineOverlay);
RE_EXTERN void REEngineOverlayFrameCommit(struct REEngineOverlay *engineOverlay);
RE_EXTERN void REEngineOverlayFrameExit(struct REEngineOverlay *engineOverlay);

NS_ASSUME_NONNULL_END
