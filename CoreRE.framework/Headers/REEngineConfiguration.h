#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct REEngineConfiguration * REEngineConfigurationCreateFromEngine(struct REEngine *engine);
RE_EXTERN BOOL REEngineConfigurationGetEnablePreloadEngineAssets(struct REEngineConfiguration *configuration);
RE_EXTERN BOOL REEngineConfigurationIsSolariumLeanModeEnabled(struct REEngineConfiguration *configuration);
RE_EXTERN BOOL REEngineConfigurationGetEnablePreloadMXIAssets(struct REEngineConfiguration *configuration);

NS_ASSUME_NONNULL_END
