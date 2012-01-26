#import "URIParsedResult.h"

@implementation URIParsedResult

@synthesize uRI;
@synthesize title;
@synthesize possiblyMaliciousURI;
@synthesize displayResult;

- (id) init:(NSString *)uri title:(NSString *)title {
  if (self = [super init:ParsedResultType.URI]) {
    uri = [self massageURI:uri];
    title = title;
  }
  return self;
}


/**
 * @return true if the URI contains suspicious patterns that may suggest it intends to
 * mislead the user about its true nature. At the moment this looks for the presence
 * of user/password syntax in the host/authority portion of a URI which may be used
 * in attempts to make the URI's host appear to be other than it is. Example:
 * http://yourbank.com@phisher.com  This URI connects to phisher.com but may appear
 * to connect to yourbank.com at first glance.
 */
- (BOOL) possiblyMaliciousURI {
  return [self containsUser];
}

- (BOOL) containsUser {
  int hostStart = [uri rangeOfString:':'];
  hostStart++;
  int uriLength = [uri length];

  while (hostStart < uriLength && [uri characterAtIndex:hostStart] == '/') {
    hostStart++;
  }

  int hostEnd = [uri rangeOfString:'/' param1:hostStart];
  if (hostEnd < 0) {
    hostEnd = uriLength;
  }
  int at = [uri rangeOfString:'@' param1:hostStart];
  return at >= hostStart && at < hostEnd;
}

- (NSString *) displayResult {
  StringBuffer * result = [[[StringBuffer alloc] init:30] autorelease];
  [self maybeAppend:title param1:result];
  [self maybeAppend:uri param1:result];
  return [result description];
}


/**
 * Transforms a string that represents a URI into something more proper, by adding or canonicalizing
 * the protocol.
 */
+ (NSString *) massageURI:(NSString *)uri {
  uri = [uri stringByTrimmingCharactersInSet];
  int protocolEnd = [uri rangeOfString:':'];
  if (protocolEnd < 0) {
    uri = [@"http://" stringByAppendingString:uri];
  }
   else if ([self isColonFollowedByPortNumber:uri protocolEnd:protocolEnd]) {
    uri = [@"http://" stringByAppendingString:uri];
  }
   else {
    uri = [[uri substringFromIndex:0 param1:protocolEnd] toLowerCase] + [uri substringFromIndex:protocolEnd];
  }
  return uri;
}

+ (BOOL) isColonFollowedByPortNumber:(NSString *)uri protocolEnd:(int)protocolEnd {
  int nextSlash = [uri rangeOfString:'/' param1:protocolEnd + 1];
  if (nextSlash < 0) {
    nextSlash = [uri length];
  }
  if (nextSlash <= protocolEnd + 1) {
    return NO;
  }

  for (int x = protocolEnd + 1; x < nextSlash; x++) {
    if ([uri characterAtIndex:x] < '0' || [uri characterAtIndex:x] > '9') {
      return NO;
    }
  }

  return YES;
}

- (void) dealloc {
  [uri release];
  [title release];
  [super dealloc];
}

@end
