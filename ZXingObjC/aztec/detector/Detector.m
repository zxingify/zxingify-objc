#import "Detector.h"

@implementation Point

- (ResultPoint *) toResultPoint {
  return [[[ResultPoint alloc] init:x y:y] autorelease];
}

- (id) init:(int)x y:(int)y {
  if (self = [super init]) {
    x = x;
    y = y;
  }
  return self;
}

@end

@implementation Detector

- (id) initWithImage:(BitMatrix *)image {
  if (self = [super init]) {
    image = image;
  }
  return self;
}


/**
 * <p>Detects an Aztec Code in an image.</p>
 * 
 * @return {@link AztecDetectorResult} encapsulating results of detecting an Aztec Code
 * @throws NotFoundException if no Aztec Code can be found
 */
- (AztecDetectorResult *) detect {
  Point * pCenter = [self matrixCenter];
  NSArray * bullEyeCornerPoints = [self getBullEyeCornerPoints:pCenter];
  [self extractParameters:bullEyeCornerPoints];
  NSArray * corners = [self getMatrixCornerPoints:bullEyeCornerPoints];
  BitMatrix * bits = [self sampleGrid:image topLeft:corners[shift % 4] bottomLeft:corners[(shift + 3) % 4] bottomRight:corners[(shift + 2) % 4] topRight:corners[(shift + 1) % 4]];
  return [[[AztecDetectorResult alloc] init:bits param1:corners param2:compact param3:nbDataBlocks param4:nbLayers] autorelease];
}


/**
 * <p> Extracts the number of data layers and data blocks from the layer around the bull's eye </p>
 * 
 * @param bullEyeCornerPoints the array of bull's eye corners
 * @throws NotFoundException in case of too many errors or invalid parameters
 */
- (void) extractParameters:(NSArray *)bullEyeCornerPoints {
  NSArray * resab = [self sampleLine:bullEyeCornerPoints[0] p2:bullEyeCornerPoints[1] size:2 * nbCenterLayers + 1];
  NSArray * resbc = [self sampleLine:bullEyeCornerPoints[1] p2:bullEyeCornerPoints[2] size:2 * nbCenterLayers + 1];
  NSArray * rescd = [self sampleLine:bullEyeCornerPoints[2] p2:bullEyeCornerPoints[3] size:2 * nbCenterLayers + 1];
  NSArray * resda = [self sampleLine:bullEyeCornerPoints[3] p2:bullEyeCornerPoints[0] size:2 * nbCenterLayers + 1];
  if (resab[0] && resab[2 * nbCenterLayers]) {
    shift = 0;
  }
   else if (resbc[0] && resbc[2 * nbCenterLayers]) {
    shift = 1;
  }
   else if (rescd[0] && rescd[2 * nbCenterLayers]) {
    shift = 2;
  }
   else if (resda[0] && resda[2 * nbCenterLayers]) {
    shift = 3;
  }
   else {
    @throw [NotFoundException notFoundInstance];
  }
  NSArray * parameterData;
  NSArray * shiftedParameterData;
  if (compact) {
    shiftedParameterData = [NSArray array];

    for (int i = 0; i < 7; i++) {
      shiftedParameterData[i] = resab[2 + i];
      shiftedParameterData[i + 7] = resbc[2 + i];
      shiftedParameterData[i + 14] = rescd[2 + i];
      shiftedParameterData[i + 21] = resda[2 + i];
    }

    parameterData = [NSArray array];

    for (int i = 0; i < 28; i++) {
      parameterData[i] = shiftedParameterData[(i + shift * 7) % 28];
    }

  }
   else {
    shiftedParameterData = [NSArray array];

    for (int i = 0; i < 11; i++) {
      if (i < 5) {
        shiftedParameterData[i] = resab[2 + i];
        shiftedParameterData[i + 10] = resbc[2 + i];
        shiftedParameterData[i + 20] = rescd[2 + i];
        shiftedParameterData[i + 30] = resda[2 + i];
      }
      if (i > 5) {
        shiftedParameterData[i - 1] = resab[2 + i];
        shiftedParameterData[i + 10 - 1] = resbc[2 + i];
        shiftedParameterData[i + 20 - 1] = rescd[2 + i];
        shiftedParameterData[i + 30 - 1] = resda[2 + i];
      }
    }

    parameterData = [NSArray array];

    for (int i = 0; i < 40; i++) {
      parameterData[i] = shiftedParameterData[(i + shift * 10) % 40];
    }

  }
  [self correctParameterData:parameterData compact:compact];
  [self getParameters:parameterData];
}


/**
 * 
 * <p>Gets the Aztec code corners from the bull's eye corners and the parameters </p>
 * 
 * @param bullEyeCornerPoints the array of bull's eye corners
 * @return the array of aztec code corners
 * @throws NotFoundException if the corner points do not fit in the image
 */
- (NSArray *) getMatrixCornerPoints:(NSArray *)bullEyeCornerPoints {
  float ratio = (2 * nbLayers + (nbLayers > 4 ? 1 : 0) + (nbLayers - 4) / 8) / (2.0f * nbCenterLayers);
  int dx = bullEyeCornerPoints[0].x - bullEyeCornerPoints[2].x;
  dx += dx > 0 ? 1 : -1;
  int dy = bullEyeCornerPoints[0].y - bullEyeCornerPoints[2].y;
  dy += dy > 0 ? 1 : -1;
  int targetcx = [self round:bullEyeCornerPoints[2].x - ratio * dx];
  int targetcy = [self round:bullEyeCornerPoints[2].y - ratio * dy];
  int targetax = [self round:bullEyeCornerPoints[0].x + ratio * dx];
  int targetay = [self round:bullEyeCornerPoints[0].y + ratio * dy];
  dx = bullEyeCornerPoints[1].x - bullEyeCornerPoints[3].x;
  dx += dx > 0 ? 1 : -1;
  dy = bullEyeCornerPoints[1].y - bullEyeCornerPoints[3].y;
  dy += dy > 0 ? 1 : -1;
  int targetdx = [self round:bullEyeCornerPoints[3].x - ratio * dx];
  int targetdy = [self round:bullEyeCornerPoints[3].y - ratio * dy];
  int targetbx = [self round:bullEyeCornerPoints[1].x + ratio * dx];
  int targetby = [self round:bullEyeCornerPoints[1].y + ratio * dy];
  if (![self isValid:targetax y:targetay] || ![self isValid:targetbx y:targetby] || ![self isValid:targetcx y:targetcy] || ![self isValid:targetdx y:targetdy]) {
    @throw [NotFoundException notFoundInstance];
  }
  return [NSArray arrayWithObjects:[[[ResultPoint alloc] init:targetax param1:targetay] autorelease], [[[ResultPoint alloc] init:targetbx param1:targetby] autorelease], [[[ResultPoint alloc] init:targetcx param1:targetcy] autorelease], [[[ResultPoint alloc] init:targetdx param1:targetdy] autorelease], nil];
}


/**
 * 
 * <p> Corrects the parameter bits using Reed-Solomon algorithm </p>
 * 
 * @param parameterData paremeter bits
 * @param compact true if this is a compact Aztec code
 * @throws NotFoundException if the array contains too many errors
 */
+ (void) correctParameterData:(NSArray *)parameterData compact:(BOOL)compact {
  int numCodewords;
  int numDataCodewords;
  if (compact) {
    numCodewords = 7;
    numDataCodewords = 2;
  }
   else {
    numCodewords = 10;
    numDataCodewords = 4;
  }
  int numECCodewords = numCodewords - numDataCodewords;
  NSArray * parameterWords = [NSArray array];
  int codewordSize = 4;

  for (int i = 0; i < numCodewords; i++) {
    int flag = 1;

    for (int j = 1; j <= codewordSize; j++) {
      if (parameterData[codewordSize * i + codewordSize - j]) {
        parameterWords[i] += flag;
      }
      flag <<= 1;
    }

  }


  @try {
    ReedSolomonDecoder * rsDecoder = [[[ReedSolomonDecoder alloc] init:GenericGF.AZTEC_PARAM] autorelease];
    [rsDecoder decode:parameterWords param1:numECCodewords];
  }
  @catch (ReedSolomonException * rse) {
    @throw [NotFoundException notFoundInstance];
  }

  for (int i = 0; i < numDataCodewords; i++) {
    int flag = 1;

    for (int j = 1; j <= codewordSize; j++) {
      parameterData[i * codewordSize + codewordSize - j] = (parameterWords[i] & flag) == flag;
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
- (NSArray *) getBullEyeCornerPoints:(Point *)pCenter {
  Point * pina = pCenter;
  Point * pinb = pCenter;
  Point * pinc = pCenter;
  Point * pind = pCenter;
  BOOL color = YES;

  for (nbCenterLayers = 1; nbCenterLayers < 9; nbCenterLayers++) {
    Point * pouta = [self getFirstDifferent:pina color:color dx:1 dy:-1];
    Point * poutb = [self getFirstDifferent:pinb color:color dx:1 dy:1];
    Point * poutc = [self getFirstDifferent:pinc color:color dx:-1 dy:1];
    Point * poutd = [self getFirstDifferent:pind color:color dx:-1 dy:-1];
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
  if (![self isValid:targetax y:targetay] || ![self isValid:targetbx y:targetby] || ![self isValid:targetcx y:targetcy] || ![self isValid:targetdx y:targetdy]) {
    @throw [NotFoundException notFoundInstance];
  }
  Point * pa = [[[Point alloc] init:targetax param1:targetay] autorelease];
  Point * pb = [[[Point alloc] init:targetbx param1:targetby] autorelease];
  Point * pc = [[[Point alloc] init:targetcx param1:targetcy] autorelease];
  Point * pd = [[[Point alloc] init:targetdx param1:targetdy] autorelease];
  return [NSArray arrayWithObjects:pa, pb, pc, pd, nil];
}


/**
 * 
 * Finds a candidate center point of an Aztec code from an image
 * 
 * @return the center point
 */
- (Point *) getMatrixCenter {
  ResultPoint * pointA;
  ResultPoint * pointB;
  ResultPoint * pointC;
  ResultPoint * pointD;

  @try {
    NSArray * cornerPoints = [[[[WhiteRectangleDetector alloc] init:image] autorelease] detect];
    pointA = cornerPoints[0];
    pointB = cornerPoints[1];
    pointC = cornerPoints[2];
    pointD = cornerPoints[3];
  }
  @catch (NotFoundException * e) {
    int cx = image.width / 2;
    int cy = image.height / 2;
    pointA = [[self getFirstDifferent:[[[Point alloc] init:cx + 15 / 2 param1:cy - 15 / 2] autorelease] color:NO dx:1 dy:-1] toResultPoint];
    pointB = [[self getFirstDifferent:[[[Point alloc] init:cx + 15 / 2 param1:cy + 15 / 2] autorelease] color:NO dx:1 dy:1] toResultPoint];
    pointC = [[self getFirstDifferent:[[[Point alloc] init:cx - 15 / 2 param1:cy + 15 / 2] autorelease] color:NO dx:-1 dy:1] toResultPoint];
    pointD = [[self getFirstDifferent:[[[Point alloc] init:cx - 15 / 2 param1:cy - 15 / 2] autorelease] color:NO dx:-1 dy:-1] toResultPoint];
  }
  int cx = [self round:([pointA x] + [pointD x] + [pointB x] + [pointC x]) / 4];
  int cy = [self round:([pointA y] + [pointD y] + [pointB y] + [pointC y]) / 4];

  @try {
    NSArray * cornerPoints = [[[[WhiteRectangleDetector alloc] init:image param1:15 param2:cx param3:cy] autorelease] detect];
    pointA = cornerPoints[0];
    pointB = cornerPoints[1];
    pointC = cornerPoints[2];
    pointD = cornerPoints[3];
  }
  @catch (NotFoundException * e) {
    pointA = [[self getFirstDifferent:[[[Point alloc] init:cx + 15 / 2 param1:cy - 15 / 2] autorelease] color:NO dx:1 dy:-1] toResultPoint];
    pointB = [[self getFirstDifferent:[[[Point alloc] init:cx + 15 / 2 param1:cy + 15 / 2] autorelease] color:NO dx:1 dy:1] toResultPoint];
    pointC = [[self getFirstDifferent:[[[Point alloc] init:cx - 15 / 2 param1:cy + 15 / 2] autorelease] color:NO dx:-1 dy:1] toResultPoint];
    pointD = [[self getFirstDifferent:[[[Point alloc] init:cx - 15 / 2 param1:cy - 15 / 2] autorelease] color:NO dx:-1 dy:-1] toResultPoint];
  }
  cx = [self round:([pointA x] + [pointD x] + [pointB x] + [pointC x]) / 4];
  cy = [self round:([pointA y] + [pointD y] + [pointB y] + [pointC y]) / 4];
  return [[[Point alloc] init:cx param1:cy] autorelease];
}


/**
 * Samples an Aztec matrix from an image
 */
- (BitMatrix *) sampleGrid:(BitMatrix *)image topLeft:(ResultPoint *)topLeft bottomLeft:(ResultPoint *)bottomLeft bottomRight:(ResultPoint *)bottomRight topRight:(ResultPoint *)topRight {
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
  return [sampler sampleGrid:image param1:dimension param2:dimension param3:0.5f param4:0.5f param5:dimension - 0.5f param6:0.5f param7:dimension - 0.5f param8:dimension - 0.5f param9:0.5f param10:dimension - 0.5f param11:[topLeft x] param12:[topLeft y] param13:[topRight x] param14:[topRight y] param15:[bottomRight x] param16:[bottomRight y] param17:[bottomLeft x] param18:[bottomLeft y]];
}


/**
 * Sets number of layers and number of datablocks from parameter bits
 */
- (void) getParameters:(NSArray *)parameterData {
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
    if (parameterData[i]) {
      nbLayers += 1;
    }
  }


  for (int i = nbBitsForNbLayers; i < nbBitsForNbLayers + nbBitsForNbDatablocks; i++) {
    nbDataBlocks <<= 1;
    if (parameterData[i]) {
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
- (NSArray *) sampleLine:(Point *)p1 p2:(Point *)p2 size:(int)size {
  NSArray * res = [NSArray array];
  float d = [self distance:p1 b:p2];
  float moduleSize = d / (size - 1);
  float dx = moduleSize * (p2.x - p1.x) / d;
  float dy = moduleSize * (p2.y - p1.y) / d;
  float px = p1.x;
  float py = p1.y;

  for (int i = 0; i < size; i++) {
    res[i] = [image get:[self round:px] param1:[self round:py]];
    px += dx;
    py += dy;
  }

  return res;
}


/**
 * @return true if the border of the rectangle passed in parameter is compound of white points only
 * or black points only
 */
- (BOOL) isWhiteOrBlackRectangle:(Point *)p1 p2:(Point *)p2 p3:(Point *)p3 p4:(Point *)p4 {
  int corr = 3;
  p1 = [[[Point alloc] init:p1.x - corr param1:p1.y + corr] autorelease];
  p2 = [[[Point alloc] init:p2.x - corr param1:p2.y - corr] autorelease];
  p3 = [[[Point alloc] init:p3.x + corr param1:p3.y - corr] autorelease];
  p4 = [[[Point alloc] init:p4.x + corr param1:p4.y + corr] autorelease];
  int cInit = [self getColor:p4 p2:p1];
  if (cInit == 0) {
    return NO;
  }
  int c = [self getColor:p1 p2:p2];
  if (c != cInit || c == 0) {
    return NO;
  }
  c = [self getColor:p2 p2:p3];
  if (c != cInit || c == 0) {
    return NO;
  }
  c = [self getColor:p3 p2:p4];
  return c == cInit && c != 0;
}


/**
 * Gets the color of a segment
 * 
 * @return 1 if segment more than 90% black, -1 if segment is more than 90% white, 0 else
 */
- (int) getColor:(Point *)p1 p2:(Point *)p2 {
  float d = [self distance:p1 b:p2];
  float dx = (p2.x - p1.x) / d;
  float dy = (p2.y - p1.y) / d;
  int error = 0;
  float px = p1.x;
  float py = p1.y;
  BOOL colorModel = [image get:p1.x param1:p1.y];

  for (int i = 0; i < d; i++) {
    px += dx;
    py += dy;
    if ([image get:[self round:px] param1:[self round:py]] != colorModel) {
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
- (Point *) getFirstDifferent:(Point *)init color:(BOOL)color dx:(int)dx dy:(int)dy {
  int x = init.x + dx;
  int y = init.y + dy;

  while ([self isValid:x y:y] && [image get:x param1:y] == color) {
    x += dx;
    y += dy;
  }

  x -= dx;
  y -= dy;

  while ([self isValid:x y:y] && [image get:x param1:y] == color) {
    x += dx;
  }

  x -= dx;

  while ([self isValid:x y:y] && [image get:x param1:y] == color) {
    y += dy;
  }

  y -= dy;
  return [[[Point alloc] init:x param1:y] autorelease];
}

- (BOOL) isValid:(int)x y:(int)y {
  return x >= 0 && x < image.width && y > 0 && y < image.height;
}


/**
 * Ends up being a bit faster than Math.round(). This merely rounds its
 * argument to the nearest int, where x.5 rounds up.
 */
+ (int) round:(float)d {
  return (int)(d + 0.5f);
}

+ (float) distance:(Point *)a b:(Point *)b {
  return (float)[Math sqrt:(a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y)];
}

- (void) dealloc {
  [image release];
  [super dealloc];
}

@end
