#import "ZXResultPoint.h"
#import "ZXBitMatrix.h"
#import "ZXDetectorResult.h"

@interface ZXAztecDetectorResult : ZXDetectorResult

@property (nonatomic, readonly) int nbLayers;
@property (nonatomic, readonly) int nbDatablocks;
@property (nonatomic, readonly) BOOL compact;

- (id)initWithBits:(ZXBitMatrix *)bits
            points:(NSArray *)points
           compact:(BOOL)compact
      nbDatablocks:(int)nbDatablocks
          nbLayers:(int)nbLayers;

@end
