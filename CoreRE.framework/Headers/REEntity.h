#import <Foundation/Foundation.h>
#import <CoreRE/REDefines.h>
#import <CoreRE/REComponent.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN NSString * REEntityGetDebugDescription(struct REEntity *entity);
RE_EXTERN NSString * REEntityGetDebugDescriptionRecursive(struct REEntity *entity);
RE_EXTERN struct REEntity * REEntityCreate(void);
RE_EXTERN void REEntityInsertChild(struct REEntity *parent, struct REEntity *child, unsigned long index);
RE_EXTERN void REEntitySetName(struct REEntity *entity, const char *name);
RE_EXTERN const char * REEntityGetName(struct REEntity *entity);
RE_EXTERN struct REEntity * _Nullable REEntityFindInHierarchyByName(struct REEntity *entity, const char *name);
RE_EXTERN struct REComponent * _Nullable REEntityGetComponentByClass(struct REEntity *entity, struct REComponentClass *componentClass);
RE_EXTERN struct REComponent * REEntityAddComponentByClass(struct REEntity *entity, struct REComponentClass *componentClass);
RE_EXTERN void REEntityAddExistingComponent(struct REEntity *entity, struct REComponent *component);
RE_EXTERN struct REComponent * _Nullable REEntityGetOrAddComponentByClass(struct REEntity *entity, struct REComponentClass *componentClass);
RE_EXTERN void REEntityRemoveComponentByClass(struct REEntity *entity, struct REComponentClass *componentClass);
RE_EXTERN bool REEntityIsAnchored(struct REEntity *entity);
RE_EXTERN struct REEntity * _Nullable REEntityGetParent(struct REEntity *);
RE_EXTERN struct REEntity * REEntityCopy(struct REEntity *);
RE_EXTERN void REEntityRemoveAllComponents(struct REEntity *);
RE_EXTERN NSUInteger REEntityGetComponentCount(struct REEntity *);
RE_EXTERN struct REComponent * REEntityGetComponentAtIndex(struct REEntity *, NSInteger);
RE_EXTERN unsigned long REEntityGetChildren(struct REEntity *entity, struct REEntity * _Nonnull * _Nonnull children, unsigned long allocatedCount);

NS_ASSUME_NONNULL_END
