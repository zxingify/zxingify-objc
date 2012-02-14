#import "AbstractNDEFResultParser.h"

@implementation AbstractNDEFResultParser

+ (NSString *) bytesToString:(char *)bytes offset:(int)offset length:(int)length encoding:(NSStringEncoding)encoding { 
  return [[[NSString alloc] initWithBytes:bytes + offset length:length encoding:encoding] autorelease];
}

@end
