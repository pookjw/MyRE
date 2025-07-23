#import <QuartzCore/QuartzCore.h>
#import <CoreRE/Defines.h>

NS_ASSUME_NONNULL_BEGIN

@interface CAContext : NSObject
@property (retain, nullable) CALayer *layer;
@property float level;
@property unsigned int commitPriority;
@end

NS_ASSUME_NONNULL_END
