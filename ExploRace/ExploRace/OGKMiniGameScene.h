//
//  OGKMiniGame.h
//  ExploRace
//
//  Created by David Samuelson on 2/2/14.
//  Copyright (c) 2014 OGK. All rights reserved.
//

#import "OGKWorldScene.h"

@interface OGKMiniGameScene : OGKWorldScene

- (instancetype)initWithSize:(CGSize)size ReturnScene:(SKScene *)scene;
- (void)returnToSceneFadeToBackgroundImageNamed:(NSString *)name;
- (void)returnToScene;

@end
