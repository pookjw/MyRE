#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class _UIRealityKitIntegration;
@protocol _UIRealityKitIntegrationDelegate <NSObject>
@end

@interface _UIRealityKitIntegration : NSObject
@property (weak, nonatomic) id<_UIRealityKitIntegrationDelegate> delegate;
- (id)_simulationContext;
- (BOOL)canJoinSimulation;
- (BOOL)joinSimulationIfNeeded:(id*)arg1;
- (void)performAfterSimulationWasJoined:(id)arg1;
@end

NS_ASSUME_NONNULL_END
