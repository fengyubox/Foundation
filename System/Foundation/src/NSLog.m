/*
 *  NSLog.m
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

#import <Foundation/NSObjCRuntime.h>
#import <Foundation/NSInternal.h>
#import <Foundation/NSException.h>
#include <sys/time.h>

typedef void (*CFLogFunc)(int32_t lev, const char *message, size_t length, char withBanner);

CF_EXPORT void _CFLogvEx(CFLogFunc logit, CFStringRef (*copyDescFunc)(void *, const void *), CFDictionaryRef formatOptions, int32_t lev, CFStringRef format, va_list args);

static void __NSLogCString(int32_t lev, const char *message, size_t length, char withBanner)
{
    int millis = 0;
    time_t now;
    struct tm *timeinfo;
    char dateFormat[80];
    const char *processName = "hoge";//getprogname();

    pid_t pid = getpid();
    uid_t uid = getuid();
    bzero(dateFormat, 80);

    time(&now);
    timeinfo = localtime(&now);
    struct timeval tod;
    gettimeofday(&tod, NULL);
    millis = (1000 * tod.tv_usec / USEC_PER_SEC);
    strftime(dateFormat, 80, "%Y-%m-%d %T", timeinfo);

    if (message[length - 1] == '\n')
    {
        printf("%s.%03d %s[%d:%x] %.*s", dateFormat, millis, processName, pid, uid, (int)length, message);
    }
    else
    {
        printf("%s.%03d %s[%d:%x] %.*s\n", dateFormat, millis, processName, pid, uid, (int)length, message);
    }

}

void NSLogv(NSString *fmt, va_list args)
{
//    @autoreleasepool {
        _CFLogvEx(&__NSLogCString, &_NSCFCopyDescription2, nil, 4, (CFStringRef)fmt, args);
//    }
}

void NSLog(NSString *fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    NSLogv(fmt, args);
    va_end(args);
}

extern const char *_NSPrintForDebugger(id object);
const char *_NSPrintForDebugger(id object)
{
    NSString *str = nil;
    @try {
        str = [object debugDescription];
    } @catch (NSException *e) {
        NSLog(@"%@", e);
    }
    return [str UTF8String];
}
