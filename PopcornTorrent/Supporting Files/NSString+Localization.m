

#import "NSString+Localization.h"

@implementation NSString (Localization)

- (NSString *)localizedString {
    return NSLocalizedString(self, nil);
}

@end
