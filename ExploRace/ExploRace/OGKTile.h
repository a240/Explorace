//
//  OGKTile.h
//  ExploRace
//
//  Created by David Samuelson on 1/30/14.
//  Copyright (c) 2014 OGK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OGKTile : NSObject

@property (readonly) int x;
@property (readonly) int y;
@property NSString *name;
@property BOOL isEvil;
@property BOOL hasFogOfWar;

- (instancetype)initWithName:(NSString *)name X:(int)x Y:(int)y;

@end
