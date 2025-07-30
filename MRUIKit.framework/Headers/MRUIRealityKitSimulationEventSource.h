#import <UIKit/UIKit.h>
#import <CoreRE/REEntity.h>
#import <MRUIKit/MRUIEntityEvent.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MRUIRealityKitSimulationEventSourceObserver <NSObject>
- (void)didReceiveEntityEvent:(MRUIEntityEvent *)event;
@end

@interface MRUIRealityKitSimulationEventSource : NSObject
+ (MRUIRealityKitSimulationEventSource *)sharedInstance;
- (void)addObserver:(id<MRUIRealityKitSimulationEventSourceObserver>)observer forEntity:(struct REEntity *)entity;
- (void)removeObserver:(id<MRUIRealityKitSimulationEventSourceObserver>)observer forEntity:(struct REEntity *)entity;
- (void)removeObserver:(id<MRUIRealityKitSimulationEventSourceObserver>)observer;
@end

NS_ASSUME_NONNULL_END
