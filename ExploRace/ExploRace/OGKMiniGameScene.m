//
//  OGKMiniGame.m
//  ExploRace
//
//  Created by David Samuelson on 2/2/14.
//  Copyright (c) 2014 OGK. All rights reserved.
//

#import "OGKMiniGameScene.h"

@interface OGKMiniGameScene ()

@property SKScene *returnScene;

@end

@implementation OGKMiniGameScene

- (instancetype)initWithSize:(CGSize)size ReturnScene:(SKScene *)scene
{
    if (self = [super initWithSize:size]) {
        self.returnScene = scene;
    }
    return self;
}

- (void)returnToScene
{
    [self.view presentScene:self.returnScene];
}

- (void)returnToSceneFadeToBackgroundImageNamed:(NSString *)name
{
    [self addBackgroundImageFromName:name];
    SKSpriteNode *whiteScreen = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:self.size];
    [self.backgroundLayer addChild:whiteScreen];
    whiteScreen.anchorPoint = CGPointZero;
    SKAction *fade = [SKAction fadeAlphaTo:0 duration:0.5];
    SKAction *wait = [SKAction waitForDuration:1];
    SKAction *returnScene = [SKAction runBlock:^{
        [self returnToScene];
    }];
    SKAction *fadeWaitRemove = [SKAction sequence:@[fade, wait, returnScene]];
    [whiteScreen runAction:fadeWaitRemove];
}

@end
