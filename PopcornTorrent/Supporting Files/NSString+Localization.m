

#import "NSString+Localization.h"

@implementation NSString (Localization)

- (NSString *)localizedString {
    return [[NSBundle bundleWithIdentifier:@"com.popcorntimetv.popcorntorrent"] localizedStringForKey:self value:self table:nil];
}

@end
