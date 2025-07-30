#import <UIKit/UIKit.h>
#import <CoreRE/REEntity.h>

NS_ASSUME_NONNULL_BEGIN

@class MRUIEntityPreferenceHost;
@protocol MRUIEntityPreferenceHostDelegate <NSObject>
- (MRUIEntityPreferenceHost * _Nullable)overridePreferenceHostForEntity:(struct REEntity *)entity;
@end

@interface MRUIEntityPreferenceHost : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (MRUIEntityPreferenceHost *)preferenceHostForEntity:(struct REEntity *)entity;
@property (weak, nonatomic, nullable) id<MRUIEntityPreferenceHostDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
