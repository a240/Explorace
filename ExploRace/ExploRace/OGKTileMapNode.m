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
@property NSMutableDictionary *evilCloudTileNodes;

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
    self.evilCloudTileNodes = [[NSMutableDictionary alloc] initWithCapacity:self.tileMap.widthInTiles * self.tileMap.heightInTiles];
    
    for (int x=0; x < self.tileMap.widthInTiles; x++) {
        for (int y=0; y < self.tileMap.heightInTiles; y++) {
            OGKTile *tile = [self.tileMap getTileAtX:x Y:y];
            NSString *name = tile.name;
            
            SKSpriteNode *tileNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:name]];
            CGPoint tilePositionPoint = CGPointMake(tileNode.frame.size.width * (x + 0.5), tileNode.frame.size.height * (y + 0.5));
            tileNode.position = tilePositionPoint;
            [self addChild:tileNode];
            
            // Add tileNode to Dictionay
            [self.tileNodes setObject:tileNode forKey:[NSString stringWithFormat:@"X%dY%d", x, y]];
            
            if (tile.isEvil) {
                SKSpriteNode *evilCloudNode = [SKSpriteNode spriteNodeWithImageNamed:@"EvilCloudTile"];
                [self.evilCloudTileNodes setObject:evilCloudNode forKey:[NSString stringWithFormat:@"X%dY%d", x, y]];
                evilCloudNode.position = tilePositionPoint;
                [self addChild:evilCloudNode];
                float randomScaleValue = (arc4random() % 11) * 0.01 + 0.9;
                float randomTime = (arc4random() % 11) * 0.1;
                SKAction *randomScale = [SKAction scaleTo:randomScaleValue duration:randomTime];
                SKAction *scaleDown = [SKAction scaleTo:0.9 duration:1];
                SKAction *scaleUp = [SKAction scaleTo:1 duration:1];
                SKAction *pulseScale = [SKAction sequence:@[scaleDown, scaleUp]];
                SKAction *pulseForever = [SKAction repeatActionForever:pulseScale];
                SKAction *randomScaleThenPulseForever = [SKAction sequence:@[randomScale, pulseForever]];
                [evilCloudNode runAction:randomScaleThenPulseForever];
            }
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
