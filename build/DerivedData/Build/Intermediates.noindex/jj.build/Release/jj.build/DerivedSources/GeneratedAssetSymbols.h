#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "down" asset catalog image resource.
static NSString * const ACImageNameDown AC_SWIFT_PRIVATE = @"down";

/// The "eey" asset catalog image resource.
static NSString * const ACImageNameEey AC_SWIFT_PRIVATE = @"eey";

/// The "eye" asset catalog image resource.
static NSString * const ACImageNameEye AC_SWIFT_PRIVATE = @"eye";

/// The "up" asset catalog image resource.
static NSString * const ACImageNameUp AC_SWIFT_PRIVATE = @"up";

#undef AC_SWIFT_PRIVATE
