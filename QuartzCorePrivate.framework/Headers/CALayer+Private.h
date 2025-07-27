#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

CA_EXTERN unsigned long long const CAInvalidRenderId;

@interface CALayer (Private)
@property (copy) NSNumber *UICALayerRenderID;
@property (copy) NSDictionary *separatedOptions;
@property unsigned int separatedState;
@end

NS_ASSUME_NONNULL_END
