#import <UIKit/UIKit.h>
#import <CoreRE/Defines.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Private)
@property (nonatomic, setter=_setClipsToREBounds:) BOOL _clipsToREBounds;
@property (readonly) long _currentSeparatedState;
@property (readonly, nonatomic) BOOL _supportsEntityHitTesting;
- (void)_requestSeparatedState:(NSInteger)state withReason:(NSString *)reason;
- (struct REEntity * _Nullable)_reEntity;
+ (BOOL)_supportsSeparationForIdiom:(UIUserInterfaceIdiom)idiom;
- (NSMutableArray<NSString *> *)_separatedStateTrackedRequestReasons;
- (NSMutableArray<NSString *> *)_separatedStateSeparatedRequestReasons;
- (id _Nullable)_separatedValueForKey:(NSString *)key;
- (void)_setSeparatedValue:(id _Nullable)separatedValue forKey:(NSString *)key;
+ (void)_setSeparatedViewForServerID:(UIView *)view serverID:(unsigned int)serverID;
@property (class, readonly) CGFloat _defaultThickness;
@property (nonatomic, setter=_setThickness:) CGFloat _thickness;
- (void)_didChangePreferredContentDepth;
@end

NS_ASSUME_NONNULL_END
