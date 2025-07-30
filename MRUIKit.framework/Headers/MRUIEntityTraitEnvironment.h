#import <UIKit/UIKit.h>
#import <CoreRE/REEntity.h>

NS_ASSUME_NONNULL_BEGIN

@class MRUIEntityTraitEnvironment;
@protocol MRUIEntityTraitDelegate <NSObject>
- (UITraitCollection * _Nullable)overrideTraitCollectionForChildEntity:(struct REEntity*)childEntity ofEntity:(struct REEntity*)entity;
- (void)traitCollectionDidChange:(UITraitCollection * _Nullable)traitCollection forEntity:(struct REEntity *)entity;
@end

@interface MRUIEntityTraitEnvironment : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (MRUIEntityTraitEnvironment *)traitEnvironmentForEntity:(struct REEntity *)entity;
@property (weak, nonatomic, nullable) id<MRUIEntityTraitDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
