#import <Foundation/Foundation.h>
#import <RealityFusion/Defines.h>

NS_ASSUME_NONNULL_BEGIN

RF_EXTERN struct RFServiceManager * RFServiceManagerCreate(void);
RF_EXTERN void RFServiceManagerSetMeshReconstructionService(struct RFServiceManager *manager, struct RFMeshReconstructionService *service);
RF_EXTERN void RFServiceManagerSetAnchorManagementService(struct RFServiceManager *manager, struct RFAnchorManagementService *service);
RF_EXTERN void RFServiceManagerSetLoggingService(struct RFServiceManager *manager, struct RFLoggingService *service);
RF_EXTERN void RFServiceManagerSetEnvironmentProbePlacementService(struct RFServiceManager *manager, struct RFEnvironmentProbePlacementService *service);
RF_EXTERN void RFServiceManagerSetAtmospherePlacementService(struct RFServiceManager *manager, struct RFAtmospherePlacementService *service);
RF_EXTERN void RFServiceManagerSetAnchorDataProvider(struct RFServiceManager *manager, struct RFAnchorDataProvider *provider);

NS_ASSUME_NONNULL_END