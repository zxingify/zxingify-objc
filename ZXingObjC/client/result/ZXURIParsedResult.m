#import "ZXURIParsedResult.h"

@interface ZXURIParsedResult ()

- (BOOL) containsUser;
- (BOOL) isColonFollowedByPortNumber:(NSString *)uri protocolEnd:(int)protocolEnd;
- (NSString *) massageURI:(NSString *)uri;

@end

@implementation ZXURIParsedResult

@synthesize uri;
@synthesize title;
@synthesize possiblyMaliciousURI;
@synthesize displayResult;

- (id) initWithUri:(NSString *)aUri title:(NSString *)aTitle {
  if (self = [super initWithType:kParsedResultTypeURI]) {
    uri = [[self massageURI:uri] copy];
    title = [aTitle copy];
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
  int hostStart = [uri rangeOfString:@":"].location;
  hostStart++;
  int uriLength = [uri length];

  while (hostStart < uriLength && [uri characterAtIndex:hostStart] == '/') {
    hostStart++;
  }

  int hostEnd = [uri rangeOfString:@"/" options:0 range:NSMakeRange(hostStart, uriLength - hostStart)].location;
  if (hostEnd < 0) {
    hostEnd = uriLength;
  }
  int at = [uri rangeOfString:@"@" options:0 range:NSMakeRange(hostStart, uriLength - hostStart)].location;
  return at >= hostStart && at < hostEnd;
}

- (NSString *) displayResult {
  NSMutableString* result = [NSMutableString stringWithCapacity:30];
  [ZXParsedResult maybeAppend:title result:result];
  [ZXParsedResult maybeAppend:uri result:result];
  return result;
}

/**
 * Transforms a string that represents a URI into something more proper, by adding or canonicalizing
 * the protocol.
 */
- (NSString *) massageURI:(NSString *)aUri {
  NSString *_uri = [aUri stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  int protocolEnd = [_uri rangeOfString:@":"].location;
  if (protocolEnd < 0) {
    // No protocol, assume http
    _uri = [NSString stringWithFormat:@"http://%@", _uri];
  } else if ([self isColonFollowedByPortNumber:_uri protocolEnd:protocolEnd]) {
    // Found a colon, but it looks like it is after the host, so the protocol is still missing
    _uri = [NSString stringWithFormat:@"http://%@", _uri];
  } else {
    _uri = [[[_uri substringToIndex:protocolEnd] lowercaseString] stringByAppendingString:[_uri substringFromIndex:protocolEnd]];
  }
  return _uri;
}

- (BOOL) isColonFollowedByPortNumber:(NSString *)aUri protocolEnd:(int)protocolEnd {
  int nextSlash = [aUri rangeOfString:@"/" options:0 range:NSMakeRange(protocolEnd + 1, [aUri length] - protocolEnd - 1)].location;
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
