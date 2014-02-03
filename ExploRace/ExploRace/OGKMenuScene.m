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
    [self addBackgroundImageFromName:@"MainMenuBackground"];
    self.backgroundColor = [SKColor blueColor];
    self.scaleMode = SKSceneScaleModeAspectFill;
    [self addChild:[self newMenuLabel]];
}

- (SKLabelNode *)newMenuLabel
{
    SKLabelNode *menuLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    menuLabel.name = @"menuNode";
    menuLabel.text = @"Explorace";
    menuLabel.fontSize = 42;
    menuLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    return menuLabel;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    SKNode *menuNode = [self childNodeWithName:@"menuNode"];
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
