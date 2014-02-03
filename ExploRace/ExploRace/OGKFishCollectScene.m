//
//  OGKFishCollectScene.m
//  ExploRace
//
//  Created by David Samuelson on 2/2/14.
//  Copyright (c) 2014 OGK. All rights reserved.
//

#import "OGKFishCollectScene.h"
#define DEFAULT_FISH_TO_COLLECT 3

static const uint32_t fishCategory = 0x1 << 0;
static const uint32_t barrelCategory = 0x1 << 1;

@interface OGKFishCollectScene () <SKPhysicsContactDelegate>

@property SKNode *fishCollection;
@property int amountOfFishToCollect;
@property SKLabelNode *amountToCollectLabel;
@property SKSpriteNode *currentFishHeld;
@property SKSpriteNode *barrelCollectionNode;
@property SKNode *fishSpawner;

@end

@implementation OGKFishCollectScene

- (void)createContent
{
    [super createContent];
    
    // Set up physics world
    self.physicsWorld.contactDelegate = self;
    self.physicsWorld.gravity = CGVectorMake(0, -5);
    
    // Determine the amount of fish to collect
    self.amountOfFishToCollect = DEFAULT_FISH_TO_COLLECT;
    
    
    // Set up scene
    [self addBackgroundImageFromName:@"BoatBackgroundBad"];
    [self createWaves];
    // Boat
    SKSpriteNode *boat = [[SKSpriteNode alloc] initWithImageNamed:@"Boat"];
    boat.anchorPoint = CGPointZero;
    [self.uiLayer addChild:boat];
    
    // Amount To Collect UI
    self.amountToCollectLabel = [[SKLabelNode alloc] initWithFontNamed:@"AvenirNext-HeavyItalic"];
    self.amountToCollectLabel.text = [NSNumber numberWithInteger:self.amountOfFishToCollect].stringValue;
    self.amountToCollectLabel.fontColor = [UIColor whiteColor];
    self.amountToCollectLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    self.amountToCollectLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    self.amountToCollectLabel.position = CGPointMake(boat.size.width / 2, boat.size.height / 2);
    [self.uiLayer addChild:self.amountToCollectLabel];
    
    
    // Fish collection
    self.fishCollection = [[SKNode alloc] init];
    [self.world addChild:self.fishCollection];
    
    // Barrel Collection Node
    self.barrelCollectionNode = [[SKSpriteNode alloc] initWithColor:[UIColor yellowColor] size:CGSizeMake(100, 20)];
    self.barrelCollectionNode.name = @"Barrel";
    self.barrelCollectionNode.position = CGPointMake(self.size.width / 2, boat.size.height / 2);
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.barrelCollectionNode.frame];
    self.physicsBody.categoryBitMask = barrelCategory;
    self.physicsBody.contactTestBitMask = fishCategory;
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.dynamic = NO;
    self.physicsBody.affectedByGravity = NO;
    [self.world addChild:self.barrelCollectionNode];
    
    
    
    // Fish spawner
    self.fishSpawner = [[SKNode alloc] init];
    
    SKAction *throwFish = [SKAction runBlock:^{
        [self throwFish];
    }];
    SKAction *wait = [SKAction waitForDuration:3];
    SKAction *throwFishForever = [SKAction repeatActionForever:[SKAction sequence:@[throwFish, wait]]];
    [self runAction:throwFishForever];
    
    
}

// Redo all this collision detection, its just bad
- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKNode *node = contact.bodyA.node;
    if (![node.name isEqualToString:@"Bad Fish"])
    {
        node = contact.bodyB.node;
    }
    [node removeFromParent];
    
    self.amountOfFishToCollect--;
    if (self.amountOfFishToCollect <= 0) {
        [self.amountToCollectLabel removeFromParent];
    } else {
        self.amountToCollectLabel.text = [NSString stringWithFormat:@"%d", self.amountOfFishToCollect];
    }
    
    if (self.amountOfFishToCollect <= 0)
    {
        if (self.currentState != GameStateTransitioning)
        {
            [self returnToSceneFadeToBackgroundImageNamed:@"BoatBackgroundGood"];
        }
    }
}


- (void)update:(NSTimeInterval)currentTime
{
    [super update:currentTime];
    
    // Remove fish the player misses
    [self.fishCollection enumerateChildNodesWithName:@"Bad Fish" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y < 0)
            [node removeFromParent];
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self.world];
    SKNode *node = [self.fishCollection nodeAtPoint:location];
    if (node != self.fishCollection)
    {
        SKSpriteNode *sNode = (SKSpriteNode *)node;
        [self pickUpFish:sNode];

    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.currentFishHeld != nil)
    {
        self.currentFishHeld.position = [[touches anyObject] locationInNode:self.world];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [[touches anyObject] locationInNode:self.world];
    CGPoint prevLocation = [touch previousLocationInNode:self.world];
    [self releaseFishWithVelocity:CGVectorMake(prevLocation.x - location.x, prevLocation.y - location.y)];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self releaseFishWithVelocity:CGVectorMake(0, 0)];
}

- (void)pickUpFish:(SKSpriteNode *)fish
{
    if (self.currentFishHeld == nil)
    {
        self.currentFishHeld = fish;
        self.currentFishHeld.physicsBody.dynamic = NO;
        self.currentFishHeld.physicsBody.affectedByGravity = NO;
        self.currentFishHeld.physicsBody.velocity = CGVectorMake(0, 0);
    }
}

- (void)releaseFishWithVelocity:(CGVector)velocity
{
    if (self.currentFishHeld != nil)
    {
        self.currentFishHeld.physicsBody.dynamic = YES;
        self.currentFishHeld.physicsBody.affectedByGravity = YES;
        self.currentFishHeld.physicsBody.velocity = velocity;
    }
}

- (void)throwFish
{
    SKSpriteNode *badFish = [self makeBadFish];
    CGPoint spawnPoint = CGPointMake(self.size.width + badFish.size.width, self.size.height / 2);
    badFish.position = spawnPoint;
    double throwAngle = 3 * M_PI / 4;
    double throwMagnitude = 70;
    badFish.zRotation = -M_PI / 4;
    [badFish.physicsBody applyAngularImpulse:0.005];
    [badFish.physicsBody applyImpulse: CGVectorMake(throwMagnitude * cosf(throwAngle), throwMagnitude * sinf(throwAngle))];
    
}

- (void)createWaves
{
    // Create Waves
    SKSpriteNode *wave3 = [[SKSpriteNode alloc] initWithImageNamed:@"Wave3"];
    wave3.anchorPoint = CGPointZero;
    wave3.position = CGPointMake(0, 200);
    [self.world addChild:wave3];
    
    SKSpriteNode *wave2 = [[SKSpriteNode alloc] initWithImageNamed:@"Wave2"];
    wave2.anchorPoint = CGPointZero;
    wave2.position = CGPointMake(0, 100);
    [self.world addChild:wave2];
    
    SKSpriteNode *wave1 = [[SKSpriteNode alloc] initWithImageNamed:@"Wave1"];
    wave1.anchorPoint = CGPointZero;
    wave1.position = CGPointZero;
    [self.world addChild:wave1];
    
    double deltaX = wave3.size.width / 2;
    SKAction *moveLeft = [SKAction moveByX:-deltaX y:0.0 duration:3.5];
    SKAction *resetLeft = [SKAction moveToX:0 duration:0.0];
    SKAction *scrollRight = [SKAction sequence:@[moveLeft, resetLeft]];
    SKAction *scrollRightForever = [SKAction repeatActionForever:scrollRight];
    [wave3 runAction:scrollRightForever];
    
    deltaX = wave2.size.width / 2;
    wave2.position = CGPointMake(-deltaX, wave2.position.y);
    SKAction *moveRight = [SKAction moveByX:deltaX y:0.0 duration:3.5];
    SKAction *resetRight = [SKAction moveToX:-deltaX duration:0.0];
    SKAction *scrollLeft = [SKAction sequence:@[moveRight, resetRight]];
    SKAction *scrollLeftForever = [SKAction repeatActionForever:scrollLeft];
    [wave2 runAction:scrollLeftForever];

    deltaX = wave1.size.width / 2;
    moveLeft = [SKAction moveByX:-deltaX y:0.0 duration:2];
    resetLeft = [SKAction moveToX:0 duration:0.0];
    scrollRight = [SKAction sequence:@[moveLeft, resetLeft]];
    scrollRightForever = [SKAction repeatActionForever:scrollRight];
    [wave1 runAction:scrollRightForever];
    
    
    
}

- (SKSpriteNode *)makeBadFish
{
    SKSpriteNode *badFish = [[SKSpriteNode alloc] initWithImageNamed:@"FishBad"];
    badFish.name = @"Bad Fish";
    badFish.physicsBody.categoryBitMask = fishCategory;
    badFish.physicsBody.contactTestBitMask = barrelCategory;
    badFish.physicsBody.collisionBitMask = 0;
    badFish.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:badFish.size];
    badFish.physicsBody.dynamic = YES;
    badFish.physicsBody.affectedByGravity = YES;
    [self.fishCollection addChild:badFish];
    
    return badFish;
}



@end
