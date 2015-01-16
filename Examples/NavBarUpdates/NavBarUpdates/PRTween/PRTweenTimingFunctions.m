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

#import "PRTweenTimingFunctions.h"

CGFloat PRTweenTimingFunctionLinear (CGFloat time, CGFloat begin, CGFloat change, CGFloat duration) {
    return change * time / duration + begin;
}

CGFloat PRTweenTimingFunctionBackOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    CGFloat s = 1.70158;
    t=t/d-1;
    return c*(t*t*((s+1)*t + s) + 1) + b;
}

CGFloat PRTweenTimingFunctionBackIn (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    CGFloat s = 1.70158;
    t/=d;
    return c*t*t*((s+1)*t - s) + b;
}

CGFloat PRTweenTimingFunctionBackInOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    CGFloat s = 1.70158;
    if ((t/=d/2) < 1) {
        s*=(1.525);
        return c/2*(t*t*((s+1)*t - s)) + b;
    }
    t-=2;
    s*=(1.525);
    return c/2*(t*t*((s+1)*t + s) + 2) + b;
}

CGFloat PRTweenTimingFunctionBounceOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    if ((t/=d) < (1/2.75)) {
        return c*(7.5625*t*t) + b;
    } else if (t < (2/2.75)) {
        t-=(1.5/2.75);
        return c*(7.5625*t*t + .75) + b;
    } else if (t < (2.5/2.75)) {
        t-=(2.25/2.75);
        return c*(7.5625*t*t + .9375) + b;
    } else {
        t-=(2.625/2.75);
        return c*(7.5625*t*t + .984375) + b;
    }
}

CGFloat PRTweenTimingFunctionBounceIn (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    return c - PRTweenTimingFunctionBounceOut(d-t, 0, c, d) + b;
}

CGFloat PRTweenTimingFunctionBounceInOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    if (t < d/2) return PRTweenTimingFunctionBounceIn(t*2, 0, c, d) * .5 + b;
    else return PRTweenTimingFunctionBounceOut(t*2-d, 0, c, d) * .5 + c*.5 + b;
}

CGFloat PRTweenTimingFunctionCircOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    t=t/d-1;
    return c * sqrt(1 - t*t) + b;
}

CGFloat PRTweenTimingFunctionCircIn (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    t/=d;
    return -c * (sqrt(1 - t*t) - 1) + b;
}

CGFloat PRTweenTimingFunctionCircInOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    if ((t/=d/2) < 1) return -c/2 * (sqrt(1 - t*t) - 1) + b;
    t-=2;
    return c/2 * (sqrt(1 - t*t) + 1) + b;
}

CGFloat PRTweenTimingFunctionCubicOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    t=t/d-1;
    return c*(t*t*t + 1) + b;
}

CGFloat PRTweenTimingFunctionCubicIn (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    t/=d;
    return c*t*t*t + b;
}

CGFloat PRTweenTimingFunctionCubicInOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    if ((t/=d/2) < 1) return c/2*t*t*t + b;
    t-=2;
    return c/2*(t*t*t + 2) + b;
}

CGFloat PRTweenTimingFunctionElasticOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    CGFloat p = d*.3;
    CGFloat s, a = .0;
    if (t==0) return b;  if ((t/=d)==1) return b+c;
    if (!a || a < ABS(c)) { a=c; s=p/4; }
    else s = p/(2*M_PI) * asin (c/a);
    return (a*pow(2,-10*t) * sin( (t*d-s)*(2*M_PI)/p ) + c + b);
}

CGFloat PRTweenTimingFunctionElasticIn (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    CGFloat p = d*.3;
    CGFloat s, a = .0;
    if (t==0) return b;  if ((t/=d)==1) return b+c;
    if (!a || a < ABS(c)) { a=c; s=p/4; }
    else s = p/(2*M_PI) * asin (c/a);
    t-=1;
    return -(a*pow(2,10*t) * sin( (t*d-s)*(2*M_PI)/p )) + b;
}

CGFloat PRTweenTimingFunctionElasticInOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    CGFloat p = d*(.3*1.5);
    CGFloat s, a = .0;
    if (t==0) return b;  if ((t/=d/2)==2) return b+c;
    if (!a || a < ABS(c)) { a=c; s=p/4; }
    else s = p/(2*M_PI) * asin (c/a);
    if (t < 1) {
        t-=1;
        return -.5*(a*pow(2,10*t) * sin( (t*d-s)*(2*M_PI)/p )) + b;
    }
    t-=1;
    return a*pow(2,-10*t) * sin( (t*d-s)*(2*M_PI)/p )*.5 + c + b;
}

CGFloat PRTweenTimingFunctionExpoOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    return (t==d) ? b+c : c * (-pow(2, -10 * t/d) + 1) + b;
}

CGFloat PRTweenTimingFunctionExpoIn (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    return (t==0) ? b : c * pow(2, 10 * (t/d - 1)) + b;
}

CGFloat PRTweenTimingFunctionExpoInOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    if (t==0) return b;
    if (t==d) return b+c;
    if ((t/=d/2) < 1) return c/2 * pow(2, 10 * (t - 1)) + b;
    return c/2 * (-pow(2, -10 * --t) + 2) + b;
}

CGFloat PRTweenTimingFunctionQuadOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    t/=d;
    return -c *t*(t-2) + b;
}

CGFloat PRTweenTimingFunctionQuadIn (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    t/=d;
    return c*t*t + b;
}

CGFloat PRTweenTimingFunctionQuadInOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    if ((t/=d/2) < 1) return c/2*t*t + b;
    t--;
    return -c/2 * (t*(t-2) - 1) + b;
}

CGFloat PRTweenTimingFunctionQuartOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    t=t/d-1;
    return -c * (t*t*t*t - 1) + b;
}

CGFloat PRTweenTimingFunctionQuartIn (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    t/=d;
    return c*t*t*t*t + b;
}

CGFloat PRTweenTimingFunctionQuartInOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    if ((t/=d/2) < 1) return c/2*t*t*t*t + b;
    t-=2;
    return -c/2 * (t*t*t*t - 2) + b;
}

CGFloat PRTweenTimingFunctionQuintOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    t=t/d-1;
	return c*(t*t*t*t*t + 1) + b;
}

CGFloat PRTweenTimingFunctionQuintIn (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    t/=d;
	return c*t*t*t*t*t + b;
}

CGFloat PRTweenTimingFunctionQuintInOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    if ((t/=d/2) < 1) return c/2*t*t*t*t*t + b;
    t-=2;
    return c/2*(t*t*t*t*t + 2) + b;
}

CGFloat PRTweenTimingFunctionSineOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    return c * sin(t/d * (M_PI/2)) + b;
}

CGFloat PRTweenTimingFunctionSineIn (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    return -c * cos(t/d * (M_PI/2)) + c + b;
}

CGFloat PRTweenTimingFunctionSineInOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    return -c/2 * (cos(M_PI*t/d) - 1) + b;
}

CGFloat PRTweenTimingFunctionCALinear       (CGFloat t, CGFloat b, CGFloat c, CGFloat d) { return 0; }
CGFloat PRTweenTimingFunctionCAEaseIn       (CGFloat t, CGFloat b, CGFloat c, CGFloat d) { return 0; }
CGFloat PRTweenTimingFunctionCAEaseOut      (CGFloat t, CGFloat b, CGFloat c, CGFloat d) { return 0; }
CGFloat PRTweenTimingFunctionCAEaseInOut    (CGFloat t, CGFloat b, CGFloat c, CGFloat d) { return 0; }
CGFloat PRTweenTimingFunctionCADefault      (CGFloat t, CGFloat b, CGFloat c, CGFloat d) { return 0; }

CGFloat PRTweenTimingFunctionUIViewLinear       (CGFloat t, CGFloat b, CGFloat c, CGFloat d) { return 0; }
CGFloat PRTweenTimingFunctionUIViewEaseIn       (CGFloat t, CGFloat b, CGFloat c, CGFloat d) { return 0; }
CGFloat PRTweenTimingFunctionUIViewEaseOut      (CGFloat t, CGFloat b, CGFloat c, CGFloat d) { return 0; }
CGFloat PRTweenTimingFunctionUIViewEaseInOut    (CGFloat t, CGFloat b, CGFloat c, CGFloat d) { return 0; }

CGFloat (*PRTweenTimingFunctionCACustom(CAMediaTimingFunction *timingFunction))(CGFloat, CGFloat, CGFloat, CGFloat) {
    return &PRTweenTimingFunctionLinear;
}
