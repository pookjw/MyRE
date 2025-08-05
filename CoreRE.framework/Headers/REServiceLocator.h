#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>
#import <DirectResource/Defines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct REAssetManager * REServiceLocatorGetAssetManager(struct REServiceLocator *serviceLocator);
RE_EXTERN struct DRContext * REServiceLocatorGetDirectResourceService(struct REServiceLocator *serviceLocator);

NS_ASSUME_NONNULL_END