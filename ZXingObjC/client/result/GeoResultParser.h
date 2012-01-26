#import "ParsedResult.h"
#import "Result.h"

/**
 * Parses a "geo:" URI result, which specifies a location on the surface of
 * the Earth as well as an optional altitude above the surface. See
 * <a href="http://tools.ietf.org/html/draft-mayrhofer-geo-uri-00">
 * http://tools.ietf.org/html/draft-mayrhofer-geo-uri-00</a>.
 * 
 * @author Sean Owen
 */

@interface GeoResultParser : ResultParser {
}

+ (GeoParsedResult *) parse:(Result *)result;
@end
