//
//  OGKMapScene.m
//  ExploRace
//
//  Created by David Samuelson on 1/30/14.
//  Copyright (c) 2014 OGK. All rights reserved.
//

#import "OGKMapScene.h"
#import "OGKTileMap.h"
#import "OGKTileMapNode.h"
#import "OGKPlayer.h"
#import "OGKTimerUINode.h"

#define TIME_TO_MOVE 0.2
#define DEFAULT_FOG_WAR_REMOVAL_RADIUS 0

@interface OGKMapScene ()

typedef NS_ENUM(NSUInteger, StateType) {
    StateTypeMoving,
    StateTypeReadyToMove
};

@property OGKTileMap *tileMap;
@property OGKTileMapNode *tileMapNode;
@property OGKTile *currentTile;
@property OGKPlayer *player;
@property StateType currentState;

@end

@implementation OGKMapScene

- (void)update:(NSTimeInterval)currentTime
{
    [super update:currentTime];
    
}

- (void)didSimulatePhysics
{
    [super didSimulatePhysics];
}

- (void)createContent
{
    [super createContent];
    
    // Movement Gestures
    UISwipeGestureRecognizer *swipeLeftDirectionGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipLeftDirection:)];
    [self.view addGestureRecognizer:swipeLeftDirectionGestureRecognizer];
    [swipeLeftDirectionGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    
    UISwipeGestureRecognizer *swipeRightDirectionGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipRightDirection:)];
    [self.view addGestureRecognizer:swipeRightDirectionGestureRecognizer];
    [swipeRightDirectionGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    
    UISwipeGestureRecognizer *swipeUpDirectionGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipUpDirection:)];
    [self.view addGestureRecognizer:swipeUpDirectionGestureRecognizer];
    [swipeUpDirectionGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    
    UISwipeGestureRecognizer *swipeDownDirectionGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipDownDirection:)];
    [self.view addGestureRecognizer:swipeDownDirectionGestureRecognizer];
    [swipeDownDirectionGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    
    // Tile map
    self.tileMap = [self generateTileMapWithWidth:6 AndHeight:6];
    self.tileMapNode = [[OGKTileMapNode alloc] initWithTileMap:self.tileMap];
    [self.world addChild:self.tileMapNode];
    
    // Player
    self.player = [[OGKPlayer alloc] initWithColor:[UIColor magentaColor] size:CGSizeMake(40, 60)];
    [self.world addChild:self.player];
    [self cameraFollowNode:self.player];
    
    // Create Spawn Tile
    self.currentTile = [self.tileMap getTileAtX:0 Y:0];
    SKSpriteNode *currentTileNode = [self.tileMapNode getTileNodeAtX:self.currentTile.x Y:self.currentTile.y];
    self.player.position = currentTileNode.position;
    
    [self setCameraBoundsToWorld];
    
    self.currentState = StateTypeReadyToMove;
}



- (void)removeFogOfWarFromTileAtX:(int)tileX Y:(int)tileY Radius:(int)radius
{
    if (radius == 0)
    {
        [self.tileMap getTileAtX:tileX Y:tileY].hasFogOfWar = NO;
        return;
    }
    
    for (int x = tileX - radius; x < tileX + radius; x++) {
        for (int y = tileY - radius; y < tileY + radius; y++) {
            if ([self.tileMap checkTileExistAtX:x Y:y])
            {
                [self.tileMap getTileAtX:x Y:y].hasFogOfWar = NO;
            }
        }
    }
}

- (OGKTileMap *)generateTileMapWithWidth:(int)width AndHeight:(int)height
{
    // @TODO make real generation
    NSString *string = @"";
    int count = width * height;
    for (int i = 0; i < count; i++) {
        string = [string stringByAppendingString:@"tile"];
        if (i + 1 != count)
            string = [string stringByAppendingString:@","];
    }
    
    OGKTileMap *tileMap = [[OGKTileMap alloc] initWithString:string WithWidth:width];
    return tileMap;
}

- (void)swipLeftDirection:(UISwipeGestureRecognizer *)recognizer
{
    OGKTile *targetTile = [self.tileMap getTileAtX:self.currentTile.x - 1 Y:self.currentTile.y];
    if (targetTile == nil) return; // UI Stuff to alert play that they can not move in this direction
    
    [self movePlayerToTile:targetTile];
}

- (void)swipRightDirection:(UISwipeGestureRecognizer *)recognizer
{
    OGKTile *targetTile = [self.tileMap getTileAtX:self.currentTile.x + 1 Y:self.currentTile.y];
    if (targetTile == nil) return; // UI Stuff to alert play that they can not move in this direction
    
    [self movePlayerToTile:targetTile];
}

- (void)swipUpDirection:(UISwipeGestureRecognizer *)recognizer
{
    OGKTile *targetTile = [self.tileMap getTileAtX:self.currentTile.x Y:self.currentTile.y + 1];
    if (targetTile == nil) return; // UI Stuff to alert play that they can not move in this direction
    
    [self movePlayerToTile:targetTile];
}

- (void)swipDownDirection:(UISwipeGestureRecognizer *)recognizer
{
    OGKTile *targetTile = [self.tileMap getTileAtX:self.currentTile.x Y:self.currentTile.y - 1];
    if (targetTile == nil) return; // UI Stuff to alert play that they can not move in this direction
    
    [self movePlayerToTile:targetTile];
}

- (void)movePlayerToTile:(OGKTile *)tile
{
    if (self.currentState != StateTypeReadyToMove) return;
    
    self.currentState = StateTypeMoving;
    
    // Remove the fog of war in target tile
    [self removeFogOfWarFromTileAtX:tile.x Y:tile.y Radius:DEFAULT_FOG_WAR_REMOVAL_RADIUS];
    
    // Move player to tile
    SKSpriteNode *targetTileNode = [self.tileMapNode getTileNodeAtX:tile.x
                                                                  Y:tile.y];
    SKAction *movePlayer = [SKAction moveTo:targetTileNode.position duration:TIME_TO_MOVE];
    
    [self.player runAction:movePlayer completion:^{
        self.currentState = StateTypeReadyToMove;
        self.currentTile = tile;
        // [self playMiniGame];
    }];
    
}

- (void)playMiniGame
{
    NSArray *miniGameScenes = @[NSClassFromString(@"OGKQuickTapScene")];
    uint32_t rand = arc4random_uniform((uint32_t) [miniGameScenes count]);
    Class sceneClass = [miniGameScenes objectAtIndex:rand];
    SKScene *miniGameScene = [[sceneClass alloc] initWithSize:self.size];
    SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
    [self.view presentScene:miniGameScene transition:doors];
}

@end
