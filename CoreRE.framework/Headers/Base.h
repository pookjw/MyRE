#import <Foundation/Foundation.h>
#import <CoreRE/REDefines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN void RERetain(const void *);
RE_EXTERN void RERelease(const void *);
RE_EXTERN NSUInteger REGetRetainCount(const void *);

NS_ASSUME_NONNULL_END