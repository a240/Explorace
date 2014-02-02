//
//  OGKTileMap.h
//  ExploRace
//
//  Created by David Samuelson on 1/30/14.
//  Copyright (c) 2014 OGK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGKTile.h"

@interface OGKTileMap : NSObject

@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) unsigned long widthInTiles;
@property (nonatomic, readonly) unsigned long heightInTiles;

- (instancetype)initWithString:(NSString *)string WithWidth:(int)width;
- (instancetype)initWithArray:(NSArray *)array WithWidth:(int)width;
- (OGKTile *)getTileAtX:(int)x Y:(int)y;
- (NSArray *)getTilesWithName:(NSString *)name;
- (BOOL)checkTileExistAtX:(int)x Y:(int)y;

@end
