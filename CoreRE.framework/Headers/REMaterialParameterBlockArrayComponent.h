#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct REComponentClass * REMaterialParameterBlockArrayComponentGetComponentType(void);
RE_EXTERN void REMaterialParameterBlockArrayComponentSetBlockValueAtIndex(struct REComponent *component, NSInteger index, struct REMaterialParameter *parameter);

NS_ASSUME_NONNULL_END
