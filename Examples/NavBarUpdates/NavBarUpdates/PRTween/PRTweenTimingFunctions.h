/*
 
 These timing functions are adapted from Robert Penner's excellent AS2 easing equations.
 For more information, check out http://robertpenner.com/easing/
 
 --
 
 TERMS OF USE - EASING EQUATIONS
 
 Open source under the BSD License. 
 
 Copyright © 2001 Robert Penner
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 Neither the name of the author nor the names of contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
*/

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

CGFloat PRTweenTimingFunctionLinear (CGFloat, CGFloat, CGFloat, CGFloat);

CGFloat PRTweenTimingFunctionBackOut (CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat PRTweenTimingFunctionBackIn (CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat PRTweenTimingFunctionBackInOut (CGFloat, CGFloat, CGFloat, CGFloat);

CGFloat PRTweenTimingFunctionBounceOut (CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat PRTweenTimingFunctionBounceIn (CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat PRTweenTimingFunctionBounceInOut (CGFloat, CGFloat, CGFloat, CGFloat);

CGFloat PRTweenTimingFunctionCircOut (CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat PRTweenTimingFunctionCircIn (CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat PRTweenTimingFunctionCircInOut (CGFloat, CGFloat, CGFloat, CGFloat);

CGFloat PRTweenTimingFunctionCubicOut (CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat PRTweenTimingFunctionCubicIn (CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat PRTweenTimingFunctionCubicInOut (CGFloat, CGFloat, CGFloat, CGFloat);

CGFloat PRTweenTimingFunctionElasticOut (CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat PRTweenTimingFunctionElasticIn (CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat PRTweenTimingFunctionElasticInOut (CGFloat, CGFloat, CGFloat, CGFloat);

CGFloat PRTweenTimingFunctionExpoOut (CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat PRTweenTimingFunctionExpoIn (CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat PRTweenTimingFunctionExpoInOut (CGFloat, CGFloat, CGFloat, CGFloat);

CGFloat PRTweenTimingFunctionQuadOut (CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat PRTweenTimingFunctionQuadIn (CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat PRTweenTimingFunctionQuadInOut (CGFloat, CGFloat, CGFloat, CGFloat);

CGFloat PRTweenTimingFunctionQuartOut (CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat PRTweenTimingFunctionQuartIn (CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat PRTweenTimingFunctionQuartInOut (CGFloat, CGFloat, CGFloat, CGFloat);

CGFloat PRTweenTimingFunctionQuintOut (CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat PRTweenTimingFunctionQuintIn (CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat PRTweenTimingFunctionQuintInOut (CGFloat, CGFloat, CGFloat, CGFloat);

CGFloat PRTweenTimingFunctionSineOut (CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat PRTweenTimingFunctionSineIn (CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat PRTweenTimingFunctionSineInOut (CGFloat, CGFloat, CGFloat, CGFloat);

CGFloat PRTweenTimingFunctionCALinear (CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat PRTweenTimingFunctionCAEaseIn (CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat PRTweenTimingFunctionCAEaseOut (CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat PRTweenTimingFunctionCAEaseInOut (CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat PRTweenTimingFunctionCADefault (CGFloat, CGFloat, CGFloat, CGFloat);

CGFloat PRTweenTimingFunctionUIViewLinear (CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat PRTweenTimingFunctionUIViewEaseIn (CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat PRTweenTimingFunctionUIViewEaseOut (CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat PRTweenTimingFunctionUIViewEaseInOut (CGFloat, CGFloat, CGFloat, CGFloat);

CGFloat (*PRTweenTimingFunctionCACustom(CAMediaTimingFunction *timingFunction))(CGFloat, CGFloat, CGFloat, CGFloat);


