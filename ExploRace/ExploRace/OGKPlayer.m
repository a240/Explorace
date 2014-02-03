//
//  OGKPlayer.m
//  ExploRace
//
//  Created by David Samuelson on 1/31/14.
//  Copyright (c) 2014 OGK. All rights reserved.
//

#import "OGKPlayer.h"

@interface OGKPlayer ()

@property NSArray *idleTextures;

@end

@implementation OGKPlayer



- (instancetype)init
{
    if (self = [super initWithImageNamed:@"WizardIdle_01"])
    {
        self.idleTextures = @[[SKTexture textureWithImageNamed:@"WizardIdle_01"],
                          [SKTexture textureWithImageNamed:@"WizardIdle_02"],
                          [SKTexture textureWithImageNamed:@"WizardIdle_03"],
                          [SKTexture textureWithImageNamed:@"WizardIdle_04"],
                          [SKTexture textureWithImageNamed:@"WizardIdle_05"],
                          [SKTexture textureWithImageNamed:@"WizardIdle_06"],
                          [SKTexture textureWithImageNamed:@"WizardIdle_07"],
                          [SKTexture textureWithImageNamed:@"WizardIdle_08"],
                          [SKTexture textureWithImageNamed:@"WizardIdle_09"],
                          [SKTexture textureWithImageNamed:@"WizardIdle_10"],
                          [SKTexture textureWithImageNamed:@"WizardIdle_11"],
                                 [SKTexture textureWithImageNamed:@"WizardIdle_12"]];
        
    }
    return self;
}

- (void)playIdle
{
    
    
}

@end
