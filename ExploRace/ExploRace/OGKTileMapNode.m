//
//  OGKTileMapNode.m
//  ExploRace
//
//  Created by David Samuelson on 1/30/14.
//  Copyright (c) 2014 OGK. All rights reserved.
//

#import "OGKTileMapNode.h"
#import "OGKTileMap.h"

@interface OGKTileMapNode ()

@property OGKTileMap *tileMap;

@property NSMutableDictionary *tileNodes;

@end

@implementation OGKTileMapNode

- (instancetype)initWithTileMap:(OGKTileMap *)tileMap
{
    if (self = [super init])
    {
        self.tileMap = tileMap;
        [self generateTiles];
    }
    return self;
}

- (void)generateTiles
{
    self.tileNodes = [[NSMutableDictionary alloc] initWithCapacity:self.tileMap.widthInTiles * self.tileMap.heightInTiles];
    
    for (int x=0; x < self.tileMap.widthInTiles; x++) {
        for (int y=0; y < self.tileMap.heightInTiles; y++) {
            OGKTile *tile = [self.tileMap getTileAtX:x Y:y];
            NSString *name = tile.name;
            if (tile.isEvil)
                name = [name stringByAppendingString:@"Evil"];
            else
                name = [name stringByAppendingString:@"Good"];
            SKSpriteNode *tileNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:name]];
            tileNode.position = CGPointMake(tileNode.frame.size.width * (x + 0.5), tileNode.frame.size.height * (y + 0.5));
            [self addChild:tileNode];
            
            // Add tileNode to Dictionay
            [self.tileNodes setObject:tileNode forKey:[NSString stringWithFormat:@"X%dY%d", x, y]];
        }
    }
}

- (SKSpriteNode *)getTileNodeAtX:(int)x Y:(int)y
{
    if ([self.tileMap checkTileExistAtX:x Y:y])
    {
        NSString *key = [NSString stringWithFormat:@"X%dY%d", x, y];
        return self.tileNodes[key];
    }
    else
        return nil;
}

@end
