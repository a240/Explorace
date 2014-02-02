//
//  OGKWorldScene.m
//  ExploRace
//
//  Created by David Samuelson on 2/1/14.
//  Copyright (c) 2014 OGK. All rights reserved.
//

#import "OGKWorldScene.h"
#import "OGKTimerUINode.h"
#import "OGKGameTimer.h"
#define DEFAULT_TIME_TO_PLAY 10

@interface OGKWorldScene ()

@property BOOL contentCreated;
@property SKNode *cameraTarget;
@property OGKTimerUINode *timerNode;
@property OGKGameTimer *gameTimer;

@end


@implementation OGKWorldScene

- (void)didMoveToView:(SKView *)view
{
    if (!self.contentCreated)
    {
        self.contentCreated = YES;
        [self createContent];
    }
}

- (void)willMoveFromView:(SKView *)view
{
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers) {
        [self.view removeGestureRecognizer:recognizer];
    }
}

- (void)createContent
{
    // Setup layers
    self.backgroundLayer = [[SKNode alloc] init];
    self.world = [[SKCropNode alloc] init];
    self.uiLayer = [[SKNode alloc] init];
    [self addChild:self.backgroundLayer];
    [self addChild:self.world];
    [self addChild:self.uiLayer];
    
    // Game Timer
    self.gameTimer = [OGKGameTimer sharedInstance];
    [self.gameTimer runForTime:DEFAULT_TIME_TO_PLAY];
    
    // Add Timer
    self.timerNode = [[OGKTimerUINode alloc] init];
    CGRect timerNodeRect = [self.timerNode calculateAccumulatedFrame];
    self.timerNode.position = CGPointMake(0, self.size.height - timerNodeRect.size.height);
    [self.uiLayer addChild:self.timerNode];
    
    // Camera
    self.camera = [SKNode node];
    
    self.currentState = GameStatePlaying;
    
}

- (SKSpriteNode *)addBackgroundImageFromName:(NSString *)name
{
    SKSpriteNode *backgroundImageNode = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:name]];
    backgroundImageNode.anchorPoint = CGPointZero;
    [self.backgroundLayer addChild:backgroundImageNode];
    return backgroundImageNode;
}


- (void)cameraFollowNode:(SKNode *)node
{
    self.cameraTarget = node;
}

- (void)setCameraBoundsToWorld
{
    CGRect worldRect = [self.world calculateAccumulatedFrame];
    self.cameraBounds = [[OGKRect alloc] initWithX:self.world.position.x Y:self.world.position.y Width:worldRect.size.width Height:worldRect.size.height];
}

- (void)update:(NSTimeInterval)currentTime
{
    [self.timerNode setTime:self.gameTimer.getTimeLeft];
}

- (void)didSimulatePhysics
{
    [self updateCamera];
}

- (void)updateCamera
{
    // Move Camera to camera target
    if (self.cameraTarget != nil) {
        self.camera.position = CGPointMake(self.cameraTarget.position.x - self.size.width / 2, self.cameraTarget.position.y - self.size.height / 2);
    }
    
    if (self.cameraBounds != nil) {
        if (self.camera.position.x < self.cameraBounds.x)
            self.camera.position = CGPointMake(self.cameraBounds.x, self.camera.position.y);
        
        if (self.camera.position.x + self.scene.frame.size.width > self.cameraBounds.width)
            self.camera.position = CGPointMake(self.cameraBounds.width - self.scene.frame.size.width, self.camera.position.y);
        
        if (self.camera.position.y < self.cameraBounds.y)
            self.camera.position = CGPointMake(self.camera.position.x, self.cameraBounds.y);
        
        if (self.camera.position.y + self.scene.frame.size.height > self.cameraBounds.height)
            self.camera.position = CGPointMake(self.camera.position.x, self.cameraBounds.height - self.scene.frame.size.height);
    }
    
    // Update world based on camera
    [self centerWorldOnCamera];
}

- (void) centerWorldOnCamera
{
    CGPoint cameraPositionInScene = [self.scene convertPoint:self.camera.position fromNode:self.world];
    self.world.position = CGPointMake(self.world.position.x - cameraPositionInScene.x, self.world.position.y - cameraPositionInScene.y);
}

@end
