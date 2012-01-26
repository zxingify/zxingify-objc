#import "AbstractNDEFResultParser.h"

@implementation AbstractNDEFResultParser

+ (NSString *) bytesToString:(NSArray *)bytes offset:(int)offset length:(int)length encoding:(NSString *)encoding {

  @try {
    return [[[NSString alloc] init:bytes param1:offset param2:length param3:encoding] autorelease];
  }
  @catch (UnsupportedEncodingException * uee) {
    @throw [[[NSException alloc] init:[@"Platform does not support required encoding: " stringByAppendingString:uee]] autorelease];
  }
}

@end
