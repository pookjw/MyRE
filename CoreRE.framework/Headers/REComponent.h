#import <Foundation/Foundation.h>
#import <CoreRE/REDefines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct REComponent * REComponentCreateByClass(struct REComponentClass *componentClass);
RE_EXTERN const char * REComponentClassGetName(struct REComponentClass *componentClass);
RE_EXTERN struct REComponent * REComponentCopy(struct REComponent *);
RE_EXTERN struct REComponentClass * REComponentGetClass(struct REComponent *);

NS_ASSUME_NONNULL_END