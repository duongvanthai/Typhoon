////////////////////////////////////////////////////////////////////////////////
//
//  TYPHOON FRAMEWORK
//  Copyright 2013, Jasper Blues & Contributors
//  All Rights Reserved.
//
//  NOTICE: The authors permit you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////



#import <objc/runtime.h>
#import "TyphoonBlockComponentFactory.h"
#import "TyphoonAssembly.h"
#import "TyphoonDefinition.h"
#import "OCLogTemplate.h"
#import "TyphoonAssembly+TyphoonAssemblyFriend.h"

@implementation TyphoonBlockComponentFactory

/* ====================================================================================================================================== */
#pragma mark - Class Methods
+ (instancetype)factoryWithAssembly:(TyphoonAssembly*)assembly
{
    return [[self alloc] initWithAssemblies:@[assembly]];
}

+ (instancetype)factoryWithAssemblies:(NSArray*)assemblies
{
    return [[self alloc] initWithAssemblies:assemblies];
}

/* ====================================================================================================================================== */
#pragma mark - Initialization & Destruction

- (instancetype)initWithAssembly:(TyphoonAssembly*)assembly
{
    return [self initWithAssemblies:@[assembly]];
}

- (instancetype)initWithAssemblies:(NSArray*)assemblies
{
    self = [super init];
    if (self)
    {
        for (TyphoonAssembly* assembly in assemblies)
        {
            LogTrace(@"Building assembly: %@", NSStringFromClass([assembly class]));
            [self assertIsAssembly:assembly];

            [assembly prepareForUse];
            [self registerAllDefinitions:assembly];
        }
    }
    return self;
}

- (void)assertIsAssembly:(TyphoonAssembly*)assembly
{
    if (![assembly isKindOfClass:[TyphoonAssembly class]]) //
    {
        [NSException raise:NSInvalidArgumentException format:@"Class '%@' is not a sub-class of %@",
                                                             NSStringFromClass([assembly class]),
                                                             NSStringFromClass([TyphoonAssembly class])];
    }
}

- (void)registerAllDefinitions:(TyphoonAssembly*)assembly
{
    NSArray* definitions = [assembly definitions];
    for (TyphoonDefinition* definition in definitions)
    {
        [self register:definition];
    }
}

/* ====================================================================================================================================== */
#pragma mark - Overridden Methods

- (void)forwardInvocation:(NSInvocation*)invocation
{
    NSString* componentKey = NSStringFromSelector([invocation selector]);
    LogTrace(@"Component key: %@", componentKey);

    [invocation setSelector:@selector(componentForKey:)];
    [invocation setArgument:&componentKey atIndex:2];
    [invocation invoke];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)aSelector
{
    if ([self respondsToSelector:aSelector])
    {
        return [[self class] instanceMethodSignatureForSelector:aSelector];
    }
    else
    {
        return [[self class] instanceMethodSignatureForSelector:@selector(componentForKey:)];
    }
}

@end