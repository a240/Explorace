//
//  OGKTileMapNode.h
//  ExploRace
//
//  Created by David Samuelson on 1/30/14.
//  Copyright (c) 2014 OGK. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "OGKtileMap.h"

@interface OGKTileMapNode : SKNode

- (instancetype)initWithTileMap:(OGKTileMap *)tileMap;
- (SKSpriteNode *)getTileNodeAtX:(int)x Y:(int)y;

@end
