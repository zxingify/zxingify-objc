#import "ResultPoint.h"
#import "BitMatrix.h"
#import "DetectorResult.h"

@interface AztecDetectorResult : DetectorResult {
  BOOL compact;
  int nbDatablocks;
  int nbLayers;
}

@property(nonatomic, readonly) int nbLayers;
@property(nonatomic, readonly) int nbDatablocks;
@property(nonatomic, readonly) BOOL compact;
- (id) init:(BitMatrix *)bits points:(NSArray *)points compact:(BOOL)compact nbDatablocks:(int)nbDatablocks nbLayers:(int)nbLayers;
@end
