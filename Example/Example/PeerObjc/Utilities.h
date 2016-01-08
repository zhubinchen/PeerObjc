//
//  Utilities.h
//  QinXin
//
//  Created by zhubch on 15-3-12.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#ifndef Peer_Utilities_h
#define Peer_Utilities_h

#define weak(x) ({__weak typeof(x) __x = (x);__x;})

static inline NSString* randString(NSInteger maxLength)
{
    NSInteger length = (random() % (maxLength - maxLength + 1)) + maxLength;
    unichar letter[length];
    
    for (int i = 0; i < length; i++) {
        letter[i] = (random() % (90 - 65 + 1)) + 65;
    }
    
    return [[[NSString alloc] initWithCharacters:letter length:length] lowercaseString];
}

#endif
