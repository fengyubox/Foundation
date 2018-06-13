/*
 * Copyright (c) 2014- Tombo Inc.
 *
 * This source code is a modified version of the objc4 sources released by Apple Inc. under
 * the terms of the APSL version 2.0 (see below).
 *
 */

/*
 * Copyright (c) 2013 Apple Inc. All rights reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPLE_LICENSE_HEADER_END@
 */

/*	CFUniCharPriv.h
	Copyright (c) 1998-2013, Apple Inc. All rights reserved.
*/

#if !defined(__COREFOUNDATION_CFUNICHARPRIV__)
#define __COREFOUNDATION_CFUNICHARPRIV__ 1

#include <CoreFoundation/CFBase.h>
#include <CoreFoundation/CFUniChar.h>

#define kCFUniCharRecursiveDecompositionFlag	(1UL << 30)
#define kCFUniCharNonBmpFlag			(1UL << 31)
#define CFUniCharConvertCountToFlag(count)	((count & 0x1F) << 24)
#define CFUniCharConvertFlagToCount(flag)	((flag >> 24) & 0x1F)

enum {
    kCFUniCharCanonicalDecompMapping = (kCFUniCharCaseFold + 1),
    kCFUniCharCanonicalPrecompMapping,
    kCFUniCharCompatibilityDecompMapping
};

CF_EXPORT const void *CFUniCharGetMappingData(uint32_t type);

#endif /* ! __COREFOUNDATION_CFUNICHARPRIV__ */

