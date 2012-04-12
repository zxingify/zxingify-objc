#import "ZXBitMatrix.h"
#import "ZXDataMask.h"

/**
 * 000: mask bits for which (x + y) mod 2 == 0
 */

@interface ZXDataMask000 : ZXDataMask

@end

@implementation ZXDataMask000

- (BOOL) isMasked:(int)i j:(int)j {
  return ((i + j) & 0x01) == 0;
}

@end


/**
 * 001: mask bits for which x mod 2 == 0
 */

@interface ZXDataMask001 : ZXDataMask

@end

@implementation ZXDataMask001

- (BOOL) isMasked:(int)i j:(int)j {
  return (i & 0x01) == 0;
}

@end


/**
 * 010: mask bits for which y mod 3 == 0
 */

@interface ZXDataMask010 : ZXDataMask

@end

@implementation ZXDataMask010

- (BOOL) isMasked:(int)i j:(int)j {
  return j % 3 == 0;
}

@end


/**
 * 011: mask bits for which (x + y) mod 3 == 0
 */

@interface ZXDataMask011 : ZXDataMask

@end

@implementation ZXDataMask011

- (BOOL) isMasked:(int)i j:(int)j {
  return (i + j) % 3 == 0;
}

@end


/**
 * 100: mask bits for which (x/2 + y/3) mod 2 == 0
 */

@interface ZXDataMask100 : ZXDataMask

@end

@implementation ZXDataMask100

- (BOOL) isMasked:(int)i j:(int)j {
  return (((int)((unsigned int)i >> 1) + (j / 3)) & 0x01) == 0;
}

@end


/**
 * 101: mask bits for which xy mod 2 + xy mod 3 == 0
 */

@interface ZXDataMask101 : ZXDataMask

@end

@implementation ZXDataMask101

- (BOOL) isMasked:(int)i j:(int)j {
  int temp = i * j;
  return (temp & 0x01) + (temp % 3) == 0;
}

@end


/**
 * 110: mask bits for which (xy mod 2 + xy mod 3) mod 2 == 0
 */

@interface ZXDataMask110 : ZXDataMask

@end

@implementation ZXDataMask110

- (BOOL) isMasked:(int)i j:(int)j {
  int temp = i * j;
  return (((temp & 0x01) + (temp % 3)) & 0x01) == 0;
}

@end


/**
 * 111: mask bits for which ((x+y)mod 2 + xy mod 3) mod 2 == 0
 */

@interface ZXDataMask111 : ZXDataMask

@end

@implementation ZXDataMask111

- (BOOL) isMasked:(int)i j:(int)j {
  return ((((i + j) & 0x01) + ((i * j) % 3)) & 0x01) == 0;
}

@end


@implementation ZXDataMask

static NSArray* DATA_MASKS = nil;

/**
 * <p>Implementations of this method reverse the data masking process applied to a QR Code and
 * make its bits ready to read.</p>
 * 
 * @param bits representation of QR Code bits
 * @param dimension dimension of QR Code, represented by bits, being unmasked
 */
- (void) unmaskBitMatrix:(ZXBitMatrix *)bits dimension:(int)dimension {
  for (int i = 0; i < dimension; i++) {
    for (int j = 0; j < dimension; j++) {
      if ([self isMasked:i j:j]) {
        [bits flip:j y:i];
      }
    }
  }
}

- (BOOL) isMasked:(int)i j:(int)j {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}


/**
 * @param reference a value between 0 and 7 indicating one of the eight possible
 * data mask patterns a QR Code may use
 * @return ZXDataMask encapsulating the data mask pattern
 */
+ (ZXDataMask *) forReference:(int)reference {
  if (!DATA_MASKS) {
    /**
     * See ISO 18004:2006 6.8.1
     */
    DATA_MASKS = [[NSArray alloc] initWithObjects:
                  [[[ZXDataMask000 alloc] init] autorelease],
                  [[[ZXDataMask001 alloc] init] autorelease],
                  [[[ZXDataMask010 alloc] init] autorelease],
                  [[[ZXDataMask011 alloc] init] autorelease],
                  [[[ZXDataMask100 alloc] init] autorelease],
                  [[[ZXDataMask101 alloc] init] autorelease],
                  [[[ZXDataMask110 alloc] init] autorelease],
                  [[[ZXDataMask111 alloc] init] autorelease], nil];
  }

  if (reference < 0 || reference > 7) {
    [NSException raise:NSInvalidArgumentException  format:@"Invalid reference value"];
  }
  return [DATA_MASKS objectAtIndex:reference];
}

@end
