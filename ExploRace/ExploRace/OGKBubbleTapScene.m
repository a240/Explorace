//
//  OGKBubbleTapScene.m
//  ExploRace
//
//  Created by David Samuelson on 2/1/14.
//  Copyright (c) 2014 OGK. All rights reserved.
//

#import "OGKBubbleTapScene.h"
#define DEFAULT_BUBBLES_TO_SPAWN 6
#define SPEED_OF_BUBBLES 400
#define BAD_TO_GOOD_BUBBLE_RATIO 3

@interface OGKBubbleTapScene ()

@property SKNode *bubbles;
@property SKNode *goodBubbles;
@property SKNode *badBubbles;


@end

@implementation OGKBubbleTapScene

- (void)update:(NSTimeInterval)currentTime
{
    [super update:currentTime];
    
    if (self.badBubbles.children.count == 0 && self.currentState != GameStateTransitioning)
    {
        self.currentState = GameStateTransitioning;
        [self returnToSceneFadeToBackgroundImageNamed:@"SwampBackgroundGood"];
    }
}

- (void)createContent
{
    [super createContent];
    
    [self addBackgroundImageFromName:@"SwampBackgroundBad"];
    
    // Put Physic bounds on screen
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.friction = 0;
    self.physicsBody.restitution = 1;
    
    // Add Bubbles
    self.bubbles = [[SKNode alloc] init];
    [self.world addChild:self.bubbles];
    self.goodBubbles = [[SKNode alloc] init];
    [self.bubbles addChild:self.goodBubbles];
    self.badBubbles = [[SKNode alloc] init];
    [self.bubbles addChild:self.badBubbles];
    
    for (int i = 0; i < DEFAULT_BUBBLES_TO_SPAWN; i++) {
        [self spawnBubbleThatIsBad:!(i % BAD_TO_GOOD_BUBBLE_RATIO == 0)];
    }
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in [touches allObjects])
    {
        NSArray *bubbles = [self.bubbles nodesAtPoint:[touch locationInNode:self.world]];
        for (SKSpriteNode *bubble in bubbles) {
            if ([bubble.name isEqualToString:@"Bad Bubble"])
                [self popBadBubble:bubble];
            else if ([bubble.name isEqualToString:@"Good Bubble"])
                [self popGoodBubble:bubble];
        }
    }
}

- (SKSpriteNode *)spawnBubbleThatIsBad:(BOOL)isBad
{
    SKSpriteNode *bubble;
    if (isBad)
    {
        bubble = [self makeBadBubble];
        [self.badBubbles addChild:bubble];
    }
    else
    {
        bubble = [self makeGoodBubble];
        [self.goodBubbles addChild:bubble];
    }
    
    // Give random position
    int randX = (arc4random() % (int)(self.size.width - bubble.size.width * 2)) + bubble.size.width;
    int randY = (arc4random() % (int)(self.size.height - bubble.size.height * 2) + bubble.size.height);
    bubble.position = CGPointMake(randX, randY);
    
    // Give random Direction
    double randAngle = (arc4random() % 360) * M_PI / 180;
    CGFloat speedX = SPEED_OF_BUBBLES * cosf(randAngle);
    CGFloat speedY = SPEED_OF_BUBBLES * sinf(randAngle);
    bubble.physicsBody.velocity = CGVectorMake(speedX, speedY);
    
    return bubble;
}

- (void)popGoodBubble:(SKSpriteNode *)bubble
{
    // Spawn two move bubbles
    [self spawnBubbleThatIsBad:YES].position = bubble.position;
    [self spawnBubbleThatIsBad:NO].position = bubble.position;
    
    [bubble removeAllActions];
    NSArray *popTextures = @[[SKTexture textureWithImageNamed:@"GoodBubblePop1"], [SKTexture textureWithImageNamed:@"GoodBubblePop2"], [SKTexture textureWithImageNamed:@"GoodBubblePop3"]];
    SKAction *popAnimation = [SKAction animateWithTextures:popTextures timePerFrame:0.1];
    SKAction *popRemove = [SKAction sequence:@[popAnimation, [SKAction removeFromParent]]];
    [bubble runAction:popRemove];
}

- (SKSpriteNode *)makeGoodBubble
{
    SKSpriteNode *bubble = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"GoodBubble"]];
    bubble.name = @"Good Bubble";
    
    // Add bouncy streching to bubble
    SKAction *stretchX = [SKAction scaleXTo:1 duration:0.4];
    SKAction *stretchY = [SKAction scaleYTo:1 duration:0.4];
    SKAction *shrinkX  = [SKAction scaleXTo:0.8 duration:0.4];
    SKAction *shrinkY  = [SKAction scaleYTo:0.8 duration:0.4];
    SKAction *shrinkYStretchX = [SKAction group:@[shrinkY, stretchX]];
    SKAction *shrinkXStretchY = [SKAction group:@[shrinkX, stretchY]];
    SKAction *bubbleStretch = [SKAction sequence:@[shrinkXStretchY, shrinkYStretchX]];
    SKAction *bubbleStetchForever = [SKAction repeatActionForever:bubbleStretch];
    
    [bubble runAction:bubbleStetchForever];
    
    // Set up physics Body
    bubble.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:bubble.size.width / 2];
    bubble.physicsBody.dynamic = YES;
    bubble.physicsBody.affectedByGravity = NO;
    bubble.physicsBody.allowsRotation = NO;
    bubble.physicsBody.restitution = 1;
    bubble.physicsBody.linearDamping = 0.02;
    
    return bubble;
}

- (void)popBadBubble:(SKSpriteNode *)bubble
{
    [bubble removeAllActions];
    NSArray *popTextures = @[[SKTexture textureWithImageNamed:@"BadBubblePop1"], [SKTexture textureWithImageNamed:@"BadBubblePop2"], [SKTexture textureWithImageNamed:@"BadBubblePop3"]];
    SKAction *popAnimation = [SKAction animateWithTextures:popTextures timePerFrame:0.1];
    SKAction *popRemove = [SKAction sequence:@[popAnimation, [SKAction removeFromParent]]];
    [bubble runAction:popRemove];
}

- (SKSpriteNode *)makeBadBubble
{
    SKSpriteNode *bubble = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"BadBubble"]];
    bubble.name = @"Bad Bubble";
    
    // Add bouncy streching to bubble
    SKAction *stretchX = [SKAction scaleXTo:1 duration:0.4];
    SKAction *stretchY = [SKAction scaleYTo:1 duration:0.4];
    SKAction *shrinkX  = [SKAction scaleXTo:0.8 duration:0.4];
    SKAction *shrinkY  = [SKAction scaleYTo:0.8 duration:0.4];
    SKAction *shrinkYStretchX = [SKAction group:@[shrinkY, stretchX]];
    SKAction *shrinkXStretchY = [SKAction group:@[shrinkX, stretchY]];
    SKAction *bubbleStretch = [SKAction sequence:@[shrinkXStretchY, shrinkYStretchX]];
    SKAction *bubbleStetchForever = [SKAction repeatActionForever:bubbleStretch];
    
    [bubble runAction:bubbleStetchForever];
    
    // Set up physics Body
    bubble.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:bubble.size.width / 2];
    bubble.physicsBody.dynamic = YES;
    bubble.physicsBody.affectedByGravity = NO;
    bubble.physicsBody.allowsRotation = NO;
    bubble.physicsBody.restitution = 1;
    bubble.physicsBody.linearDamping = 0.02;
    
    return bubble;
}

@end
