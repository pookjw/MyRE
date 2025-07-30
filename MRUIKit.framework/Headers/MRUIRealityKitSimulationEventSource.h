#import <UIKit/UIKit.h>
#import <CoreRE/REEntity.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MRUIRealityKitSimulationEventSourceObserver <NSObject>
- (void)didReceiveEntityEvent:(id)event;
@end

@interface MRUIRealityKitSimulationEventSource : NSObject
+ (MRUIRealityKitSimulationEventSource *)sharedInstance;
@end

NS_ASSUME_NONNULL_END
