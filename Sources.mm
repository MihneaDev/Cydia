/* Cydia - iPhone UIKit Front-End for Debian APT
 * Copyright (C) 2008-2013  Jay Freeman (saurik)
 * Copyright (C) 2021 Mihnea Coman (mihneadev)
*/

/* GNU General Public License, Version 3 {{{ */
/*
 * Cydia is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published
 * by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * Cydia is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Cydia.  If not, see <http://www.gnu.org/licenses/>.
**/
/* }}} */

#include "CyteKit/UCPlatform.h"

#include <Foundation/Foundation.h>
#include <Menes/ObjectHandle.h>

#include <cstdio>

#include "Sources.h"

extern _H<NSMutableDictionary> Sources_;

void CydiaWriteSources() {
    unlink(SOURCES_LIST);
    FILE *file(fopen(SOURCES_LIST, "w"));
    _assert(file != NULL);

    if (kCFCoreFoundationVersionNumber >= 1443) {
        fprintf(file, "deb https://apt.elucubratus.com ./\n");
    } else {
        fprintf(file, "deb http://apt.saurik.com/ ios/%.2f main\n", kCFCoreFoundationVersionNumber);
        fprintf(file, "deb https://diatr.us/apt/ ./\n");
    }

    for (NSString *key in [Sources_ allKeys]) {
        if ([key hasPrefix:@"deb:http:"] && [Sources_ objectForKey:[NSString stringWithFormat:@"deb:https:%s", [key UTF8String] + 9]])
            continue;

        NSDictionary *source([Sources_ objectForKey:key]);
        // Ignore it if main source is added again
        if ([[source objectForKey:@"URI"] hasPrefix:@"http://apt.elucubratus.com"] || [[source objectForKey:@"URI"] hasPrefix:@"https://apt.elucubratus.com"])
            continue;

        // Don't add Electra sources
        if ([[source objectForKey:@"URI"] rangeOfString:@"electra" options:NSCaseInsensitiveSearch].location != NSNotFound)
            continue;
        
        // no procursus 4 you
        if ([[source objectForKey:@"URI"] rangeOfString:@"procurs" options:NSCaseInsensitiveSearch].location != NSNotFound)
            continue;

        NSArray *sections([source objectForKey:@"Sections"] ?: [NSArray array]);

        fprintf(file, "%s %s %s%s%s\n",
            [[source objectForKey:@"Type"] UTF8String],
            [[source objectForKey:@"URI"] UTF8String],
            [[source objectForKey:@"Distribution"] UTF8String],
            [sections count] == 0 ? "" : " ",
            [[sections componentsJoinedByString:@" "] UTF8String]
        );
    }

    fclose(file);
}

void CydiaAddSource(NSDictionary *source) {
    // Ignore it if main source is added again
    if ([[source objectForKey:@"URI"] hasPrefix:@"http://apt.elucubratus.com"] || [[source objectForKey:@"URI"] hasPrefix:@"https://apt.elucubratus.com"])
        return;

    // Don't add Electra sources
    if ([[source objectForKey:@"URI"] rangeOfString:@"electra" options:NSCaseInsensitiveSearch].location != NSNotFound)
        return;
    
    // no procursus 4 you
    if ([[source objectForKey:@"URI"] rangeOfString:@"procurs" options:NSCaseInsensitiveSearch].location != NSNotFound)
        return;

    [Sources_ setObject:source forKey:[NSString stringWithFormat:@"%@:%@:%@", [source objectForKey:@"Type"], [source objectForKey:@"URI"], [source objectForKey:@"Distribution"]]];
}

void CydiaAddSource(NSString *href, NSString *distribution, NSArray *sections) {
    if (href == nil || distribution == nil)
        return;

    CydiaAddSource([NSMutableDictionary dictionaryWithObjectsAndKeys:
        @"deb", @"Type",
        href, @"URI",
        distribution, @"Distribution",
        sections ?: [NSMutableArray array], @"Sections",
    nil]);
}
