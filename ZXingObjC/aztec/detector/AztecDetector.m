#import "AztecDetector.h"
#import "AztecDetectorResult.h"
#import "GenericGF.h"
#import "GridSampler.h"
#import "NotFoundException.h"
#import "ReedSolomonDecoder.h"
#import "ReedSolomonException.h"
#import "ResultPoint.h"
#import "WhiteRectangleDetector.h"

@interface AztecPoint : NSObject

@property (nonatomic, assign) int x;
@property (nonatomic, assign) int y;

- (id)initWithX:(int) x y:(int)y;
- (ResultPoint *)toResultPoint;

@end

@implementation AztecPoint

@synthesize x, y;

- (id)initWithX:(int)anX y:(int)aY {
  if (self = [super init]) {
    x = anX;
    y = aY;
  }
  return self;
}

- (ResultPoint *)toResultPoint {
  return [[ResultPoint alloc] initWithX:x y:y];
}

@end

@interface AztecDetector ()

- (NSArray*)bullEyeCornerPoints:(AztecPoint*)pCenter;
- (int) color:(AztecPoint *)p1 p2:(AztecPoint *)p2;
- (void)correctParameterData:(NSMutableArray*)parameterData compact:(BOOL)compact;
- (float)distance:(AztecPoint*)a b:(AztecPoint*)b;
- (void)extractParameters:(NSArray*)bullEyeCornerPoints;
- (AztecPoint*)firstDifferent:(AztecPoint *)init color:(BOOL)color dx:(int)dx dy:(int)dy;
- (BOOL)isValidX:(int)x y:(int)y;
- (BOOL)isWhiteOrBlackRectangle:(AztecPoint *)p1 p2:(AztecPoint *)p2 p3:(AztecPoint *)p3 p4:(AztecPoint *)p4;
- (AztecPoint*)matrixCenter;
- (NSArray*)matrixCornerPoints:(NSArray*)bullEyeCornerPoints;
- (void)parameters:(NSMutableArray*)parameterData;
- (int)round:(float)d;
- (BitMatrix*)sampleGrid:(BitMatrix*)image
                  topLeft:(ResultPoint*)topLeft
               bottomLeft:(ResultPoint*)bottomLeft
              bottomRight:(ResultPoint*)bottomRight
                 topRight:(ResultPoint*)topRight;
- (NSArray*)sampleLine:(AztecPoint*)p1 p2:(AztecPoint*)p2 size:(int)size;

@end

@implementation AztecDetector

- (id)initWithImage:(BitMatrix*)anImage {
  if (self = [super init]) {
    image = [anImage retain];
  }
  return self;
}


/**
 * <p>Detects an Aztec Code in an image.</p>
 * 
 * @return {@link AztecDetectorResult} encapsulating results of detecting an Aztec Code
 * @throws NotFoundException if no Aztec Code can be found
 */
- (AztecDetectorResult*)detect {
  AztecPoint* pCenter = [self matrixCenter];
  NSArray * bullEyeCornerPoints = [self bullEyeCornerPoints:pCenter];
  [self extractParameters:bullEyeCornerPoints];
  NSArray * corners = [self matrixCornerPoints:bullEyeCornerPoints];
  BitMatrix *bits = [self sampleGrid:image
                             topLeft:[corners objectAtIndex:shift % 4]
                          bottomLeft:[corners objectAtIndex:(shift + 3) % 4]
                         bottomRight:[corners objectAtIndex:(shift + 2) % 4]
                            topRight:[corners objectAtIndex:(shift + 1) % 4]];
  return [[[AztecDetectorResult alloc] initWithBits:bits
                                             points:corners
                                            compact:compact
                                       nbDatablocks:nbDataBlocks
                                           nbLayers:nbLayers] autorelease];
}


/**
 * <p> Extracts the number of data layers and data blocks from the layer around the bull's eye </p>
 * 
 * @param bullEyeCornerPoints the array of bull's eye corners
 * @throws NotFoundException in case of too many errors or invalid parameters
 */
- (void)extractParameters:(NSArray*)bullEyeCornerPoints {
  AztecPoint *p0 = [bullEyeCornerPoints objectAtIndex:0];
  AztecPoint *p1 = [bullEyeCornerPoints objectAtIndex:1];
  AztecPoint *p2 = [bullEyeCornerPoints objectAtIndex:2];
  AztecPoint *p3 = [bullEyeCornerPoints objectAtIndex:3];

  NSArray *resab = [self sampleLine:p0 p2:p1 size:2 * nbCenterLayers + 1];
  NSArray *resbc = [self sampleLine:p1 p2:p2 size:2 * nbCenterLayers + 1];
  NSArray *rescd = [self sampleLine:p2 p2:p3 size:2 * nbCenterLayers + 1];
  NSArray *resda = [self sampleLine:p3 p2:p0 size:2 * nbCenterLayers + 1];

  if ([resab objectAtIndex:0] && [resab objectAtIndex:2 * nbCenterLayers]) {
    shift = 0;
  } else if ([resbc objectAtIndex:0] && [resbc objectAtIndex:2 * nbCenterLayers]) {
    shift = 1;
  } else if ([rescd objectAtIndex:0] && [rescd objectAtIndex:2 * nbCenterLayers]) {
    shift = 2;
  } else if ([resda objectAtIndex:0] && [resda objectAtIndex:2 * nbCenterLayers]) {
    shift = 3;
  } else {
    @throw [NotFoundException notFoundInstance];
  }

  NSMutableArray *parameterData = [NSMutableArray array];
  NSMutableArray *shiftedParameterData = [NSMutableArray array];
  if (compact) {
    for (int i = 0; i < 28; i++) {
      [shiftedParameterData addObject:[NSNull null]];
    }

    for (int i = 0; i < 7; i++) {
      [shiftedParameterData replaceObjectAtIndex:i withObject:[resab objectAtIndex:2+i]];
      [shiftedParameterData replaceObjectAtIndex:i + 7 withObject:[resbc objectAtIndex:2+i]];
      [shiftedParameterData replaceObjectAtIndex:i + 14 withObject:[rescd objectAtIndex:2+i]];
      [shiftedParameterData replaceObjectAtIndex:i + 21 withObject:[resda objectAtIndex:2+i]];
    }

    for (int i = 0; i < 28; i++) {
      [parameterData addObject:[shiftedParameterData objectAtIndex:(i + shift * 7) % 28]];
    }
  } else {
    for (int i = 0; i < 40; i++) {
      [shiftedParameterData addObject:[NSNull null]];
    }

    for (int i = 0; i < 11; i++) {
      if (i < 5) {
        [shiftedParameterData replaceObjectAtIndex:i withObject:[resab objectAtIndex:2 + i]];
        [shiftedParameterData replaceObjectAtIndex:i + 10 withObject:[resbc objectAtIndex:2 + i]];
        [shiftedParameterData replaceObjectAtIndex:i + 20 withObject:[rescd objectAtIndex:2 + i]];
        [shiftedParameterData replaceObjectAtIndex:i + 30 withObject:[resda objectAtIndex:2 + i]];
      }
      if (i > 5) {
        [shiftedParameterData replaceObjectAtIndex:i - 1 withObject:[resab objectAtIndex:2 + i]];
        [shiftedParameterData replaceObjectAtIndex:i + 10 - 1 withObject:[resbc objectAtIndex:2 + i]];
        [shiftedParameterData replaceObjectAtIndex:i + 20 - 1 withObject:[rescd objectAtIndex:2 + i]];
        [shiftedParameterData replaceObjectAtIndex:i + 30 - 1 withObject:[resda objectAtIndex:2 + i]];
      }
    }

    for (int i = 0; i < 40; i++) {
      [parameterData addObject:[shiftedParameterData objectAtIndex:(i + shift * 10) % 40]];
    }

  }
  [self correctParameterData:parameterData compact:compact];
  [self parameters:parameterData];
}


/**
 * 
 * <p>Gets the Aztec code corners from the bull's eye corners and the parameters </p>
 * 
 * @param bullEyeCornerPoints the array of bull's eye corners
 * @return the array of aztec code corners
 * @throws NotFoundException if the corner points do not fit in the image
 */
- (NSArray*)matrixCornerPoints:(NSArray*)bullEyeCornerPoints {
  AztecPoint *p0 = [bullEyeCornerPoints objectAtIndex:0];
  AztecPoint *p1 = [bullEyeCornerPoints objectAtIndex:1];
  AztecPoint *p2 = [bullEyeCornerPoints objectAtIndex:2];
  AztecPoint *p3 = [bullEyeCornerPoints objectAtIndex:3];
  
  float ratio = (2 * nbLayers + (nbLayers > 4 ? 1 : 0) + (nbLayers - 4) / 8) / (2.0f * nbCenterLayers);
  int dx = p0.x - p2.x;
  dx += dx > 0 ? 1 : -1;
  int dy = p0.y - p2.y;
  dy += dy > 0 ? 1 : -1;
  int targetcx = [self round:p2.x - ratio * dx];
  int targetcy = [self round:p2.y - ratio * dy];
  int targetax = [self round:p0.x + ratio * dx];
  int targetay = [self round:p0.y + ratio * dy];
  dx = p1.x - p3.x;
  dx += dx > 0 ? 1 : -1;
  dy = p1.y - p3.y;
  dy += dy > 0 ? 1 : -1;
  int targetdx = [self round:p3.x - ratio * dx];
  int targetdy = [self round:p3.y - ratio * dy];
  int targetbx = [self round:p1.x + ratio * dx];
  int targetby = [self round:p1.y + ratio * dy];
  if (![self isValidX:targetax y:targetay] ||
      ![self isValidX:targetbx y:targetby] ||
      ![self isValidX:targetcx y:targetcy] ||
      ![self isValidX:targetdx y:targetdy]) {
    @throw [NotFoundException notFoundInstance];
  }
  return [NSArray arrayWithObjects:[[[ResultPoint alloc] initWithX:targetax y:targetay] autorelease],
          [[[ResultPoint alloc] initWithX:targetbx y:targetby] autorelease],
          [[[ResultPoint alloc] initWithX:targetcx y:targetcy] autorelease],
          [[[ResultPoint alloc] initWithX:targetdx y:targetdy] autorelease], nil];
}


/**
 * 
 * <p> Corrects the parameter bits using Reed-Solomon algorithm </p>
 * 
 * @param parameterData paremeter bits
 * @param compact true if this is a compact Aztec code
 * @throws NotFoundException if the array contains too many errors
 */
- (void)correctParameterData:(NSMutableArray *)parameterData compact:(BOOL)isCompact {
  int numCodewords;
  int numDataCodewords;
  if (isCompact) {
    numCodewords = 7;
    numDataCodewords = 2;
  }
   else {
    numCodewords = 10;
    numDataCodewords = 4;
  }
  int numECCodewords = numCodewords - numDataCodewords;
  NSMutableArray *parameterWords = [NSMutableArray array];
  for (int i = 0; i < numCodewords; i++) {
    [parameterWords addObject:[NSNumber numberWithInt:0]];
  }
  
  int codewordSize = 4;

  for (int i = 0; i < numCodewords; i++) {
    int flag = 1;

    for (int j = 1; j <= codewordSize; j++) {
      if ([[parameterData objectAtIndex:codewordSize * i + codewordSize - j] boolValue]) {
        [parameterWords replaceObjectAtIndex:i withObject:
         [NSNumber numberWithInt:[[parameterWords objectAtIndex:i] intValue] + flag]];
      }
      flag <<= 1;
    }
  }

  @try {
    ReedSolomonDecoder *rsDecoder = [[[ReedSolomonDecoder alloc] initWithField:[GenericGF AztecDataParam]] autorelease];
    [rsDecoder decode:parameterWords twoS:numECCodewords];
  }
  @catch (ReedSolomonException * rse) {
    @throw [NotFoundException notFoundInstance];
  }

  for (int i = 0; i < numDataCodewords; i++) {
    int flag = 1;

    for (int j = 1; j <= codewordSize; j++) {
      [parameterData replaceObjectAtIndex:i * codewordSize + codewordSize - j
                               withObject:[NSNumber numberWithBool:
                                           ([[parameterWords objectAtIndex:i] intValue] & flag) == flag]];
      flag <<= 1;
    }
  }
}


/**
 * 
 * <p> Finds the corners of a bull-eye centered on the passed point </p>
 * 
 * @param pCenter Center point
 * @return The corners of the bull-eye
 * @throws NotFoundException If no valid bull-eye can be found
 */
- (NSArray*)bullEyeCornerPoints:(AztecPoint*)pCenter {
  AztecPoint *pina = pCenter;
  AztecPoint *pinb = pCenter;
  AztecPoint *pinc = pCenter;
  AztecPoint *pind = pCenter;
  BOOL color = YES;

  for (nbCenterLayers = 1; nbCenterLayers < 9; nbCenterLayers++) {
    AztecPoint *pouta = [self firstDifferent:pina color:color dx:1 dy:-1];
    AztecPoint *poutb = [self firstDifferent:pinb color:color dx:1 dy:1];
    AztecPoint *poutc = [self firstDifferent:pinc color:color dx:-1 dy:1];
    AztecPoint *poutd = [self firstDifferent:pind color:color dx:-1 dy:-1];
    if (nbCenterLayers > 2) {
      float q = [self distance:poutd b:pouta] * nbCenterLayers / ([self distance:pind b:pina] * (nbCenterLayers + 2));
      if (q < 0.75 || q > 1.25 || ![self isWhiteOrBlackRectangle:pouta p2:poutb p3:poutc p4:poutd]) {
        break;
      }
    }
    pina = pouta;
    pinb = poutb;
    pinc = poutc;
    pind = poutd;
    color = !color;
  }

  if (nbCenterLayers != 5 && nbCenterLayers != 7) {
    @throw [NotFoundException notFoundInstance];
  }
  compact = nbCenterLayers == 5;
  float ratio = 0.75f * 2 / (2 * nbCenterLayers - 3);
  int dx = pina.x - pinc.x;
  int dy = pina.y - pinc.y;
  int targetcx = [self round:pinc.x - ratio * dx];
  int targetcy = [self round:pinc.y - ratio * dy];
  int targetax = [self round:pina.x + ratio * dx];
  int targetay = [self round:pina.y + ratio * dy];
  dx = pinb.x - pind.x;
  dy = pinb.y - pind.y;
  int targetdx = [self round:pind.x - ratio * dx];
  int targetdy = [self round:pind.y - ratio * dy];
  int targetbx = [self round:pinb.x + ratio * dx];
  int targetby = [self round:pinb.y + ratio * dy];
  if (![self isValidX:targetax y:targetay] ||
      ![self isValidX:targetbx y:targetby] ||
      ![self isValidX:targetcx y:targetcy] ||
      ![self isValidX:targetdx y:targetdy]) {
    @throw [NotFoundException notFoundInstance];
  }
  AztecPoint * pa = [[[AztecPoint alloc] initWithX:targetax y:targetay] autorelease];
  AztecPoint * pb = [[[AztecPoint alloc] initWithX:targetbx y:targetby] autorelease];
  AztecPoint * pc = [[[AztecPoint alloc] initWithX:targetcx y:targetcy] autorelease];
  AztecPoint * pd = [[[AztecPoint alloc] initWithX:targetdx y:targetdy] autorelease];
  return [NSArray arrayWithObjects:pa, pb, pc, pd, nil];
}


/**
 * 
 * Finds a candidate center point of an Aztec code from an image
 * 
 * @return the center point
 */
- (AztecPoint *)matrixCenter {
  ResultPoint *pointA;
  ResultPoint *pointB;
  ResultPoint *pointC;
  ResultPoint *pointD;

  @try {
    NSArray * cornerPoints = [[[[WhiteRectangleDetector alloc] initWithImage:image] autorelease] detect];
    pointA = [cornerPoints objectAtIndex:0];
    pointB = [cornerPoints objectAtIndex:1];
    pointC = [cornerPoints objectAtIndex:2];
    pointD = [cornerPoints objectAtIndex:3];
  }
  @catch (NotFoundException * e) {
    int cx = image.width / 2;
    int cy = image.height / 2;
    pointA = [[self firstDifferent:[[[AztecPoint alloc] initWithX:cx + 15 / 2 y:cy - 15 / 2] autorelease] color:NO dx:1 dy:-1] toResultPoint];
    pointB = [[self firstDifferent:[[[AztecPoint alloc] initWithX:cx + 15 / 2 y:cy + 15 / 2] autorelease] color:NO dx:1 dy:1] toResultPoint];
    pointC = [[self firstDifferent:[[[AztecPoint alloc] initWithX:cx - 15 / 2 y:cy + 15 / 2] autorelease] color:NO dx:-1 dy:1] toResultPoint];
    pointD = [[self firstDifferent:[[[AztecPoint alloc] initWithX:cx - 15 / 2 y:cy - 15 / 2] autorelease] color:NO dx:-1 dy:-1] toResultPoint];
  }
  int cx = [self round:([pointA x] + [pointD x] + [pointB x] + [pointC x]) / 4];
  int cy = [self round:([pointA y] + [pointD y] + [pointB y] + [pointC y]) / 4];

  @try {
    NSArray * cornerPoints = [[[[WhiteRectangleDetector alloc] initWithImage:image initSize:15 x:cx y:cy] autorelease] detect];
    pointA = [cornerPoints objectAtIndex:0];
    pointB = [cornerPoints objectAtIndex:1];
    pointC = [cornerPoints objectAtIndex:2];
    pointD = [cornerPoints objectAtIndex:3];
  }
  @catch (NotFoundException * e) {
    pointA = [[self firstDifferent:[[[AztecPoint alloc] initWithX:cx + 15 / 2 y:cy - 15 / 2] autorelease] color:NO dx:1 dy:-1] toResultPoint];
    pointB = [[self firstDifferent:[[[AztecPoint alloc] initWithX:cx + 15 / 2 y:cy + 15 / 2] autorelease] color:NO dx:1 dy:1] toResultPoint];
    pointC = [[self firstDifferent:[[[AztecPoint alloc] initWithX:cx - 15 / 2 y:cy + 15 / 2] autorelease] color:NO dx:-1 dy:1] toResultPoint];
    pointD = [[self firstDifferent:[[[AztecPoint alloc] initWithX:cx - 15 / 2 y:cy - 15 / 2] autorelease] color:NO dx:-1 dy:-1] toResultPoint];
  }
  cx = [self round:([pointA x] + [pointD x] + [pointB x] + [pointC x]) / 4];
  cy = [self round:([pointA y] + [pointD y] + [pointB y] + [pointC y]) / 4];
  return [[[AztecPoint alloc] initWithX:cx y:cy] autorelease];
}


/**
 * Samples an Aztec matrix from an image
 */
- (BitMatrix *) sampleGrid:(BitMatrix *)anImage topLeft:(ResultPoint *)topLeft bottomLeft:(ResultPoint *)bottomLeft bottomRight:(ResultPoint *)bottomRight topRight:(ResultPoint *)topRight {
  int dimension;
  if (compact) {
    dimension = 4 * nbLayers + 11;
  }
   else {
    if (nbLayers <= 4) {
      dimension = 4 * nbLayers + 15;
    }
     else {
      dimension = 4 * nbLayers + 2 * ((nbLayers - 4) / 8 + 1) + 15;
    }
  }
  GridSampler * sampler = [GridSampler instance];

  return [sampler sampleGrid:anImage
                  dimensionX:dimension
                  dimensionY:dimension
                       p1ToX:0.5f
                       p1ToY:0.5f
                       p2ToX:dimension - 0.5f
                       p2ToY:0.5f
                       p3ToX:dimension - 0.5f
                       p3ToY:dimension - 0.5f
                       p4ToX:0.5f
                       p4ToY:dimension - 0.5f
                     p1FromX:[topLeft x]
                     p1FromY:[topLeft y]
                     p2FromX:[topRight x]
                     p2FromY:[topRight y]
                     p3FromX:[bottomRight x]
                     p3FromY:[bottomRight y]
                     p4FromX:[bottomLeft x]
                     p4FromY:[bottomLeft y]];
}


/**
 * Sets number of layers and number of datablocks from parameter bits
 */
- (void) parameters:(NSArray *)parameterData {
  int nbBitsForNbLayers;
  int nbBitsForNbDatablocks;
  if (compact) {
    nbBitsForNbLayers = 2;
    nbBitsForNbDatablocks = 6;
  }
   else {
    nbBitsForNbLayers = 5;
    nbBitsForNbDatablocks = 11;
  }

  for (int i = 0; i < nbBitsForNbLayers; i++) {
    nbLayers <<= 1;
    if ([[parameterData objectAtIndex:i] boolValue]) {
      nbLayers += 1;
    }
  }


  for (int i = nbBitsForNbLayers; i < nbBitsForNbLayers + nbBitsForNbDatablocks; i++) {
    nbDataBlocks <<= 1;
    if ([[parameterData objectAtIndex:i] boolValue]) {
      nbDataBlocks += 1;
    }
  }

  nbLayers++;
  nbDataBlocks++;
}


/**
 * 
 * Samples a line
 * 
 * @param p1 first point
 * @param p2 second point
 * @param size number of bits
 * @return the array of bits
 */
- (NSArray *) sampleLine:(AztecPoint *)p1 p2:(AztecPoint *)p2 size:(int)size {
  NSMutableArray * res = [NSMutableArray arrayWithCapacity:size];
  float d = [self distance:p1 b:p2];
  float moduleSize = d / (size - 1);
  float dx = moduleSize * (p2.x - p1.x) / d;
  float dy = moduleSize * (p2.y - p1.y) / d;
  float px = p1.x;
  float py = p1.y;

  for (int i = 0; i < size; i++) {
    [res addObject:[NSNumber numberWithBool:[image get:[self round:px] y:[self round:py]]]];
    px += dx;
    py += dy;
  }

  return res;
}


/**
 * @return true if the border of the rectangle passed in parameter is compound of white points only
 * or black points only
 */
- (BOOL)isWhiteOrBlackRectangle:(AztecPoint *)p1 p2:(AztecPoint *)p2 p3:(AztecPoint *)p3 p4:(AztecPoint *)p4 {
  int corr = 3;
  p1 = [[[AztecPoint alloc] initWithX:p1.x - corr y:p1.y + corr] autorelease];
  p2 = [[[AztecPoint alloc] initWithX:p2.x - corr y:p2.y - corr] autorelease];
  p3 = [[[AztecPoint alloc] initWithX:p3.x + corr y:p3.y - corr] autorelease];
  p4 = [[[AztecPoint alloc] initWithX:p4.x + corr y:p4.y + corr] autorelease];
  int cInit = [self color:p4 p2:p1];
  if (cInit == 0) {
    return NO;
  }
  int c = [self color:p1 p2:p2];
  if (c != cInit || c == 0) {
    return NO;
  }
  c = [self color:p2 p2:p3];
  if (c != cInit || c == 0) {
    return NO;
  }
  c = [self color:p3 p2:p4];
  return c == cInit && c != 0;
}


/**
 * Gets the color of a segment
 * 
 * @return 1 if segment more than 90% black, -1 if segment is more than 90% white, 0 else
 */
- (int) color:(AztecPoint *)p1 p2:(AztecPoint *)p2 {
  float d = [self distance:p1 b:p2];
  float dx = (p2.x - p1.x) / d;
  float dy = (p2.y - p1.y) / d;
  int error = 0;
  float px = p1.x;
  float py = p1.y;
  BOOL colorModel = [image get:p1.x y:p1.y];

  for (int i = 0; i < d; i++) {
    px += dx;
    py += dy;
    if ([image get:[self round:px] y:[self round:py]] != colorModel) {
      error++;
    }
  }

  float errRatio = (float)error / d;
  if (errRatio > 0.1 && errRatio < 0.9) {
    return 0;
  }
  if (errRatio <= 0.1) {
    return colorModel ? 1 : -1;
  }
   else {
    return colorModel ? -1 : 1;
  }
}


/**
 * Gets the coordinate of the first point with a different color in the given direction
 */
- (AztecPoint *) firstDifferent:(AztecPoint *)init color:(BOOL)color dx:(int)dx dy:(int)dy {
  int x = init.x + dx;
  int y = init.y + dy;

  while ([self isValidX:x y:y] && [image get:x y:y] == color) {
    x += dx;
    y += dy;
  }

  x -= dx;
  y -= dy;

  while ([self isValidX:x y:y] && [image get:x y:y] == color) {
    x += dx;
  }

  x -= dx;

  while ([self isValidX:x y:y] && [image get:x y:y] == color) {
    y += dy;
  }

  y -= dy;
  return [[[AztecPoint alloc] initWithX:x y:y] autorelease];
}

- (BOOL) isValidX:(int)x y:(int)y {
  return x >= 0 && x < image.width && y > 0 && y < image.height;
}


/**
 * Ends up being a bit faster than Math.round(). This merely rounds its
 * argument to the nearest int, where x.5 rounds up.
 */
- (int) round:(float)d {
  return (int)(d + 0.5f);
}

- (float) distance:(AztecPoint *)a b:(AztecPoint *)b {
  return (float)sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y));
}

- (void) dealloc {
  [image release];
  [super dealloc];
}

@end
