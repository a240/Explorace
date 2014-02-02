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
#import "OGKMiniGameScene.h"

#define TIME_TO_MOVE 0.2

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

@property UISwipeGestureRecognizer *swipeLeftDirectionGestureRecognizer;
@property UISwipeGestureRecognizer *swipeRightDirectionGestureRecognizer;
@property UISwipeGestureRecognizer *swipeDownDirectionGestureRecognizer;
@property UISwipeGestureRecognizer *swipeUpDirectionGestureRecognizer;

@end

@implementation OGKMapScene

- (void)update:(NSTimeInterval)currentTime
{
    [super update:currentTime];
    
}

- (void)didMoveToView:(SKView *)view
{
    [super didMoveToView:view];
    
    [self addSwipGestures];
}

- (void)willMoveFromView:(SKView *)view
{
    [super willMoveFromView:view];
    [self.view removeGestureRecognizer:self.swipeLeftDirectionGestureRecognizer];
    [self.view removeGestureRecognizer:self.swipeRightDirectionGestureRecognizer];
    [self.view removeGestureRecognizer:self.swipeUpDirectionGestureRecognizer];
    [self.view removeGestureRecognizer:self.swipeDownDirectionGestureRecognizer];
}

- (void)didSimulatePhysics
{
    [super didSimulatePhysics];
}

- (void)createContent
{
    [super createContent];
    
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

- (void)addSwipGestures
{
    // Movement Gestures
    self.swipeLeftDirectionGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipLeftDirection:)];
    [self.swipeLeftDirectionGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:self.swipeLeftDirectionGestureRecognizer];
    
    self.swipeRightDirectionGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipRightDirection:)];
    [self.view addGestureRecognizer:self.swipeRightDirectionGestureRecognizer];
    [self.swipeRightDirectionGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    
    self.swipeUpDirectionGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipUpDirection:)];
    [self.view addGestureRecognizer:self.swipeUpDirectionGestureRecognizer];
    [self.swipeUpDirectionGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    
    self.swipeDownDirectionGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipDownDirection:)];
    [self.view addGestureRecognizer:self.swipeDownDirectionGestureRecognizer];
    [self.swipeDownDirectionGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
}

- (void)removeEvilCloudFromTileAtX:(int)tileX Y:(int)tileY Radius:(int)radius
{
    SKAction *fadeRemove = [SKAction sequence:@[[SKAction fadeAlphaTo:0 duration:0.3], [SKAction removeFromParent]]];
    if (radius == 0)
    {
        [[self.tileMapNode getEvilCloudAtX:tileX Y:tileY] runAction:fadeRemove];
        [self.tileMap getTileAtX:tileX Y:tileY].isEvil = NO;
        return;
    }
    
    for (int x = tileX - radius; x < tileX + radius; x++) {
        for (int y = tileY - radius; y < tileY + radius; y++) {
            if ([self.tileMap checkTileExistAtX:x Y:y])
            {
                [[self.tileMapNode getEvilCloudAtX:tileX Y:tileY] runAction:fadeRemove];
                [self.tileMap getTileAtX:x Y:y].isEvil = NO;
            }
        }
    }
}

- (OGKTileMap *)generateTileMapWithWidth:(int)width AndHeight:(int)height
{
    // @TODO make real generation
    int count = width * height;
    NSArray *tilePool = @[@"BlankTile", @"LakeTile", @"MountainTile", @"SwampTile", @"ValleyTile"];
    NSMutableArray *tilesStringArray = [[NSMutableArray alloc] initWithCapacity:count];
    for (int i = 0; i < count; i++)
    {
        NSString *tileName = tilePool[arc4random() % [tilePool count]];
        [tilesStringArray addObject:tileName];
    }
    
    int spawnIndex = arc4random() % count;
    
    [tilesStringArray replaceObjectAtIndex:spawnIndex withObject:@"CrystalTile"];
    
    OGKTileMap *tileMap = [[OGKTileMap alloc] initWithArray:tilesStringArray WithWidth:width];
    
    //
    for (OGKTile *tile in [tileMap getTilesWithName:@"CrystalTile"])
    {
        tile.isGoal = YES;
        tile.isEvil = NO;
    }
    
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
    
    // Move player to tile
    SKSpriteNode *targetTileNode = [self.tileMapNode getTileNodeAtX:tile.x
                                                                  Y:tile.y];
    SKAction *movePlayer = [SKAction moveTo:targetTileNode.position duration:TIME_TO_MOVE];
    
    [self.player runAction:movePlayer completion:^{
        self.currentState = StateTypeReadyToMove;
        self.currentTile = tile;
        if (self.currentTile.isGoal)
        {
            NSLog(@"YOU WIN");
        }
        if (self.currentTile.isEvil)
        {
            [self removeEvilCloudFromTileAtX:tile.x Y:tile.y Radius:0];
            [self runAction:[SKAction sequence:@[[SKAction waitForDuration:1], [SKAction runBlock:^{
                [self playMiniGame];
            }]]]];
        }
    }];
    
}

- (void)playMiniGame
{
    NSArray *miniGameScenes = @[NSClassFromString(@"OGKFishCollectScene")];
    
    uint32_t rand = arc4random_uniform((uint32_t) [miniGameScenes count]);
    Class sceneClass = [miniGameScenes objectAtIndex:rand];
    OGKMiniGameScene *miniGameScene = [[sceneClass alloc] initWithSize:self.size ReturnScene:self];
    
    SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
    [self.view presentScene:miniGameScene transition:doors];
}

@end
