#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBSDisplayIdentity : NSObject <NSSecureCoding, NSCopying>
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (unsigned int)displayID;
@end

NS_ASSUME_NONNULL_END
