#import <Foundation/Foundation.h>

#import "PRTweenTimingFunctions.h"

typedef CGFloat(*PRTweenTimingFunction)(CGFloat, CGFloat, CGFloat, CGFloat);

#if NS_BLOCKS_AVAILABLE
@class PRTweenPeriod;

typedef void (^PRTweenUpdateBlock)(PRTweenPeriod *period);

typedef void       (^PRTweenCompleteBlock)();

#endif

enum {
    PRTweenHasTweenedValueObserver = 1 << 0,
    PRTweenHasTweenedLerpObserver  = 1 << 1,
};
typedef NSUInteger PRTweenHasTweenedObserverOptions;

@interface PRTweenPeriod : NSObject {
    CGFloat duration;
    CGFloat delay;
    CGFloat startOffset;
    CGFloat startValue;
    CGFloat endValue;
    CGFloat tweenedValue;
}

@property(nonatomic) CGFloat startValue;
@property(nonatomic) CGFloat endValue;
@property(nonatomic) CGFloat tweenedValue;
@property(nonatomic) CGFloat duration;
@property(nonatomic) CGFloat delay;
@property(nonatomic) CGFloat startOffset;

+ (id)periodWithStartValue:(CGFloat)aStartValue
                  endValue:(CGFloat)anEndValue
                  duration:(CGFloat)duration;

+ (id)periodWithStartValue:(CGFloat)aStartValue
                  endValue:(CGFloat)anEndValue
                  duration:(CGFloat)duration
                     delay:(CGFloat)delay;

@end

@protocol PRTweenLerpPeriod

- (NSValue *)tweenedValueForProgress:(CGFloat)progress;

- (void)setProgress:(CGFloat)progress;

@end

@interface PRTweenLerpPeriod : PRTweenPeriod {
    NSValue *startLerp;
    NSValue *endLerp;
    NSValue *tweenedLerp;
}

@property(nonatomic, copy) NSValue *startLerp;
@property(nonatomic, copy) NSValue *endLerp;
@property(nonatomic, copy) NSValue *tweenedLerp;

+ (id)periodWithStartValue:(NSValue *)aStartValue
                  endValue:(NSValue *)anEndValue
                  duration:(CGFloat)duration;

+ (id)periodWithStartValue:(NSValue *)aStartValue
                  endValue:(NSValue *)anEndValue
                  duration:(CGFloat)duration
                     delay:(CGFloat)delay;
@end

@interface PRTweenCGPointLerpPeriod : PRTweenLerpPeriod <PRTweenLerpPeriod>
+ (id)periodWithStartCGPoint:(CGPoint)aStartPoint
                  endCGPoint:(CGPoint)anEndPoint
                    duration:(CGFloat)duration;

- (CGPoint)startCGPoint;

- (CGPoint)tweenedCGPoint;

- (CGPoint)endCGPoint;
@end

@interface PRTweenCGRectLerpPeriod : PRTweenLerpPeriod <PRTweenLerpPeriod>
+ (id)periodWithStartCGRect:(CGRect)aStartRect
                  endCGRect:(CGRect)anEndRect
                   duration:(CGFloat)duration;

- (CGRect)startCGRect;

- (CGRect)tweenedCGRect;

- (CGRect)endCGRect;
@end

@interface PRTweenCGSizeLerpPeriod : PRTweenLerpPeriod <PRTweenLerpPeriod>
+ (id)periodWithStartCGSize:(CGSize)aStartSize
                  endCGSize:(CGSize)anEndSize
                   duration:(CGFloat)duration;

+ (id)periodWithStartCGSize:(CGSize)aStartSize
                  endCGSize:(CGSize)anEndSize
                   duration:(CGFloat)duration
                      delay:(CGFloat)delay;

- (CGSize)startCGSize;

- (CGSize)tweenedCGSize;

- (CGSize)endCGSize;
@end

@interface PRTweenOperation : NSObject {
    PRTweenPeriod *period;
    NSObject      *target;
    SEL                   updateSelector;
    SEL                   completeSelector;
    PRTweenTimingFunction timingFunction;

    CGFloat *boundRef;
    SEL boundGetter;
    SEL boundSetter;

    BOOL override;

    PRTweenHasTweenedObserverOptions observers;

#if NS_BLOCKS_AVAILABLE
    PRTweenUpdateBlock   updateBlock;
    PRTweenCompleteBlock completeBlock;
#endif

@private
    BOOL canUseBuiltAnimation;
}

@property(nonatomic, retain) PRTweenPeriod *period;
@property(nonatomic, retain) NSObject      *target;
@property(nonatomic) SEL                           updateSelector;
@property(nonatomic) SEL                           completeSelector;
@property(nonatomic, assign) PRTweenTimingFunction timingFunction;

#if NS_BLOCKS_AVAILABLE
@property(nonatomic, copy) PRTweenUpdateBlock   updateBlock;
@property(nonatomic, copy) PRTweenCompleteBlock completeBlock;
#endif

@property(nonatomic, assign) CGFloat *boundRef;
@property(nonatomic, retain) id boundObject;
@property(nonatomic) SEL        boundGetter;
@property(nonatomic) SEL        boundSetter;
@property(nonatomic) BOOL       override;

@property(nonatomic) PRTweenHasTweenedObserverOptions observers;

@end

@interface PRTweenCGPointLerp : NSObject
+ (PRTweenOperation *)lerp:(id)object
                  property:(NSString *)property
                      from:(CGPoint)from
                        to:(CGPoint)to
                  duration:(CGFloat)duration
            timingFunction:(PRTweenTimingFunction)timingFunction
                    target:(NSObject *)target
          completeSelector:(SEL)selector;

+ (PRTweenOperation *)lerp:(id)object
                  property:(NSString *)property
                      from:(CGPoint)from
                        to:(CGPoint)to
                  duration:(CGFloat)duration
                     delay:(CGFloat)delay
            timingFunction:(PRTweenTimingFunction)timingFunction
                    target:(NSObject *)target
          completeSelector:(SEL)selector;

+ (PRTweenOperation *)lerp:(id)object
                  property:(NSString *)property
                      from:(CGPoint)from
                        to:(CGPoint)to
                  duration:(CGFloat)duration;

#if NS_BLOCKS_AVAILABLE

+ (PRTweenOperation *)lerp:(id)object
                  property:(NSString *)property
                      from:(CGPoint)from
                        to:(CGPoint)to
                  duration:(CGFloat)duration
            timingFunction:(PRTweenTimingFunction)timingFunction
               updateBlock:(PRTweenUpdateBlock)updateBlock
             completeBlock:(PRTweenCompleteBlock)completeBlock;

+ (PRTweenOperation *)lerp:(id)object
                  property:(NSString *)property
                      from:(CGPoint)from
                        to:(CGPoint)to
                        duration:(CGFloat)duration
                     delay:(CGFloat)delay
            timingFunction:(PRTweenTimingFunction)timingFunction
               updateBlock:(PRTweenUpdateBlock)updateBlock
             completeBlock:(PRTweenCompleteBlock)completeBlock;

#endif
@end

@interface PRTweenCGRectLerp : NSObject
+ (PRTweenOperation *)lerp:(id)object
                  property:(NSString *)property
                      from:(CGRect)from
                        to:(CGRect)to
                  duration:(CGFloat)duration
            timingFunction:(PRTweenTimingFunction)timingFunction
                    target:(NSObject *)target
          completeSelector:(SEL)selector;

+ (PRTweenOperation *)lerp:(id)object
                  property:(NSString *)property
                      from:(CGRect)from
                        to:(CGRect)to
                  duration:(CGFloat)duration
                     delay:(CGFloat)delay
            timingFunction:(PRTweenTimingFunction)timingFunction
                    target:(NSObject *)target
          completeSelector:(SEL)selector;

+ (PRTweenOperation *)lerp:(id)object
                  property:(NSString *)property
                      from:(CGRect)from
                        to:(CGRect)to
                  duration:(CGFloat)duration;

#if NS_BLOCKS_AVAILABLE

+ (PRTweenOperation *)lerp:(id)object
                  property:(NSString *)property
                      from:(CGRect)from
                        to:(CGRect)to
                  duration:(CGFloat)duration
            timingFunction:(PRTweenTimingFunction)timingFunction
               updateBlock:(PRTweenUpdateBlock)updateBlock
             completeBlock:(PRTweenCompleteBlock)completeBlock;

+ (PRTweenOperation *)lerp:(id)object
                  property:(NSString *)property
                      from:(CGRect)from
                        to:(CGRect)to
                  duration:(CGFloat)duration
                     delay:(CGFloat)delay
            timingFunction:(PRTweenTimingFunction)timingFunction
               updateBlock:(PRTweenUpdateBlock)updateBlock
             completeBlock:(PRTweenCompleteBlock)completeBlock;

#endif
@end

@interface PRTweenCGSizeLerp : NSObject
+ (PRTweenOperation *)lerp:(id)object
                  property:(NSString *)property
                      from:(CGSize)from
                        to:(CGSize)to
                  duration:(CGFloat)duration
            timingFunction:(PRTweenTimingFunction)timingFunction
                    target:(NSObject *)target
          completeSelector:(SEL)selector;

+ (PRTweenOperation *)lerp:(id)object
                  property:(NSString *)property
                      from:(CGSize)from
                        to:(CGSize)to
                  duration:(CGFloat)duration
                     delay:(CGFloat)delay
            timingFunction:(PRTweenTimingFunction)timingFunction
                    target:(NSObject *)target completeSelector:(SEL)selector;

+ (PRTweenOperation *)lerp:(id)object
                  property:(NSString *)property
                      from:(CGSize)from
                        to:(CGSize)to
                  duration:(CGFloat)duration;

#if NS_BLOCKS_AVAILABLE

+ (PRTweenOperation *)lerp:(id)object
                  property:(NSString *)property
                      from:(CGSize)from
                        to:(CGSize)to
                  duration:(CGFloat)duration
            timingFunction:(PRTweenTimingFunction)timingFunction
               updateBlock:(PRTweenUpdateBlock)updateBlock
             completeBlock:(PRTweenCompleteBlock)completeBlock;

//+ (PRTweenOperation *)lerp:(id)object
//                  property:(NSString *)property
//                      from:(CGSize)from
//                        to:(CGSize)to
//                  duration:(CGFloat)duration
//                     delay:(CGFloat)delay
//            timingFunction:(PRTweenTimingFunction)timingFunction
//               updateBlock:(PRTweenUpdateBlock)updateBlock
//             completeBlock:(PRTweenCompleteBlock)completeBlock;

#endif
@end

@interface PRTween : NSObject {
    NSMutableArray *tweenOperations;
    NSMutableArray *expiredTweenOperations;
    NSTimer        *timer;
    CGFloat timeOffset;

    PRTweenTimingFunction defaultTimingFunction;
    BOOL                  useBuiltInAnimationsWhenPossible;
}

@property(nonatomic, readonly) CGFloat             timeOffset;
@property(nonatomic, assign) PRTweenTimingFunction defaultTimingFunction;
@property(nonatomic, assign) BOOL                  useBuiltInAnimationsWhenPossible;

+ (PRTween *)sharedInstance;

+ (PRTweenOperation *)tween:(id)object
                   property:(NSString *)property
                       from:(CGFloat)from
                         to:(CGFloat)to
                   duration:(CGFloat)duration
             timingFunction:(PRTweenTimingFunction)timingFunction
                     target:(NSObject *)target
           completeSelector:(SEL)selector;

+ (PRTweenOperation *)tween:(CGFloat *)ref
                       from:(CGFloat)from
                         to:(CGFloat)to
                   duration:(CGFloat)duration
             timingFunction:(PRTweenTimingFunction)timingFunction
                     target:(NSObject *)target
           completeSelector:(SEL)selector;

+ (PRTweenOperation *)tween:(CGFloat *)ref
                       from:(CGFloat)from
                         to:(CGFloat)to
                   duration:(CGFloat)duration
                      delay:(CGFloat)delay
             timingFunction:(PRTweenTimingFunction)timingFunction
                     target:(NSObject *)target
           completeSelector:(SEL)selector;

+ (PRTweenOperation *)tween:(id)object
                   property:(NSString *)property
                       from:(CGFloat)from
                         to:(CGFloat)to
                   duration:(CGFloat)duration;

+ (PRTweenOperation *)tween:(CGFloat *)ref
                       from:(CGFloat)from
                         to:(CGFloat)to
                   duration:(CGFloat)duration;

+ (PRTweenOperation *)lerp:(id)object
                  property:(NSString *)property
                    period:(PRTweenLerpPeriod <PRTweenLerpPeriod> *)period
            timingFunction:(PRTweenTimingFunction)timingFunction
                    target:(NSObject *)target
          completeSelector:(SEL)selector;

- (PRTweenOperation *)addTweenOperation:(PRTweenOperation *)operation;

- (PRTweenOperation *)addTweenPeriod:(PRTweenPeriod *)period
                              target:(NSObject *)target
                            selector:(SEL)selector;

- (PRTweenOperation *)addTweenPeriod:(PRTweenPeriod *)period
                              target:(NSObject *)target
                            selector:(SEL)selector
                      timingFunction:(PRTweenTimingFunction)timingFunction;

- (void)removeTweenOperation:(PRTweenOperation *)tweenOperation;

- (void)removeAllTweenOperations;

#if NS_BLOCKS_AVAILABLE

+ (PRTweenOperation *)tween:(id)object
                   property:(NSString *)property
                       from:(CGFloat)from
                         to:(CGFloat)to
                   duration:(CGFloat)duration
             timingFunction:(PRTweenTimingFunction)timingFunction
                updateBlock:(PRTweenUpdateBlock)updateBlock
              completeBlock:(PRTweenCompleteBlock)completeBlock;

+ (PRTweenOperation *)tween:(id)object
                   property:(NSString *)property
                       from:(CGFloat)from
                         to:(CGFloat)to
                   duration:(CGFloat)duration
                      delay:(CGFloat)delay
             timingFunction:(PRTweenTimingFunction)timingFunction
                updateBlock:(PRTweenUpdateBlock)updateBlock
              completeBlock:(PRTweenCompleteBlock)completeBlock;

+ (PRTweenOperation *)tween:(CGFloat *)ref
                       from:(CGFloat)from to:(CGFloat)to
                   duration:(CGFloat)duration
             timingFunction:(PRTweenTimingFunction)timingFunction
                updateBlock:(PRTweenUpdateBlock)updateBlock
              completeBlock:(PRTweenCompleteBlock)completeBlock;

+ (PRTweenOperation *)tween:(CGFloat *)ref
                       from:(CGFloat)from
                         to:(CGFloat)to
                   duration:(CGFloat)duration
                      delay:(CGFloat)delay
             timingFunction:(PRTweenTimingFunction)timingFunction
                updateBlock:(PRTweenUpdateBlock)updateBlock
              completeBlock:(PRTweenCompleteBlock)completeBlock;

+ (PRTweenOperation *)lerp:(id)object
                  property:(NSString *)property
                    period:(PRTweenLerpPeriod <PRTweenLerpPeriod> *)period
            timingFunction:(PRTweenTimingFunction)timingFunction
               updateBlock:(PRTweenUpdateBlock)updateBlock
             completeBlock:(PRTweenCompleteBlock)completeBlock;

- (PRTweenOperation *)addTweenPeriod:(PRTweenPeriod *)period
                         updateBlock:(PRTweenUpdateBlock)updateBlock
                     completionBlock:(PRTweenCompleteBlock)completeBlock;

- (PRTweenOperation *)addTweenPeriod:(PRTweenPeriod *)period
                         updateBlock:(PRTweenUpdateBlock)updateBlock
                     completionBlock:(PRTweenCompleteBlock)completionBlock
                      timingFunction:(PRTweenTimingFunction)timingFunction;

#endif

@end
