#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct REMaterialParameter * REMaterialParameterBlockValueCreate(void);
RE_EXTERN void REMaterialParameterBlockValueClearParameter(struct REMaterialParameter *parameter);
RE_EXTERN void REMaterialParameterBlockValueSetColor4(struct REMaterialParameter *parameter, const char *, unsigned int, struct REColorGamut4F *);
RE_EXTERN void REMaterialParameterBlockValueSetFloat(struct REMaterialParameter *parameter, const char *, float);
RE_EXTERN BOOL REMaterialParameterBlockValueGetFloat(struct REMaterialParameter *parameter, const char *, float *);

NS_ASSUME_NONNULL_END
