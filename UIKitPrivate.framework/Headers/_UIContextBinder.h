#import <QuartzCorePrivate/CAContext.h>

NS_ASSUME_NONNULL_BEGIN

@class _UIContextBinder;

struct __attribute__((aligned(32))) UIContextBindingDescription {
    id displayIdentity;
    BOOL unknown:1;
    BOOL ignoresHitTest:1;
    BOOL shouldCreateContextAsSecure:1;
    BOOL shouldUseRemoteContext:1;
    BOOL alwaysGetsContexts:1;
    BOOL isWindowServerHostingManaged:1;
    BOOL keepContextInBackground:1;
    BOOL allowsOcclusionDetectionOverride:1;
    BOOL wantsSuperlayerSecurityAnalysis:1;
};

@protocol _UIContextBindable <NSObject>
@property (weak, nonatomic, setter=_setBoundContext:) CAContext *_boundContext;
@property (weak, nonatomic, setter=_setContextBinder:) _UIContextBinder *_contextBinder;
- (CGFloat)_bindableLevel;
- (CALayer *)_bindingLayer;
- (BOOL)_isVisible;
@end

@interface _UIContextBinder : NSObject
- (void)enrollBindable:(id<_UIContextBindable>)bindable;
- (void)attachBindable:(id<_UIContextBindable>)bindable;
- (CAContext *)_contextForBindable:(id<_UIContextBindable>)bindable;
@end

NS_ASSUME_NONNULL_END
