#import "DataMask.h"

@implementation DataMask000

- (BOOL) isMasked:(int)i j:(int)j {
  return ((i + j) & 0x01) == 0;
}

@end

@implementation DataMask001

- (BOOL) isMasked:(int)i j:(int)j {
  return (i & 0x01) == 0;
}

@end

@implementation DataMask010

- (BOOL) isMasked:(int)i j:(int)j {
  return j % 3 == 0;
}

@end

@implementation DataMask011

- (BOOL) isMasked:(int)i j:(int)j {
  return (i + j) % 3 == 0;
}

@end

@implementation DataMask100

- (BOOL) isMasked:(int)i j:(int)j {
  return (((i >>> 1) + (j / 3)) & 0x01) == 0;
}

@end

@implementation DataMask101

- (BOOL) isMasked:(int)i j:(int)j {
  int temp = i * j;
  return (temp & 0x01) + (temp % 3) == 0;
}

@end

@implementation DataMask110

- (BOOL) isMasked:(int)i j:(int)j {
  int temp = i * j;
  return (((temp & 0x01) + (temp % 3)) & 0x01) == 0;
}

@end

@implementation DataMask111

- (BOOL) isMasked:(int)i j:(int)j {
  return ((((i + j) & 0x01) + ((i * j) % 3)) & 0x01) == 0;
}

@end


/**
 * See ISO 18004:2006 6.8.1
 */
NSArray * const DATA_MASKS = [NSArray arrayWithObjects:[[[DataMask000 alloc] init] autorelease], [[[DataMask001 alloc] init] autorelease], [[[DataMask010 alloc] init] autorelease], [[[DataMask011 alloc] init] autorelease], [[[DataMask100 alloc] init] autorelease], [[[DataMask101 alloc] init] autorelease], [[[DataMask110 alloc] init] autorelease], [[[DataMask111 alloc] init] autorelease], nil];

@implementation DataMask

- (id) init {
  if (self = [super init]) {
  }
  return self;
}


/**
 * <p>Implementations of this method reverse the data masking process applied to a QR Code and
 * make its bits ready to read.</p>
 * 
 * @param bits representation of QR Code bits
 * @param dimension dimension of QR Code, represented by bits, being unmasked
 */
- (void) unmaskBitMatrix:(BitMatrix *)bits dimension:(int)dimension {

  for (int i = 0; i < dimension; i++) {

    for (int j = 0; j < dimension; j++) {
      if ([self isMasked:i j:j]) {
        [bits flip:j param1:i];
      }
    }

  }

}

- (BOOL) isMasked:(int)i j:(int)j {
}


/**
 * @param reference a value between 0 and 7 indicating one of the eight possible
 * data mask patterns a QR Code may use
 * @return DataMask encapsulating the data mask pattern
 */
+ (DataMask *) forReference:(int)reference {
  if (reference < 0 || reference > 7) {
    @throw [[[IllegalArgumentException alloc] init] autorelease];
  }
  return DATA_MASKS[reference];
}

@end
