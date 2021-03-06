/*
 *  NSTimer.m
 *  Foundation
 *
 *  Copyright (c) 2014 Apportable. All rights reserved.
 *  Copyright (c) 2014- Tombo Inc.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License, version 2.1.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301  USA
 */

#import <Foundation/NSTimer.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSObjectInternal.h>
#import <dispatch/dispatch.h>
#import <objc/runtime.h>
#import "NSTimerInternal.h"

@implementation NSTimer {
    id _target;
    SEL _sel;
    dispatch_source_t _source;
}

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)yesOrNo
{
    [invocation retainArguments];
    return [[[self alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:ti] interval:ti target:invocation selector:@selector(invoke) userInfo:nil repeats:yesOrNo] autorelease];
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)yesOrNo
{
    [invocation retainArguments];
    NSTimer *timer = [[self alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:ti] interval:ti target:invocation selector:@selector(invoke) userInfo:nil repeats:yesOrNo];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    return [timer autorelease];
}

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)sel userInfo:(id)userInfo repeats:(BOOL)yesOrNo
{
    return [[[self alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:ti] interval:ti target:aTarget selector:sel userInfo:userInfo repeats:yesOrNo] autorelease];
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)sel userInfo:(id)userInfo repeats:(BOOL)yesOrNo
{
    NSTimer *timer = [[self alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:ti] interval:ti target:aTarget selector:sel userInfo:userInfo repeats:yesOrNo];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    return [timer autorelease];
}

- (id)initWithFireDate:(NSDate *)date interval:(NSTimeInterval)ti target:(id)t selector:(SEL)s userInfo:(id)ui repeats:(BOOL)rep
{
    _timeInterval = rep ? ti : 0.0;
    _fireDate = date;
    _valid = YES;
    _target = [t retain];
    _sel = s;
    _userInfo = [ui retain];

    return self;
}

- (void)fire
{
    [_target performSelector:_sel withObject:self];
    if(_timeInterval == 0.0) {
        dispatch_source_cancel(self.source);
        [self release];
    }
}

- (void)invalidate
{
    _valid = NO;
    dispatch_suspend(self.source);
    [self release];
}

- (void)dealloc
{
    [_target release];
    [_userInfo release];
    [super dealloc];
}
@end

@implementation NSTimer (Private)
- (void)setSource:(dispatch_source_t)source
{
    _source = source;
}

- (dispatch_source_t)source
{
    return _source;
}
@end
