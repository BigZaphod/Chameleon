/*
 * Copyright (c) 2012, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "UIAppearanceProxy.h"
#import "UIAppearanceProperty.h"
#import <objc/runtime.h>
#import <UIKit/UIGeometry.h>
#import "UIAppearanceInstance.h"

static const char *UIAppearanceSetterOverridesAssociatedObjectKey = "UIAppearanceSetterOverridesAssociatedObjectKey";

static BOOL TypeIsSignedInteger(const char *t)
{
    return (t != NULL) && (strcmp(t,@encode(char)) == 0
                           || strcmp(t,@encode(int)) == 0
                           || strcmp(t,@encode(short)) == 0
                           || strcmp(t,@encode(long)) == 0
                           || strcmp(t,@encode(long long)) == 0);
}

static BOOL TypeIsUnsignedInteger(const char *t)
{
    return (t != NULL) && (strcmp(t,@encode(unsigned char)) == 0
                           || strcmp(t,@encode(unsigned int)) == 0
                           || strcmp(t,@encode(unsigned short)) == 0
                           || strcmp(t,@encode(unsigned long)) == 0
                           || strcmp(t,@encode(unsigned long long)) == 0);
}

static BOOL TypeIsObject(const char *t)
{
    return (t != NULL) && strcmp(t,@encode(id)) == 0;
}

static BOOL TypeIsCGFloat(const char *t)
{
    return (t != NULL) && strcmp(t,@encode(CGFloat)) == 0;
}

static BOOL TypeIsCGPoint(const char *t)
{
    return (t != NULL) && strcmp(t,@encode(CGPoint)) == 0;
}

static BOOL TypeIsCGSize(const char *t)
{
    return (t != NULL) && strcmp(t,@encode(CGSize)) == 0;
}

static BOOL TypeIsCGRect(const char *t)
{
    return (t != NULL) && strcmp(t,@encode(CGRect)) == 0;
}

static BOOL TypeIsUIEdgeInsets(const char *t)
{
    return (t != NULL) && strcmp(t,@encode(UIEdgeInsets)) == 0;
}

static BOOL TypeIsUIOffset(const char *t)
{
    return (t != NULL) && strcmp(t,@encode(UIOffset)) == 0;
}

static BOOL TypeIsIntegerType(const char *t)
{
    return TypeIsSignedInteger(t) || TypeIsUnsignedInteger(t);
}

static BOOL TypeIsPropertyType(const char *t)
{
    return TypeIsIntegerType(t)
    || TypeIsObject(t)
    || TypeIsCGFloat(t)
    || TypeIsCGPoint(t)
    || TypeIsCGSize(t)
    || TypeIsCGRect(t)
    || TypeIsUIEdgeInsets(t)
    || TypeIsUIOffset(t);
}

// fetches the original IMP for the method that we tucked away earlier (see down below) when we first registered
// an appearance setting for this class/property combo.
static IMP GetOriginalMethodIMP(id self, SEL cmd)
{
    NSValue *boxedMethodImp = nil;
    Class klass = [self class];
    
    while (klass && !boxedMethodImp) {
        NSDictionary *overrides = objc_getAssociatedObject(klass, UIAppearanceSetterOverridesAssociatedObjectKey);
        boxedMethodImp = [overrides objectForKey:NSStringFromSelector(cmd)];
        klass = [klass superclass];
    }
    
    if (boxedMethodImp && strcmp(@encode(IMP), [boxedMethodImp objCType]) == 0) {
        IMP imp;
        [boxedMethodImp getValue:&imp];
        return imp;
    } else {
        return NULL;
    }
}

// this function is used by the setter override to record which property with which axis values was set
// it then attaches that record to the *instance* (not the class!) so this information can be used later
// (currently in UIView) to intelligently apply the default UIAppearance rules without having them override
// settings that were set on the instance directly somewhere. this is how Apple's stuff works and that feature
// is the reason we have to go through all this trouble overriding stuff in the first place!
static void DidSetPropertyWithAxisValues(id self, SEL cmd, NSInteger numberOfAxisValues, NSInteger *axisValues)
{
    NSMutableArray *propertyKey = [NSMutableArray array];

    // IMPORTANT! Must build the property key the same way we do down in -forwardInvocation:
    for (NSInteger i=0; i<numberOfAxisValues; i++) {
        [propertyKey addObject:@(axisValues[i])];
    }

    [propertyKey addObject:NSStringFromSelector(cmd)];

    [self _UIAppearancePropertyDidChange:propertyKey];
}

// this evil macro is used to generate type-specific setter overrides
// it currently only supports up to 4 axis values. if more are needed, just add more cases here following the pattern. easy!
#define UIAppearanceSetterOverride(TYPE) \
static void UIAppearanceSetterOverride_##TYPE(id self, SEL cmd, TYPE property, ...) { \
    typedef void(*SetterMethod)(id, SEL, TYPE, ...); \
    SetterMethod imp = (SetterMethod)GetOriginalMethodIMP(self, cmd); \
    const NSInteger numberOfAxisValues = [[self methodSignatureForSelector:cmd] numberOfArguments] - 3; \
    if (imp && numberOfAxisValues >= 0) { \
        va_list args; va_start(args, property); \
        NSInteger axisValues[numberOfAxisValues]; \
        if (numberOfAxisValues == 0) { \
            imp(self, cmd, property); \
        } else if (numberOfAxisValues == 1) { \
            axisValues[0]=va_arg(args, NSInteger); \
            imp(self, cmd, property, axisValues[0]); \
        } else if (numberOfAxisValues == 2) { \
            axisValues[0]=va_arg(args, NSInteger); axisValues[1]=va_arg(args, NSInteger); \
            imp(self, cmd, property, axisValues[0], axisValues[1]); \
        } else if (numberOfAxisValues == 3) { \
            axisValues[0]=va_arg(args, NSInteger); axisValues[1]=va_arg(args, NSInteger); axisValues[2]=va_arg(args, NSInteger); \
            imp(self, cmd, property, axisValues[0], axisValues[1], axisValues[2]); \
        } else if (numberOfAxisValues == 4) { \
            axisValues[0]=va_arg(args, NSInteger); axisValues[1]=va_arg(args, NSInteger); axisValues[2]=va_arg(args, NSInteger); axisValues[3]=va_arg(args, NSInteger); \
            imp(self, cmd, property, axisValues[0], axisValues[1], axisValues[2], axisValues[3]); \
        } else { \
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"argument count mismatch" userInfo:nil]; \
        } \
        DidSetPropertyWithAxisValues(self, cmd, numberOfAxisValues, axisValues); \
        va_end(args); \
    } else { \
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"something terrible has happened" userInfo:nil]; \
    } \
}

// curse you, static language!
UIAppearanceSetterOverride(NSInteger)
UIAppearanceSetterOverride(NSUInteger)
UIAppearanceSetterOverride(id)
UIAppearanceSetterOverride(CGFloat)
UIAppearanceSetterOverride(CGPoint)
UIAppearanceSetterOverride(CGSize)
UIAppearanceSetterOverride(CGRect)
UIAppearanceSetterOverride(UIEdgeInsets)
UIAppearanceSetterOverride(UIOffset)

static IMP ImplementationForPropertyType(const char *t)
{
    if (TypeIsSignedInteger(t)) {
        return (IMP)UIAppearanceSetterOverride_NSInteger;
    } else if (TypeIsUnsignedInteger(t)) {
        return (IMP)UIAppearanceSetterOverride_NSUInteger;
    } else if (TypeIsObject(t)) {
        return (IMP)UIAppearanceSetterOverride_id;
    } else if (TypeIsCGFloat(t)) {
        return (IMP)UIAppearanceSetterOverride_CGFloat;
    } else if (TypeIsCGPoint(t)) {
        return (IMP)UIAppearanceSetterOverride_CGPoint;
    } else if (TypeIsCGSize(t)) {
        return (IMP)UIAppearanceSetterOverride_CGSize;
    } else if (TypeIsCGRect(t)) {
        return (IMP)UIAppearanceSetterOverride_CGRect;
    } else if (TypeIsUIEdgeInsets(t)) {
        return (IMP)UIAppearanceSetterOverride_UIEdgeInsets;
    } else if (TypeIsUIOffset(t)) {
        return (IMP)UIAppearanceSetterOverride_UIOffset;
    } else {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"no setter implementation for property type" userInfo:nil];
    }
}

@implementation UIAppearanceProxy {
    Class<UIAppearance> _targetClass;
    NSMutableDictionary *_settings;
}

- (id)initWithClass:(Class<UIAppearance>)k
{
    if ((self=[super init])) {
        _targetClass = k;
        _settings = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return self;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    // allowed selector formats:
    //  -set<Name>:forAxis:axis:axis:...
    //  -<name>ForAxis:axis:axis...
    //
    // the axis parts are optional.

    // property values must be one of these types: id, NSInteger, NSUInteger, CGFloat, CGPoint, CGSize, CGRect, UIEdgeInsets or UIOffset.

    // each axis must be either NSInteger or NSUInteger.
    // throw an exception if other types are used in an axis.

    NSMethodSignature *methodSignature = [anInvocation methodSignature];
    NSMutableArray *propertyKey = [NSMutableArray array];

    // see if this selector is a setter or a getter
    const BOOL isSetter = [NSStringFromSelector([anInvocation selector]) hasPrefix:@"set"] && [methodSignature numberOfArguments] > 2 && strcmp([methodSignature methodReturnType], @encode(void)) == 0;
    const BOOL isGetter = !isSetter && strcmp([methodSignature methodReturnType], @encode(void)) != 0;
    
    // ensure that the property type is legit
    const char *propertyType = isSetter? [methodSignature getArgumentTypeAtIndex:2] : (isGetter? [methodSignature methodReturnType] : NULL);
    if (!TypeIsPropertyType(propertyType)) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"property type must be id, NSInteger, NSUInteger, CGFloat, CGPoint, CGSize, CGRect, UIEdgeInsets or UIOffset" userInfo:nil];
    }
    
    // use axis arguments when building the unique key for this property
    const int axisStartIndex = isSetter? 3 : 2;
    for (int i=axisStartIndex; i<[methodSignature numberOfArguments]; i++) {
        const char *type = [methodSignature getArgumentTypeAtIndex:i];
        
        // ensure that the axis arguments are integers
        if (!TypeIsIntegerType(type)) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"axis type must be NSInteger or NSUInteger" userInfo:nil];
        }
        
        NSInteger axisValue = 0;
        [anInvocation getArgument:&axisValue atIndex:i];
        [propertyKey addObject:@(axisValue)];
    }
    
    if (isGetter) {
        // convert the getter's selector into a setter's selector since that's what we actually key the property value with
        NSMutableString *selectorKeyString = [NSStringFromSelector([anInvocation selector]) mutableCopy];
        [selectorKeyString replaceCharactersInRange:NSMakeRange(0, 1) withString:[[selectorKeyString substringToIndex:1] uppercaseString]];
        [selectorKeyString insertString:@"set" atIndex:0];
        
        // if the property has 1 or more axis parts, we need to take those into account, too
        if ([methodSignature numberOfArguments] > 2) {
            const NSRange colonRange = [selectorKeyString rangeOfString:@":"];
            const NSRange forRange = [selectorKeyString rangeOfString:@"For"];
            
            if (colonRange.location != NSNotFound && forRange.location != NSNotFound && colonRange.location > NSMaxRange(forRange)) {
                const NSRange axisNameRange = NSMakeRange(forRange.location+3, colonRange.location-forRange.location-3);
                NSString *axisName = [selectorKeyString substringWithRange:axisNameRange];
                axisName = [axisName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[axisName substringToIndex:1] uppercaseString]];
                NSString *axisSelectorPartName = [NSString stringWithFormat:@"for%@:", axisName];
                [selectorKeyString insertString:axisSelectorPartName atIndex:NSMaxRange(colonRange)];
                [selectorKeyString replaceCharactersInRange:NSMakeRange(forRange.location, colonRange.location-forRange.location) withString:@""];
            }
        } else {
            [selectorKeyString appendString:@":"];
        }

        // finish building the property key now that we have the expected selector name
        [propertyKey addObject:[selectorKeyString copy]];

        // fetch the current property value using the key and put it in the current invocation
        // so it can be returned to the caller
        UIAppearanceProperty *propertyValue = [_settings objectForKey:propertyKey];
        [propertyValue setReturnValueForInvocation:anInvocation];
    }
    else if (isSetter) {
        NSString *selectorString = NSStringFromSelector([anInvocation selector]);

        // finish building the property key using the selector we have
        [propertyKey addObject:selectorString];
        
        // save the actual property value using the key
        [_settings setObject:[[UIAppearanceProperty alloc] initWithInvocation:anInvocation] forKey:propertyKey];
        
        // WARNING! Swizzling ahead!
        
        // what we're doing here is sneakily overriding the existing implemention with our own so we can track when the setter is called
        // and not have the appearance defaults override if a more local setting has been made.
        // the plan is to replace the class's original implementation of the setter with a custom one and save off the original IMP
        // so that we can call it later after doing what we need to do in the custom setter.
        // this checks to see if we've overriden the current setter for this class or not, and if not, we do so and store it off
        // in an associated dictionary that's attached to the class itself so we can get at it later from our setter.
        // I could not come up with a better way to do this and I have no idea how safe this really is at this point.
        // I wanted to insert a custom class a bit like how KVO apparently works, but it turns out most of the functions I need
        // for that are either deprecated or marked as "don't use" in the docs. :/ this is the best I could come up with given my
        // current knowledge of how everything works at this abstraction level. abandon all hope, ye who enter here...
        
        NSMutableDictionary *methodOverrides = objc_getAssociatedObject(_targetClass, UIAppearanceSetterOverridesAssociatedObjectKey);
        
        if (!methodOverrides) {
            methodOverrides = [NSMutableDictionary dictionaryWithCapacity:1];
            objc_setAssociatedObject(_targetClass, UIAppearanceSetterOverridesAssociatedObjectKey, methodOverrides, OBJC_ASSOCIATION_RETAIN);
        }
        
        if (![methodOverrides objectForKey:selectorString]) {
            Method method = class_getInstanceMethod(_targetClass, [anInvocation selector]);
            
            if (method) {
                IMP implementation = method_getImplementation(method);
                IMP overrideImplementation =  ImplementationForPropertyType([methodSignature getArgumentTypeAtIndex:2]);
                
                if (implementation != overrideImplementation) {
                    [methodOverrides setObject:[NSValue valueWithBytes:&implementation objCType:@encode(IMP)] forKey:selectorString];
                    class_replaceMethod(_targetClass, [anInvocation selector], overrideImplementation, method_getTypeEncoding(method));
                }
            }
        }
    }
    else {
        // derp
        [self doesNotRecognizeSelector:[anInvocation selector]];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [super methodSignatureForSelector:aSelector] ?: [(id)_targetClass instanceMethodSignatureForSelector:aSelector];
}

- (NSDictionary *)_appearancePropertiesAndValues
{
    return [_settings copy];
}

@end
