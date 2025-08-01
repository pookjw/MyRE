#import <QuartzCore/QuartzCore.h>
#import <CoreRE/Defines.h>

NS_ASSUME_NONNULL_BEGIN

@interface CAContext : NSObject
+ (NSArray<CAContext *> *)allContexts;
+ (CAContext * _Nullable)remoteContextWithOptions:(NSDictionary<NSString *, id> * _Nullable)options;
+ (CAContext * _Nullable)localContextWithOptions:(NSDictionary<NSString *, id> * _Nullable)options;
@property (retain, nullable) CALayer *layer;
@property float level;
@property unsigned int commitPriority;
- (void)orderAbove:(unsigned int)order;
@end

NS_ASSUME_NONNULL_END
