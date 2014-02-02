//
//  OGKWorldScene.h
//  ExploRace
//
//  Created by David Samuelson on 2/1/14.
//  Copyright (c) 2014 OGK. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "OGKRect.h"

@interface OGKWorldScene : SKScene

typedef NS_ENUM(NSInteger, GameState)
{
    GameStatePlaying,
    GameStateTransitioning
};

@property SKNode *camera;
@property OGKRect *cameraBounds;
@property SKCropNode *world;
@property (readonly) OGKRect *worldViewBounds;
@property SKNode *uiLayer;
@property SKNode *backgroundLayer;
@property GameState currentState;

- (void)createContent;
- (void)cameraFollowNode:(SKNode *)node;
- (void)setCameraBoundsToWorld;
- (SKSpriteNode *)addBackgroundImageFromName:(NSString *)name;


@end
