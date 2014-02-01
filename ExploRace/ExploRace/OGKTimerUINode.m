//
//  OGKUIBarNode.m
//  ExploRace
//
//  Created by David Samuelson on 1/31/14.
//  Copyright (c) 2014 OGK. All rights reserved.
//

#import "OGKTimerUINode.h"
#define HEIGHT_IN_POINTS 24
#define FONT_SIZE 30
#define PADDING 5

@interface OGKTimerUINode ()

@property SKLabelNode *timeLeftLabelNode;
@property SKSpriteNode *timerSpriteNode;

@end

@implementation OGKTimerUINode

- (instancetype)init
{
    if (self = [super init])
    {
        self.timerSpriteNode = [[SKSpriteNode alloc] initWithImageNamed:@"Timer"];
        self.timerSpriteNode.position = CGPointMake(self.timerSpriteNode.size.width / 2 + PADDING, self.timerSpriteNode.position.y);
        [self addChild:self.timerSpriteNode];
        
        self.timeLeftLabelNode = [SKLabelNode labelNodeWithFontNamed:@"AppleSDGothicNeo-Regular"];
        self.timeLeftLabelNode.text = @"TIMER";
        self.timeLeftLabelNode.fontSize = FONT_SIZE;
        self.timeLeftLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        self.timeLeftLabelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        self.timeLeftLabelNode.position = CGPointMake( self.timerSpriteNode.position.x + self.timerSpriteNode.size.width + PADDING, self.timerSpriteNode.position.y);
        [self addChild:self.timeLeftLabelNode];
        
        self.timeLeft = [NSNumber numberWithDouble:0];
    }
    return self;
}

@end
