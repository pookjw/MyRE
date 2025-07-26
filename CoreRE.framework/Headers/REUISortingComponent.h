#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct REComponentClass * REUISortingComponentGetComponentType(void);
RE_EXTERN void REUISortingComponentSetSortCategory(struct REComponent *component, BOOL);
RE_EXTERN void REUISortingComponentSetExtents(struct REComponent *component, CGRect);

NS_ASSUME_NONNULL_END
