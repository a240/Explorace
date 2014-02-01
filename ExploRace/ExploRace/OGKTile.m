//
//  OGKTile.m
//  ExploRace
//
//  Created by David Samuelson on 1/30/14.
//  Copyright (c) 2014 OGK. All rights reserved.
//

#import "OGKTile.h"

@implementation OGKTile

- (instancetype)initWithName:(NSString *)name X:(int)x Y:(int)y
{
    if (self = [super init]) {
        self.name = name;
        self.isEvil = true;
        _x = x;
        _y = y;
    }
    return self;
}

@end
