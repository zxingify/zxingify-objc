#import "ResultParser.h"

/**
 * Parses a WIFI configuration string.  Strings will be of the form:
 * WIFI:T:WPA;S:mynetwork;P:mypass;;
 * 
 * The fields can come in any order, and there should be tests to see
 * if we can parse them all correctly.
 * 
 * @author Vikram Aggarwal
 */

@class Result, WifiParsedResult;

@interface WifiResultParser : ResultParser

+ (WifiParsedResult *) parse:(Result *)result;

@end
