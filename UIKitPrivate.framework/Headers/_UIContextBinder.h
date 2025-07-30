#import <QuartzCorePrivate/CAContext.h>
#import <FrontBoardServices/FBSDisplayIdentity.h>

NS_ASSUME_NONNULL_BEGIN

struct __attribute__((aligned(32))) UIContextBindingDescription {
    FBSDisplayIdentity *displayIdentity;
    BOOL unknown;
    BOOL ignoresHitTest;
    BOOL shouldCreateContextAsSecure;
    BOOL shouldUseRemoteContext;
    BOOL alwaysGetsContexts;
    BOOL isWindowServerHostingManaged;
    BOOL keepContextInBackground;
    BOOL allowsOcclusionDetectionOverride;
    BOOL wantsSuperlayerSecurityAnalysis;
};

@class _UIContextBinder;

@protocol _UIContextBindable <NSObject>
@property (weak, nonatomic, setter=_setBoundContext:) CAContext *_boundContext;
@property (weak, nonatomic, setter=_setContextBinder:) _UIContextBinder *_contextBinder;
- (CGFloat)_bindableLevel;
- (CALayer * _Nullable)_bindingLayer;
- (BOOL)_isVisible;
@end

@protocol _UIContextBinding <NSObject>
- (void)attachContext:(CAContext *)context;
- (void)detachContext:(CAContext *)context;
@end

@interface _UIContextBinder : NSObject
@property (readonly, nonatomic) id<_UIContextBinding> substrate;
- (void)enrollBindable:(id<_UIContextBindable>)bindable;
- (void)attachBindable:(id<_UIContextBindable>)bindable;
- (CAContext *)_contextForBindable:(id<_UIContextBindable>)bindable;
+ (CAContext *)createContextForBindable:(id<_UIContextBindable>)bindable withSubstrate:(id<_UIContextBinding>)substrate;
@end

NS_ASSUME_NONNULL_END
