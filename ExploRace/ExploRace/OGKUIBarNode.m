//
//  OGKUIBarNode.m
//  ExploRace
//
//  Created by David Samuelson on 1/31/14.
//  Copyright (c) 2014 OGK. All rights reserved.
//

#import "OGKUIBarNode.h"
#define HEIGHT_IN_POINTS 24
#define FONT_SIZE 15

@interface OGKUIBarNode ()

@property SKLabelNode *timeLeftLabelNode;
@property SKSpriteNode *backgroundNode;

@end

@implementation OGKUIBarNode

- (instancetype)init
{
    if (self = [super init])
    {
        self.backgroundNode = [[SKSpriteNode alloc] initWithImageNamed:@"UIBackground"];
        [self addChild:self.backgroundNode];
        
        self.timeLeftLabelNode = [SKLabelNode labelNodeWithFontNamed:@"AppleSDGothicNeo-Regular"];
        self.timeLeftLabelNode.text = @"TIMER";
        self.timeLeftLabelNode.fontSize = FONT_SIZE;
        [self addChild:self.timeLeftLabelNode];
        
        self.timeLeft = [NSNumber numberWithDouble:0];
    }
    return self;
}

@end
