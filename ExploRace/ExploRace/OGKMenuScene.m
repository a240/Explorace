//
//  OGKMenuScene.m
//  ExploRace
//
//  Created by David Samuelson on 1/29/14.
//  Copyright (c) 2014 OGK. All rights reserved.
//

#import "OGKMenuScene.h"
#import "OGKMapScene.h"

@interface OGKMenuScene ()

@property BOOL contentCreated;

@end

@implementation OGKMenuScene

- (void)didMoveToView:(SKView *)view
{
    if (!self.contentCreated) {
        [self createSceneConents];
        self.contentCreated = YES;
    }
}

- (void)createSceneConents
{
    self.backgroundColor = [SKColor blueColor];
    self.scaleMode = SKSceneScaleModeAspectFill;
    SKSpriteNode *background = [[SKSpriteNode alloc] initWithImageNamed:@"MenuBackground"];
    background.anchorPoint = CGPointZero;
    [self addChild:background];
    
    SKSpriteNode *playButton = [[SKSpriteNode alloc] initWithImageNamed:@"PlayButton1"];
    NSArray *textures = @[[SKTexture textureWithImageNamed:@"PlayButton1"], [SKTexture textureWithImageNamed:@"PlayButton2"], [SKTexture textureWithImageNamed:@"PlayButton3"]];
    SKAction *animation = [SKAction animateWithTextures:textures timePerFrame:0.08];
    SKAction *animationForever = [SKAction repeatActionForever:animation];
    [playButton runAction:animationForever];
    playButton.position = CGPointMake(self.size.width / 2, self.size.height / 2);
    playButton.name = @"Play Button";
    [self addChild:playButton];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    SKNode *menuNode = [self childNodeWithName:@"Play Button"];
    if (menuNode != nil) {
        menuNode.name = nil;
        SKAction *moveUp = [SKAction moveByX:0 y:100 duration:0.5];
        SKAction *zoom = [SKAction scaleTo:1.4 duration:0.25];
        SKAction *fadeAway = [SKAction fadeOutWithDuration:0.25];
        SKAction *moveSequence = [SKAction group:@[moveUp, zoom, fadeAway, zoom]];
        SKAction *remove = [SKAction removeFromParent];
        SKAction *moveAndRemoveSequence = [SKAction sequence:@[moveSequence, remove]];
        [menuNode runAction:moveAndRemoveSequence completion:^{
            SKScene *mapScene= [[OGKMapScene alloc] initWithSize:self.size];
            SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
            [self.view presentScene:mapScene transition:doors];
        }];
    }
}

@end
