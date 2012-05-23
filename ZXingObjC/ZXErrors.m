#import "ZXErrors.h"

NSError* ChecksumErrorInstance() {
  NSDictionary* userInfo = [NSDictionary dictionaryWithObject:@"This barcode does failed its checksum"
                                                       forKey:NSLocalizedDescriptionKey];

  return [[[NSError alloc] initWithDomain:ZXErrorDomain code:ZXChecksumError userInfo:userInfo] autorelease];
}

NSError* FormatErrorInstance() {
  NSDictionary* userInfo = [NSDictionary dictionaryWithObject:@"This barcode does not confirm to the format's rules"
                                                       forKey:NSLocalizedDescriptionKey];

  return [[[NSError alloc] initWithDomain:ZXErrorDomain code:ZXFormatError userInfo:userInfo] autorelease];
}

NSError* NotFoundErrorInstance() {
  NSDictionary* userInfo = [NSDictionary dictionaryWithObject:@"A barcode was not found in this image"
                                                       forKey:NSLocalizedDescriptionKey];

  return [[[NSError alloc] initWithDomain:ZXErrorDomain code:ZXNotFoundError userInfo:userInfo] autorelease];
}