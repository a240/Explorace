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

@property SKNode *camera;
@property OGKRect *cameraBounds;
@property SKCropNode *world;
@property (readonly) OGKRect *worldViewBounds;
@property SKNode *uiLayer;

- (void)createContent;
- (void)cameraFollowNode:(SKNode *)node;
- (void)setCameraBoundsToWorld;


@end
