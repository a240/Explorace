//
//  OGKRect.m
//  ExploRace
//
//  Created by David Samuelson on 2/1/14.
//  Copyright (c) 2014 OGK. All rights reserved.
//

#import "OGKRect.h"

@implementation OGKRect

- (instancetype)initWithX:(float)x Y:(float)y Width:(float)width Height:(float)height
{
    if (self = [super init])
    {
        self.x = x;
        self.y = y;
        self.width = width;
        self.height = height;
    }
    return self;
}

@end
