//
//  UIBase.h
//  UIKit
//
//  Created by Zac Bowling on 9/11/11.
//
// Copyright (C) 2011 SeatMe, Inc http://www.seatme.com
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//


#ifdef __OBJC__
    #ifndef __clang__
    //Required to make CGRect work nicely with NSRect on 32bit with GCC. 
    #define NS_BUILD_32_LIKE_64 1
    #endif
    #import <Foundation/Foundation.h>
#endif


#ifndef IBAction
#define IBAction void
#endif

#ifndef IBOutlet
#define IBOutlet
#endif


// If ARC is not enabled, declare empty ARC directives to supress compiler errors
#ifndef __has_feature
#define __has_feature(x) 0 // Compatibility with non-clang compilers.
#endif

#if __has_feature(objc_arc)
#define ASSIGNWEAK weak
#else
#define ASSIGNWEAK assign
#define __unsafe_unretained
#define __bridge
//    #define __weak
#endif


#ifndef __CHAMELEON_STUB
#define __CHAMELEON_STUB(x)
#endif

#ifndef __CHAMELEON_STUB_IMPLEMENTATION
#define __CHAMELEON_STUB_IMPLEMENTATION
#endif